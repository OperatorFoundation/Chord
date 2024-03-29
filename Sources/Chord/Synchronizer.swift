//
//  Optional.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

public typealias Callback0 = () -> Void
public typealias Callback<T> = (T) -> Void
public typealias Callback2<S, T> = (S, T) -> Void
public typealias Caller0 = (@escaping Callback0) -> Void
public typealias Caller<T> = (@escaping Callback<T>) -> Void
public typealias Caller2<S, T> = (@escaping Callback2<S, T>) -> Void
public typealias CallerWithArg<S, T> = (S, @escaping Callback<T>) -> Void
public typealias CallerThrows<T> = (@escaping Callback<T>) throws -> Void
public typealias AsyncCaller<T> = () async -> T
public typealias AsyncThrowingCaller<T> = () async throws -> T
public typealias AsyncEffect = () async -> Void
public typealias AsyncThrowingEffect = () async throws -> Void

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

    static public func sync<S, T>(_ arg: S, _ function: @escaping CallerWithArg<S, T>) -> T
    {
        let lock = DispatchGroup()

        var result: T?

        lock.enter()
        function(arg)
        {
            result = $0
            lock.leave()
        }
        lock.wait()

        return result!
    }

    static public func sync2<S, T>(_ function: @escaping Caller2<S, T>) -> (S, T)
    {
        let lock = DispatchGroup()

        var result: (S, T)?

        lock.enter()
        function
        {
            result = ($0, $1)
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

public class MainThreadEffectSynchronizer
{
    static public func sync(_ function: @escaping Caller0)
    {
        let lock = DispatchGroup()

        lock.enter()
        DispatchQueue.main.async
        {
            function
            {
                lock.leave()
            }
        }

        lock.wait()
    }
}

public class MainThreadEffect
{
    static public func sync(_ function: @escaping Callback0)
    {
        let lock = DispatchSemaphore(value: 0)

        if Thread.isMainThread
        {
            function()
        }
        else
        {
            DispatchQueue.main.async
            {
                function()
                lock.signal()
            }

            lock.wait()
        }
    }
}

@available(macOS 12.0, *)
public class AsyncAwaitSynchronizer<T>
{
    static public func sync(_ function: @escaping AsyncCaller<T>) -> T
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

        Task
        {
            self.result = await function()
            lock.signal()
        }

        lock.wait()

        return self.result!
    }
}

@available(macOS 12.0, *)
public class AsyncAwaitThrowingSynchronizer<T>
{
    static public func sync(_ function: @escaping AsyncThrowingCaller<T>) throws -> T
    {
        let synchronizer = AsyncAwaitThrowingSynchronizer<T>(function)
        return try synchronizer.sync()
    }

    let function: AsyncThrowingCaller<T>

    public init(_ function: @escaping AsyncThrowingCaller<T>)
    {
        self.function = function
    }

    func sync() throws -> T
    {
        let queue = BlockingQueue<Result<T,Error>>()

        Task
        {
            do
            {
                let result = try await function()
                queue.enqueue(element: Result.success(result))
            }
            catch
            {
                queue.enqueue(element: Result.failure(error))
            }
        }

        let result = queue.dequeue()

        switch result
        {
            case .success(let value):
                return value

            case .failure(let error):
                throw error
        }
    }
}

@available(macOS 12.0, *)
public class AsyncAwaitEffectSynchronizer
{
    static public func sync(_ function: @escaping AsyncEffect)
    {
        let synchronizer = AsyncAwaitEffectSynchronizer(function)
        return synchronizer.sync()
    }

    let function: AsyncEffect

    public init(_ function: @escaping AsyncEffect)
    {
        self.function = function
    }

    func sync()
    {
        let lock = DispatchSemaphore(value: 0)

        Task
        {
            await function()

            lock.signal()
        }

        lock.wait()
    }
}

@available(macOS 12.0, *)
public class AsyncAwaitThrowingEffectSynchronizer
{
    static public func sync(_ function: @escaping AsyncThrowingEffect)
    {
        let synchronizer = AsyncAwaitThrowingEffectSynchronizer(function)
        return synchronizer.sync()
    }

    let function: AsyncThrowingEffect

    public init(_ function: @escaping AsyncThrowingEffect)
    {
        self.function = function
    }

    func sync()
    {
        let lock = DispatchSemaphore(value: 0)

        Task
        {
            do
            {
                try await function()
            }
            catch
            {
            }

            lock.signal()
        }

        lock.wait()
    }
}
