//
//  AsyncQueue.swift
//
//
//  Created by Dr. Brandon Wiley on 11/29/23.
//

import Foundation

public class AsyncQueue<T>
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

    public func enqueue(element: T) async
    {
        await AsyncAwaitAsynchronizer.async<T>
        {
            self.queue.enqueue(element: element)
        }
    }

    public func dequeue() async -> T
    {
        await AsyncAwaitAsynchronizer.async<T>
        {
            return self.queue.dequeue()
        }
    }
}
