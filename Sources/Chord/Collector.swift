//
//  File.swift
//  
//
//  Created by Dr. Brandon Wiley on 1/21/21.
//

import Foundation

public class Collector<O>
{
    let queue = DispatchQueue(label: "Collector")
    let lock = DispatchGroup()
    var taskCount = 0
    var outputs: [O] = []

    public init()
    {
    }

    public var isEmptyOfTasks: Bool
    {
        self.lock.enter()
        let result = taskCount == 0
        self.lock.leave()

        return result
    }

    public var isEmptyOfOutputs: Bool
    {
        self.lock.enter()
        let result = outputs.isEmpty
        self.lock.leave()

        return result
    }

    public func addTask(_ task: @escaping () -> O)
    {
        queue.async
        {
            self.lock.enter()
            self.taskCount += 1
            self.lock.leave()

            let output = task()

            self.lock.enter()
            self.taskCount -= 1
            self.outputs.append(output)
            self.lock.leave()
        }
    }
}
