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
    var lock = DispatchGroup()
    var counter = InvertedLockedCounter()
    
    public init()
    {
    }
    
    public func enqueue(element: T)
    {
        lock.enter()
        
        queue.enqueue(element)
        counter.increment()
        
        lock.leave()
    }
    
    public func dequeue() -> T
    {
        while true
        {
            // Wait for counter > 0
            counter.wait()

            lock.enter()

            guard let result = queue.dequeue() else
            {
                lock.leave()
                continue
            }

            counter.decrement()
            lock.leave()
            return result
        }
    }
}
