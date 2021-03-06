//
//  TodoListTableViewModel.swift
//  VidaToDo
//
//  Created by Bart Chrzaszcz on 4/18/18.
//  Copyright © 2018 Vida Health. All rights reserved.
//

import RxCocoa

extension ToDoTask.Priority {
    struct Strings {
        static let high = "High:"
        static let medium = "Medium:"
        static let low = "Low:"
    }

    func text() -> String {
        switch self {
        case .high:
            return Strings.high
        case .medium:
            return Strings.medium
        case .low:
            return Strings.low
        }
    }
}

class TodoListTableViewModel {
    let taskToDoManager = TaskToDoManager()
    let bag = DisposeBag()

    // MARK: Observables
    private let tasksViewDataSubject = BehaviorSubject<[TodoCardTableViewData]>(value: [])
    var tasksViewData: Observable<[TodoCardTableViewData]> {
        return tasksViewDataSubject
    }

    init() {
        updateTasks()
    }

    // MARK: Public Subscriptions

    func subscribeToTaskIsDoneObservable(_ observable: Observable<(id: Int, isDone: Bool)>) {
        observable.withLatestFrom(taskToDoManager.tasks()) { (taskIsDoneTuple, tasks) -> (ToDoTask?, Bool) in
                let (taskID, isDone) = taskIsDoneTuple
                return (tasks.filter({$0.id == taskID}).first, isDone)
            }.flatMap({ (task, isDone) -> Observable<Result<Bool>> in
                guard let task = task else {
                    // TODO: Should not be network errroe here, would require knowing impl. of manager
                    let error = NetworkError(type: .invalidUrl, message: "unable to find task that is done for task")
                    errorLog(error)
                    return Observable.just(Result.error(error))
                }
                // TODO: Investigate if we want network request to return Singles
                return self.taskToDoManager.updateTask(ToDoTask(id: task.id, group: task.group, title: task.title, description: task.description, priority: task.priority, done: isDone))
            }).subscribe(onNext: { (result) in
                guard case .value(_) = result else {
                    errorLog("unable to update task for isDone")
                    // FIXME: We always fail sending to the server
                    return
                }
                return
            }).disposed(by: bag)
    }

    // MARK: Public
    // TODO: Update UI based on task selection
    func taskIsSelected(taskID: Int) {
        Observable.just(taskID).withLatestFrom(taskToDoManager.tasks()).subscribe(onNext: { (tasks) in
            guard tasks.filter({ $0.id == taskID}).first != nil else {
                errorLog("unable to find task")
                return
            }
            // TODO: Do something with the task selection
            return
        }).disposed(by: bag)
    }

    func removeTaskWithID(_ taskID: Int) {
        Observable.just(taskID).withLatestFrom(taskToDoManager.tasks()).subscribe(onNext: { (tasks) in
            guard tasks.filter({ $0.id == taskID}).first != nil else {
                errorLog("unable to find task")
                return
            }
            // TODO: Remove the task
            return
        }).disposed(by: bag)
    }

    func viewDidAppear() {
        updateTasks()
    }

    // MARK: Private

    // TODO: Define a suite of patterns for cacheOnly (take(1)?), networkOnly (skip(1)?) type things
    // TODO: Define a pattern for using distinctUntilChanged to only update the UI if view data has changed.
    func updateTasks() {
        taskToDoManager.tasks().map({ (tasks)  in
            tasks.map {
                return TodoCardTableViewData(taskID: $0.id, priorityText: $0.priority.text(), taskTitle: $0.title, isDone: $0.done)
            }
        }).subscribe(onNext: { [weak self] (taskViewDataList) in
            self?.tasksViewDataSubject.onNext(taskViewDataList)
        }).disposed(by: bag)
    }
}
