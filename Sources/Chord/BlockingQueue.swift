//
//  BlockingQueue.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/31/20.
//

import Foundation
import SwiftQueue

public class BlockingQueue<T>: @unchecked Sendable
{
    var value: T? = nil
    var enqueueLock = DispatchSemaphore(value: 1)
    var dequeueLock = DispatchSemaphore(value: 0)
    let uuid = UUID()

    public init()
    {
    }
    
    public func enqueue(element: T)
    {
        print("BlockingQueue[\(self.uuid)].enqueue(\(element))")
        print("BlockingQueue[\(self.uuid)].enqueue: waiting on enqueueLock")
        enqueueLock.wait()
        print("BlockingQueue[\(self.uuid)].enqueue: passed enqueueLock")

        self.value = element

        print("BlockingQueue[\(self.uuid)].enqueue: sending dequeueLock signal")
        dequeueLock.signal()
        print("BlockingQueue[\(self.uuid)].enqueue: sent dequeueLock signal")
    }
    
    public func dequeue() -> T
    {
        print("BlockingQueue[\(self.uuid)].dequeue()")
        print("BlockingQueue[\(self.uuid)].dequeue: waiting on dequeueLock")
        dequeueLock.wait()
        print("BlockingQueue[\(self.uuid)].dequeue: passed dequeueLock")

        let result = self.value!
        self.value = nil

        print("BlockingQueue[\(self.uuid)].dequeue: sending enqueueLock signal")
        enqueueLock.signal()
        print("BlockingQueue[\(self.uuid)].dequeue: sent enqueueLock signal")

        return result
    }
}
