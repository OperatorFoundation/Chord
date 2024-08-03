//
//  AsyncLock.swift
//
//
//  Created by Dr. Brandon Wiley on 8/2/24.
//

import Foundation

public actor AsyncSemaphore
{
    let semaphore: DispatchSemaphore

    public init(value: Int = 0)
    {
        self.semaphore = DispatchSemaphore(value: value)
    }

    public func wait() async
    {
        await withCheckedContinuation
        {
            continuation in

            self.semaphore.wait()

            continuation.resume()
        }
    }

    public func signal() async
    {
        self.semaphore.signal()
    }
}
