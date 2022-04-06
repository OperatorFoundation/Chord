//
//  Optional.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

public typealias Callback<T> = (T) -> Void
public typealias Caller<T> = (@escaping Callback<T>) -> Void
public typealias CallerThrows<T> = (@escaping Callback<T>) throws -> Void
public typealias AsyncCaller<T> = () async -> T

// Convert a failable async function into a synchronous function with an optional return value
public class Synchronizer
{
    static public func sync<T>(_ function: @escaping Caller<T>) -> T
    {
        let lock = DispatchGroup()
        
        var result: T?
        
        lock.enter()
        function
        {
            result = $0
            lock.leave()
        }
        lock.wait()
        
        return result!
    }

    static public func syncThrows<T>(_ function: @escaping CallerThrows<T>) throws -> T
    {
        let lock = DispatchGroup()

        var result: T?

        lock.enter()
        try function
        {
            result = $0
            lock.leave()
        }
        lock.wait()

        return result!
    }
}

public class MainThreadSynchronizer
{
    static public func sync<T>(_ function: @escaping Caller<T>) -> T
    {
        let lock = DispatchGroup()
        
        var result: T?
        
        lock.enter()
        DispatchQueue.main.async {
            function
            {
                result = $0
                lock.leave()
            }
        }
    
        lock.wait()
        
        return result!
    }
}

public class AsyncAwaitSynchronizer<T>
{
    static public func sync<T>(_ function: @escaping AsyncCaller<T>) -> T
    {
        let synchronizer = AsyncAwaitSynchronizer<T>(function)
        return synchronizer.sync()
    }

    let function: AsyncCaller<T>
    var result: T?

    public init(_ function: @escaping AsyncCaller<T>)
    {
        self.function = function
    }

    func sync() -> T
    {
        let lock = DispatchSemaphore(value: 0)

        async // Ignore warning about deprecation of async in favor of Task as Task does not currently work on Linux
        {
            self.result = await function()
            lock.signal()
        }

        lock.wait()

        return self.result!
    }
}
