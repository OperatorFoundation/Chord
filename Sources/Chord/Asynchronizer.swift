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
