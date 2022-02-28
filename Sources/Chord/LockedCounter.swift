import Foundation

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

    // Wait for count = 0
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
    
    // Wait for count = 0
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
    
    // Wait for count = 0
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
