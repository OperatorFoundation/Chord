////
////  ThreadSafeSet.swift
////
////
////  Created by Dr. Brandon Wiley on 3/8/23.
////
//
//import Foundation
//
//public class ThreadSafeSet<T> where T: Hashable
//{
//    public typealias Element = T
//
//    static func == (lhs: ThreadSafeSet<Element>, rhs: ThreadSafeSet<Element>) -> Bool
//    {
//        return lhs.set == rhs.set
//    }
//
//    public var set: Set<T>
//    let lock = DispatchSemaphore(value: 1)
//
//    public var array: [Element]
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return [T](self.set)
//    }
//
//    var isEmpty: Bool
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.isEmpty
//    }
//
//    var count: Int
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.count
//    }
//
//    var capacity: Int
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.capacity
//    }
//
//    public init(set: Set<Element>)
//    {
//        self.set = set
//    }
//
//    public init()
//    {
//        self.set = Set<Element>()
//    }
//
//    public init(minimumCapacity: Int)
//    {
//        self.set = Set<Element>(minimumCapacity: minimumCapacity)
//    }
//
//    public init<S>(_ sequence: S) where S: Sequence, Element == S.Element
//    {
//        self.set = Set<Element>(sequence)
//    }
//
//    public func contains(_ member: Element) -> Bool
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.contains(member)
//    }
//
//    @discardableResult public func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.insert(newMember)
//    }
//
//    @discardableResult public func update(with newMember: Element) -> Element?
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.update(with: newMember)
//    }
//
//    public func reserveCapacity(_ minimumCapacity: Int)
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        self.reserveCapacity(minimumCapacity)
//    }
//
//    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Set<Element>
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return try self.filter(isIncluded)
//    }
//
//    @discardableResult public func remove(_ member: Element) -> Element?
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.remove(member)
//    }
//
//    @discardableResult public func removeFirst() -> Element
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.removeFirst()
//    }
//
//    @discardableResult public func remove(at position: Set<Element>.Index) -> Element
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.remove(at: position)
//    }
//
//    public func removeAll(keepingCapacity keepCapacity: Bool = false)
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        self.set.removeAll(keepingCapacity: keepCapacity)
//    }
//
//    public func union<S>(_ other: S) -> Set<Element> where Element == S.Element, S: Sequence
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.union(other)
//    }
//
//    public func formUnion<S>(_ other: S) where Element == S.Element, S : Sequence
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.formUnion(other)
//    }
//
//    public func intersection(_ other: Set<Element>) -> Set<Element>
//    {
//        defer
//        {
//            self.lock.signal()
//        }
//        self.lock.wait()
//
//        return self.set.intersection(other)
//    }
//
//    func intersection<S>(_ other: S) -> Set<Element> where Element == S.Element, S : Sequence
//    mutating func formIntersection<S>(_ other: S) where Element == S.Element, S : Sequence
//    func symmetricDifference<S>(_ other: S) -> Set<Element> where Element == S.Element, S : Sequence
//    func symmetricDifference<S>(_ other: S) -> Set<Element> where Element == S.Element, S : Sequence
//    mutating func formSymmetricDifference(_ other: Set<Element>)
//    mutating func formSymmetricDifference<S>(_ other: S) where Element == S.Element, S : Sequence
//    mutating func subtract(_ other: Set<Element>)
//    mutating func subtract<S>(_ other: S) where Element == S.Element, S : Sequence
//    func subtracting(_ other: Set<Element>) -> Set<Element>
//    func subtracting<S>(_ other: S) -> Set<Element> where Element == S.Element, S : Sequence
//
//}
