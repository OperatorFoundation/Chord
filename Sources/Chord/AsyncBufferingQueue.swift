//
//  AsyncBufferingQueue.swift
//
//
//  Created by Dr. Brandon Wiley on 8/2/24.
//

import Foundation

public class AsyncBufferingQueue<Element>
{
    public var isEmpty: Bool
    {
        return self.queue.isEmpty
    }

    public var count: Int
    {
        return self.queue.count
    }

    public let bufferSize: Int

    let functionLock: AsyncSemaphore = AsyncSemaphore(value: 1)
    let enqueueLock: AsyncSemaphore = AsyncSemaphore()
    let dequeueLock: AsyncSemaphore = AsyncSemaphore()

    var queue: [Element] = []

    public init(bufferSize: Int = 1)
    {
        self.bufferSize = bufferSize
    }

    public func enqueue(_ element: Element) async
    {
        await self.functionLock.wait()

        while self.queue.count >= self.bufferSize
        {
            await self.enqueueLock.wait()

            await Task.yield()
        }

        if self.queue.isEmpty
        {
            self.queue.append(element)
        }
        else
        {
            self.queue.append(element)
            
            await self.dequeueLock.signal()
        }

        await self.functionLock.signal()
    }

    public func dequeue() async -> Element
    {
        await self.functionLock.wait()

        while true
        {
            guard let element = self.queue.first else
            {
                await self.dequeueLock.wait()

                await Task.yield()

                continue
            }

            if self.queue.count >= self.bufferSize
            {
                self.queue = [Element](self.queue.dropFirst())

                if self.queue.count < self.bufferSize
                {
                    await self.enqueueLock.signal()
                }
            }
            else
            {
                self.queue = [Element](self.queue.dropFirst())
            }

            await self.functionLock.signal()

            return element
        }
    }
}

public enum AsyncBufferingQueueError: Error
{
    case empty
}
