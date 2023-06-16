//
//  SleepingTimer.swift
//  
//
//  Created by Dr. Brandon Wiley on 3/8/23.
//

import Foundation

public class SleepingTimer
{
    static public func scheduledTimer(withTimeInterval timeInterval: TimeInterval, repeats: Bool, block: @escaping () -> Void) -> SleepingTimer
    {
        return SleepingTimer(withTimeInterval: timeInterval, repeats: repeats, block: block)
    }

    let timeInterval: TimeInterval
    let repeats: Bool
    let block: () -> Void

    var valid: Bool = true

    public init(withTimeInterval timeInterval: TimeInterval, repeats: Bool, block: @escaping () -> Void)
    {
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.block = block
    }

    public func invalidate()
    {
        self.valid = false
    }

    func run()
    {
        Task
        {
            if self.repeats
            {
                while self.valid
                {
                    try await Task.sleep(for: .seconds(self.timeInterval))

                    self.block()
                }
            }
            else
            {
                self.block()
            }
        }
    }
}
