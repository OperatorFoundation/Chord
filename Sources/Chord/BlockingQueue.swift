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
        enqueueLock.wait()

        self.value = element

        _ = dequeueLock.signal()
    }
    
    public func dequeue() -> T
    {
        dequeueLock.wait()
        
        let result = self.value!
        self.value = nil

        _ = enqueueLock.signal()

        return result
    }
}
