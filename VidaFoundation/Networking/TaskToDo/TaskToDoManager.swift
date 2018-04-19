//
//  TaskToDoManager.swift
//  VidaFoundation
//
//  Created by Brice Pollock on 4/18/18.
//  Copyright © 2018 Vida Health. All rights reserved.
//

import Foundation
import RxSwift

public struct TaskToDoManager {
    let service = TaskToDoService()

    public init() { }

    public func tasks() -> Observable<Result<ToDoTaskResponse>> {
        return service.tasks()
    }

    public func createTask(_ task: ToDoTask) -> Observable<Result<Bool>> {
        return service.createTask(task)
    }

    public func updateTask(_ task: ToDoTask) -> Observable<Result<Bool>> {
        return service.updateTask(task)
    }

    public func deleteTask(_ task: ToDoTask) -> Observable<Result<Bool>> {
        return service.updateTask(task)
    }
}
