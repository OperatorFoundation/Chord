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
    let name: String

    public init(name: String? = nil)
    {
        if let name = name
        {
            self.name = name
        }
        else
        {
            self.name = self.uuid.uuidString
        }
    }
    
    public func enqueue(element: T)
    {
        print("BlockingQueue[\(self.name)].enqueue(\(element))")
//        print("BlockingQueue[\(self.name)].enqueue: waiting on enqueueLock")
        enqueueLock.wait()
        print("BlockingQueue[\(self.name)].enqueue: passed enqueueLock")

        self.value = element

//        print("BlockingQueue[\(self.name)].enqueue: sending dequeueLock signal")
        let signalResponse = dequeueLock.signal()
        if signalResponse == 0
        {
            print("dequeueLock.signal did not wake a thread")
        }
        else
        {
            print("dequeueLock.signal woke the thread")
        }
//        print("BlockingQueue[\(self.name)].enqueue: sent dequeueLock signal")
    }
    
    public func dequeue() -> T
    {
//        print("BlockingQueue[\(self.name)].dequeue()")
        print("BlockingQueue[\(self.name)].dequeue: waiting on dequeueLock")
        if self.value == nil {
            print("\(self.name) value is nil")
        }
        else
        {
            print("\(self.name) value is: \(self.value!)")
        }
        
        dequeueLock.wait()
//        print("BlockingQueue[\(self.name)].dequeue: passed dequeueLock")
        
        let result = self.value!
        self.value = nil

//        print("BlockingQueue[\(self.name)].dequeue: sending enqueueLock signal")
        let signalResponse = enqueueLock.signal()
        if signalResponse == 0
        {
            print("enqueueLock.signal did not wake a thread")
        }
        else
        {
            print("enqueueLock.signal woke the thread")
        }
//        print("BlockingQueue[\(self.name)].dequeue: sent enqueueLock signal")

        return result
    }
}
