//
//  Optional.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

public typealias Callback<T> = (T) -> Void
public typealias Caller<T> = (@escaping Callback<T>) -> Void

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
}
