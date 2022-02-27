import Foundation
   
public class InvertedLockedCounter
{
    // Locks the InvertedLockCounter until the counter reaches zero
    var outerLock: DispatchGroup

    // Locks the internal counter variable
    var innerLock: DispatchGroup
    var counter: UInt

    public init()
    {
        self.outerLock = DispatchGroup()
        self.innerLock = DispatchGroup()
        self.counter = 0
        
        self.outerLock.enter()
    }
    
    public func increment()
    {
        self.innerLock.enter()
      
        if self.counter == 0
        {
            self.outerLock.leave()
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
            self.outerLock.enter()
        }
        
        self.innerLock.leave()
    }
    
    public func wait()
    {
        self.innerLock.enter()
        
        let count = self.counter
        
        self.innerLock.leave()
        
        if count > 0
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
        
        if count > 0
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
        
        if count > 0
        {
            return DispatchTimeoutResult.success
        }
        else
        {
            return self.outerLock.wait(wallTimeout: wallTimeout)
        }
    }
}

extension InvertedLockedCounter: CustomStringConvertible
{
    public var description: String
    {
        return "InvertedLockedCounter: \(self.counter)"
    }
}
