//
//  AsyncTimer.swift
//
//
//  Created by Dr. Brandon Wiley on 2/16/24.
//

import Foundation

public class AsyncTimer
{
    public static func scheduledTimer(withTimeInterval timeInterval: TimeInterval, repeats: Bool, block: @escaping (AsyncTimer) async -> Void) async -> AsyncTimer
    {
        return await AsyncTimer(timeInterval: timeInterval, repeats: repeats, block: block)
    }

    public var isValid: Bool
    public var fireDate: Date
    public var timeInterval: TimeInterval

    let repeats: Bool
    let block: (AsyncTimer) async -> Void

    public init(timeInterval: TimeInterval, repeats: Bool, block: @escaping (AsyncTimer) async -> Void) async
    {
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.block = block

        self.isValid = true
        self.fireDate = Date.distantFuture

        Task
        {
            await self.handleTimer()
        }
    }

    public func fire() async
    {
        guard self.isValid else
        {
            return
        }

        await self.block(self)
        self.fireDate = Date() // now
    }

    public func invalidate() async
    {
        self.isValid = false
    }

    func handleTimer() async
    {
        while self.isValid
        {
            do
            {
                try await Task.sleep(for: .seconds(self.timeInterval))

                await self.block(self)

                self.isValid = self.isValid && self.repeats
            }
            catch
            {
                self.isValid = false
            }

            await Task.yield()
        }
    }
}
