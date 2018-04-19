//
//  ToDoService.swift
//  VidaFoundation
//
//  Created by Brice Pollock on 4/18/18.
//  Copyright © 2018 Vida Health. All rights reserved.
//

import Foundation
import VidaFoundation
import RxSwift

public struct TaskToDoService {
    private let networkManager = NetworkManager()
    private let storage = GlobalStorage()

    public init() {
        if let tasks: [ToDoTask] = storage.object(forKey: GlobalStorage.Keys.tasks) {
            cachedTasks = BehaviorSubject.init(value: Result.value(tasks))
            return
        } else {
            cachedTasks = BehaviorSubject.init(value: Result.value([]))
        }
    }

    var cachedTasks: BehaviorSubject<Result<[ToDoTask]>>

    private func networkTasks() -> Observable<Result<ToDoTaskResponse>> {
        guard let url = NSMutableURLRequest(endpoint: .todos, version: .v1, type: .get) else {
            return Observable.just(Result.error(NetworkError(type: .invalidUrl, message: "Could not create url")))
        }
        return networkManager.request(url).map({ (result) -> Result<ToDoTaskResponse> in
            return NetworkDecoder.decodeResult(result)
        })
    }

    public func tasks() -> Observable<Result<[ToDoTask]>> {
            return cachedTasks
                .do(onNext: { result in
                    switch result {
                    case .value(let list): //update cache
                        self.storage.set(list, forKey: GlobalStorage.Keys.tasks)
                    case .error(let error): // log error
                        errorLog(error)
                    }
                },
                    onSubscribed: refreshTasks)
                .map {result in
                    switch result {
                    case .error(let error):
                        return Result.error(error)
                    case .value(let taskList):
                        return Result.value(taskList)
                    }
                }
    }

    func refreshTasks() {
        networkTasks().subscribe(onNext:{result in
            switch result {
            case .error(let error):
                errorLog(error)
            case .value(let taskList):
                self.cachedTasks.onNext(Result.value(taskList.objects))
            }
        }).dispose()
    }

    func createTask(_ task: LocalToDoTask) -> Observable<Result<Bool>> {
        do {
            let data = try JSONEncoder().encode(task)
            guard let url = NSMutableURLRequest(endpoint: .todos, version: .v1, type: .post, data: data) else {
                return Observable.just(Result.error(NetworkError(type: .invalidUrl, message: "Could not create url")))
            }
            return networkManager.request(url).map({ (result) -> Result<Bool> in
                return NetworkDecoder.decodeBoolResult(result)
            })
        } catch {
            errorLog(error)
            return Observable.just(Result.error(error))
        }
    }

    func updateTask(_ task: ToDoTask) -> Observable<Result<Bool>> {
        do {
            let data = try JSONEncoder().encode(task)
            guard let url = NSMutableURLRequest(endpoint: .todos, version: .v1, type: .put, data: data) else {
                return Observable.just(Result.error(NetworkError(type: .invalidUrl, message: "Could not create url")))
            }
            return networkManager.request(url).map({ (result) -> Result<Bool> in
                return NetworkDecoder.decodeBoolResult(result)
            })
        } catch {
            errorLog(error)
            return Observable.just(Result.error(error))
        }
    }

    func deleteTask(_ task: ToDoTask) -> Observable<Result<Bool>> {
        do {
            let data = try JSONEncoder().encode(task)
            guard let url = NSMutableURLRequest(endpoint: .todos, version: .v1, type: .delete, data: data) else {
                return Observable.just(Result.error(NetworkError(type: .invalidUrl, message: "Could not create url")))
            }
            return networkManager.request(url).map({ (result) -> Result<Bool> in
                return NetworkDecoder.decodeBoolResult(result)
            })
        } catch {
            errorLog(error)
            return Observable.just(Result.error(error))
        }
    }
}
