//
//  ConcurrencyTester.swift
//
//
//  Created by Dr. Brandon Wiley on 2/6/24.
//

import Foundation

public class ConcurrencyTester
{
    static public func test(_ logline: String? = nil) throws
    {
        let tester = ConcurrencyTester()
        let working = tester.test()

        guard working else
        {
            if let logline
            {
                print(logline)
            }

            print("⚠️ Concurrency is broken.")

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
            try await Task.sleep(for: Duration.seconds(1))
            self.lock.signal()
        }

        let result = self.lock.wait(timeout: .now() + DispatchTimeInterval.seconds(2))
        switch result
        {
            // Concurrency is working
            case .success:
                return true

            // Concurrency is broken
            case .timedOut:
                return false
        }
    }
}

public enum ConcurrencyTesterError: Error
{
    case concurrencyIsBroken
}
