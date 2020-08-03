import Foundation

public class Chord
{
    var queue: DispatchQueue
    var counter: LockedCounter
    
    public init()
    {
        self.counter = LockedCounter()
        self.queue = DispatchQueue(label: "testing", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    }
    
    public func async(_ function: @escaping () -> Void)
    {
        self.counter.increment()
        self.queue.async
        {
            function()
            
            self.counter.decrement()
        }
    }
    
    public func wait()
    {
        self.counter.wait()
    }
}

public class LockedCounter
{
    var outerLock: DispatchGroup
    
    var innerLock: DispatchGroup
    var counter: UInt

    public init()
    {
        self.outerLock = DispatchGroup()
        self.innerLock = DispatchGroup()
        self.counter = 0
    }
    
    public func increment()
    {
        self.innerLock.enter()
        
        if self.counter == 0
        {
            self.outerLock.enter()
        }

        self.counter = self.counter + 1
        
        self.innerLock.leave()
    }
    
    public func decrement()
    {
        self.innerLock.enter()
        
        self.counter = self.counter - 1
        
        if self.counter == 0
        {
            self.outerLock.leave()
        }
        
        self.innerLock.leave()
    }
    
    public func wait()
    {
        self.innerLock.enter()
        
        let count = self.counter
        
        self.innerLock.leave()
        
        if count == 0
        {
            return
        }
        else
        {
            self.outerLock.wait()
        }
    }
    
    public func wait(timeout: DispatchTime) -> DispatchTimeoutResult
    {
        self.innerLock.enter()
        
        let count = self.counter
        
        self.innerLock.leave()
        
        if count == 0
        {
            return DispatchTimeoutResult.success
        }
        else
        {
            return self.outerLock.wait(timeout: timeout)
        }
    }
    
    public func wait(wallTimeout: DispatchWallTime) -> DispatchTimeoutResult
    {
        self.innerLock.enter()
        
        let count = self.counter
        
        self.innerLock.leave()
        
        if count == 0
        {
            return DispatchTimeoutResult.success
        }
        else
        {
            return self.outerLock.wait(wallTimeout: wallTimeout)
        }
    }
}
    
extension LockedCounter: CustomStringConvertible
{
    public var description: String
    {
        return "LockedCounter: \(self.counter)"
    }
}

public extension Array
{
    func parallelMap<Target>(function: @escaping (Element) -> Target) -> [Target]
    {
        var temp: [Target?] = Array<Target?>(repeating: nil, count: self.count)
        let chord = Chord()
                
        for (index, item) in self.enumerated()
        {
            chord.async
            {
                let result = function(item)
                temp[index] = result
            }
        }
        
        chord.wait()
        
        let results = unwrap(input: temp)
        
        return results
    }
    
    func parallelReduce(initialValue: Element, function: @escaping (Element, Element) -> Element) -> Element
    {
        var odd = self.count % 2 != 0
        
        // If there are an odd number of values, reduce one now for convenience.
        var startingValue = odd ? function(initialValue, self[self.count-1]) : initialValue
        
        let tempSize = self.count / 2
        var temp: [Element] = Array<Element>(repeating: initialValue, count: tempSize)
        var end = tempSize

        let chord = Chord()
        var firstPass = true
        while end > 0
        {
            for index in 0..<end
            {
                chord.async
                {
                    let indexA = index * 2
                    let indexB = indexA + 1
                    let indexC = index

                    let valueA = firstPass ? self[indexA] : temp[indexA]
                    let valueB = firstPass ? self[indexB] : temp[indexB]
                    let valueC = function(valueA, valueB)
                    
                    temp[indexC] = valueC
                }
            }
            
            chord.wait()
            firstPass = false
            
            end = end / 2
            odd = end % 2 != 0
            if odd
            {
                startingValue = function(startingValue, temp[end])
                end = end - 1
            }
        }
        
        return function(temp[end], startingValue)
    }
}

func unwrap<Target>(input: [Target?]) -> [Target]
{
    var results: [Target] = []
    
    for maybeItem in input
    {
        guard let item = maybeItem else {continue}
        results.append(item)
    }
    
    return results
}
