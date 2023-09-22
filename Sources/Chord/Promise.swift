//
//  Promise.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/22/23.
//

import Foundation

public enum PromiseStatus<T>
{
    case success(T)
    case failed(Error)
    case waiting
}

public class Promise<T>
{
    let queue: DispatchQueue = DispatchQueue(label: "Promise")
    var value: PromiseStatus<T> = .waiting

    public init(_ function: @escaping () async throws -> T)
    {
        self.queue.async
        {
            Task
            {
                do
                {
                    let output = try await function()
                    self.value = .success(output)
                }
                catch
                {
                    self.value = .failed(error)
                }
            }
        }
    }

    public init(value: T)
    {
        self.value = .success(value)
    }

    public func result() -> PromiseStatus<T>
    {
        return value
    }
}
