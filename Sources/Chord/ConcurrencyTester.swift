//
//  ConcurrencyTester.swift
//
//
//  Created by Dr. Brandon Wiley on 2/6/24.
//

import Foundation

public class ConcurrencyTester
{
    static func test(_ logline: String? = nil) throws
    {
        let tester = ConcurrencyTester()
        guard tester.test() else
        {
            if let logline
            {
                print(logline)
            }

            throw ConcurrencyTesterError.concurrencyIsBroken
        }
    }

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

        let result = self.lock.wait(timeout: .now() + DispatchTimeInterval.seconds(1))
        switch result
        {
            case .success:
                return true

            case .timedOut:
                return false
        }
    }
}

public enum ConcurrencyTesterError: Error
{
    case concurrencyIsBroken
}
