//
//  ConcurrencyTester.swift
//
//
//  Created by Dr. Brandon Wiley on 2/6/24.
//

import Foundation

public class ConcurrencyTester
{
    let lock = DispatchSemaphore(value: 0)

    public init()
    {
    }

    public func test() -> Bool
    {
        Task
        {
            self.lock.signal()
        }

        let result = self.lock.wait(timeout: .now().advanced(by: .seconds(1)))
        switch result
        {
            case .success:
                return true

            case .timedOut:
                return false
        }
    }
}
