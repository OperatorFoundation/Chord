//
//  AsyncQueue.swift
//
//
//  Created by Dr. Brandon Wiley on 11/29/23.
//

import Foundation

public actor AsyncQueue<T>
{
    let queue: BlockingQueue<T>

    public init(name: String? = nil)
    {
        if let name = name
        {
            self.queue = BlockingQueue<T>(name: name)
        }
        else
        {
            self.queue = BlockingQueue<T>()
        }
    }

    public func enqueue(element: T)
    {
        AsyncAwaitSynchronizer<T>.sync
        {
            self.queue.enqueue(element: element)
        }
    }

    public func dequeue() -> T
    {
        return AsyncAwaitSynchronizer<T>.sync
        {
            return self.queue.dequeue()
        }
    }
}
