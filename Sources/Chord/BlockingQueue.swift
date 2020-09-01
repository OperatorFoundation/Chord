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
        counter.wait()

        lock.enter()
        
        let result = queue.dequeue()!
        counter.decrement()
        
        lock.leave()
        
        return result
    }
}
