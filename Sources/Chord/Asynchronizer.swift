//
//  Asynchronizer.swift
//  
//
//  Created by Dr. Brandon Wiley on 4/22/22.
//

import Foundation

public class Asynchronizer
{
    static public func async<T>(_ function: @escaping () -> T, _ callback: @escaping (T) -> Void)
    {
        let queue = DispatchQueue(label: "Asynchronizer.async")

        queue.async
        {
            let result: T = function()
            callback(result)
        }
    }

    static public func asyncThrows(_ function: @escaping () throws -> Void, _ callback: @escaping (Error?) -> Void)
    {
        let queue = DispatchQueue(label: "Asynchronizer.async")

        queue.async
        {
            do
            {
                try function()
                callback(nil)
            }
            catch
            {
                callback(error)
            }
        }
    }
}

public class AsyncAwaitAsynchronizer
{
    static public func async(_ blockingCall: @escaping () -> Void ) async
    {
        func dispatch(completion: @escaping () -> Void)
        {
            DispatchQueue.global(qos: .userInitiated).async
            {
                blockingCall()
                completion()
            }
        }

        return await withCheckedContinuation
        {
            continuation in

            dispatch
            {
                continuation.resume(returning: ())
            }
        }
    }

    static public func async(_ blockingCall: @escaping () throws -> Void ) async throws
    {
        func dispatch(completion: @escaping (Error?) -> Void)
        {
            DispatchQueue.global(qos: .userInitiated).async
            {
                do
                {
                    try blockingCall()
                    completion(nil)
                }
                catch
                {
                    completion(error)
                }
            }
        }

        return try await withCheckedThrowingContinuation
        {
            continuation in

            dispatch
            {
                maybeError in

                if let error = maybeError
                {
                    continuation.resume(throwing: error)
                }
                else
                {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    static public func async<T>(_ blockingCall: @escaping () -> T ) async -> T
    {
        func dispatch(completion: @escaping (T) -> Void)
        {
            DispatchQueue.global(qos: .userInitiated).async
            {
                let result: T = blockingCall()
                completion(result)
            }
        }

        return await withCheckedContinuation
        {
            continuation in

            dispatch
            {
                result in

                continuation.resume(returning: result)
            }
        }
    }

    static public func async<T>(_ blockingCall: @escaping () throws -> T ) async throws -> T
    {
        func dispatch(completion: @escaping (Result<T,Error>) -> Void)
        {
            DispatchQueue.global(qos: .userInitiated).async
            {
                do
                {
                    let result = try blockingCall()
                    completion(Result.success(result))
                }
                catch
                {
                    completion(Result.failure(error))
                }
            }
        }

        return try await withCheckedThrowingContinuation
        {
            continuation in

            dispatch
            {
                result in

                switch result
                {
                    case .success(let value):
                        continuation.resume(returning: value)

                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        }
    }
}
