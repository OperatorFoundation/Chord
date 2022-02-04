//
//  FilteredQueue.swift
//
//
//  Created by Dr. Brandon Wiley on 8/31/20.
//

import Foundation
import SwiftQueue


public class FilteredQueue<T>
{
    public static func drop(_ item: T)
    {
        return
    }

    var lock = DispatchGroup()
    var filters: [Filter<T>] = []
    var otherwise: (T) -> ()

    public init(otherwise: @escaping (T) -> () = FilteredQueue.drop)
    {
        self.otherwise = otherwise
    }

    public func enqueue(_ element: T)
    {
        lock.enter()

        for filter in filters
        {
            if filter.match(element)
            {
                filter.handle(element)

                lock.leave()
                return
            }
        }

        otherwise(element)

        lock.leave()
    }

    public func dequeue(match: @escaping (T) -> Bool, handle: @escaping (T) -> ())
    {
        self.addFilter(match: match, handle: handle)
    }

    public func addFilter(match: @escaping (T) -> Bool, handle: @escaping (T) -> ())
    {
        let filter = Filter(match: match, handle: handle)
        self.addFilter(filter)
    }

    public func addFilter(_ filter: Filter<T>)
    {
        lock.enter()

        self.filters.append(filter)

        lock.leave()
    }
}

public struct Filter<T>
{
    let match: (T) -> Bool
    let handle: (T) -> ()

    public init(match: @escaping (T) -> Bool, handle: @escaping (T) -> ())
    {
        self.match = match
        self.handle = handle
    }
}
