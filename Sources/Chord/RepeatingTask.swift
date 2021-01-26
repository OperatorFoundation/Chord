//
//  RepeatingTask.swift
//  
//
//  Created by Dr. Brandon Wiley & Mafalda on 1/26/21.
//

import Foundation

public class RepeatingTask
{
    let queue = DispatchQueue(label: "RepeatingTaskQueue")
    let cancelLock = DispatchGroup()
    let taskLock = DispatchGroup()
    let task: () -> Bool
    
    var notCancelled = true
    
    public init(task:@escaping () -> Bool)
    {
        self.task = task
        
        self.taskLock.enter()
        self.run()
    }
    
    public func run()
    {
        // Always lock before interacting with keepRunning
        cancelLock.enter()
        var keepRunning = notCancelled
        cancelLock.leave()
        
        if keepRunning
        {
            queue.async
            {
                let goAgain = self.task()
                
                // Always lock before interacting with keepRunning
                self.cancelLock.enter()
                keepRunning = self.notCancelled
                self.cancelLock.leave()
                
                if goAgain && keepRunning
                {
                    self.run()
                }
                else
                {
                    self.taskLock.leave()
                }
            }
        }
    }
    
    public func wait()
    {
        taskLock.wait()
    }
    
    public func cancel()
    {
        cancelLock.enter()
        notCancelled = false
        cancelLock.leave()
    }
}
