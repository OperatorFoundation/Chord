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
    let function: () async throws -> T
    let queue: DispatchQueue = DispatchQueue(label: "Promise")
    var value: PromiseStatus<T> = .waiting

    public init(_ function: @escaping () async throws -> T)
    {
        self.function = function

        self.queue.async
        {
            Task
            {
                do
                {
                    let output = try await self.function()
                    self.value = .success(output)
                }
                catch
                {
                    self.value = .failed(error)
                }
            }
        }
    }

    public func result() -> PromiseStatus<T>
    {
        return value
    }
}
