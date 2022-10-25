//
//  MultiQueue.swift
//  
//
//  Created by Dr. Brandon Wiley on 10/25/22.
//

import Foundation

public class MultiQueue<Product>
{
    let lock = DispatchSemaphore(value: 0)
    let output = BlockingQueue<Product>()
    var producers: [Producer<Product>] = []

    public init()
    {
    }

    public func add(_ producer: Producer<Product>)
    {
        self.producers.append(producer)
    }

    public func remove(_ producer: Producer<Product>)
    {
        self.producers.removeAll {$0 == producer}
    }

    public func dequeue() -> Product
    {
        return self.output.dequeue()
    }
}

open class Producer<Product>
{
    let uuid = UUID()
    let multi: MultiQueue<Product>

    var thread: Thread? = nil
    var running: Bool = true

    public init(multi: MultiQueue<Product>)
    {
        self.multi = multi

        self.thread = Thread
        {
            self.readLoop()
        }
    }

    func readLoop()
    {
        while self.running
        {
            do
            {
                let value = try self.read()

                self.multi.output.enqueue(element: value)
            }
            catch
            {
                self.running = false
            }
        }

        self.multi.remove(self)
        self.cleanup()
    }

    open func read() throws -> Product
    {
        throw MultiQueueError.unimplemented
    }

    open func cleanup()
    {
    }
}

extension Producer: Equatable
{
    public static func == (lhs: Producer<Product>, rhs: Producer<Product>) -> Bool
    {
        return lhs.uuid == rhs.uuid
    }
}

extension Producer: Hashable
{
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.uuid)
    }
}

public enum MultiQueueError: Error
{
    case unimplemented
}
