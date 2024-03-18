//
//  Timeout.swift
//
//
//  Created by Dr. Brandon Wiley on 3/18/24.
//

import Foundation

public class Timeout
{
    public let timeout: Duration

    public init(_ timeout: Duration)
    {
        self.timeout = timeout
    }

    public func wait<T>(_ function: @escaping () async throws -> T) async throws -> T
    {
        let worker: Task<T, Error> = Task
        {
            return try await function()
        }

        let _ = Task
        {
            try await Task.sleep(for: self.timeout)
            worker.cancel()
        }

        return try await worker.value
    }

    public func wait<T>(_ function: @escaping () async -> T) async throws -> T
    {
        let worker: Task<T, Error> = Task
        {
            return await function()
        }

        let _ = Task
        {
            try await Task.sleep(for: self.timeout)
            worker.cancel()
        }

        return try await worker.value
    }

    public func wait<T>(_ function: @escaping () throws -> T) throws -> T
    {
        return try AsyncAwaitThrowingSynchronizer<T>.sync
        {
            try await self.wait
            {
                return try await AsyncAwaitAsynchronizer.async(function)
            }
        }
    }

    public func wait(_ function: @escaping () async throws -> ()) async throws
    {
        let worker: Task<(), Error> = Task
        {
            try await function()
        }

        let _ = Task
        {
            try await Task.sleep(for: self.timeout)
            worker.cancel()
        }

        try await worker.value
    }

    public func wait(_ function: @escaping () async -> ()) async throws
    {
        let worker: Task<(), Error> = Task
        {
            await function()
        }

        let _ = Task
        {
            try await Task.sleep(for: self.timeout)
            worker.cancel()
        }

        try await worker.value
    }

    public func wait(_ function: @escaping () throws -> ()) throws
    {
        try AsyncAwaitThrowingSynchronizer<()>.sync
        {
            try await self.wait
            {
                try await AsyncAwaitAsynchronizer.async(function)
            }
        }
    }
}
