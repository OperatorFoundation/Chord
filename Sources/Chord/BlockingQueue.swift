//
//  BlockingQueue.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/31/20.
//

import Foundation
import SwiftQueue

public class BlockingQueue<T>
{
    var queue = Queue<T>()
    var queueLock = DispatchGroup()
    var nonemptyLock = DispatchGroup()

    public init()
    {
        // Queue is initially empty
        self.nonemptyLock.enter()
    }
    
    public func enqueue(element: T)
    {
        queueLock.enter()

        // Was the queue previously empty?
        let wasEmpty: Bool = queue.isEmpty

        // The queue is now definitely non-Empty
        queue.enqueue(element)

        // Did we just transition from empty to non-empty?
        if wasEmpty
        {
            // If so, the nonemptyLock is locked and we need to unlock it.
            // Otherwise, the nonemptyLock is not locked, so we shouldn't unlock it.
            self.nonemptyLock.leave()
        }

        queueLock.leave()
    }
    
    public func dequeue() -> T?
    {
        // Wait for the queue to be non-empty
        nonemptyLock.wait()

        queueLock.enter()

        nonemptyLock.wait()

        guard let result = queue.dequeue() else
        {
            nonemptyLock.enter()
            queueLock.leave()
            return nil
        }

        if queue.isEmpty
        {
            nonemptyLock.enter()
        }

        queueLock.leave()

        return result
    }
}
