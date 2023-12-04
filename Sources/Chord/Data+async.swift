//
//  Data+async.swift
//
//
//  Created by Dr. Brandon Wiley on 12/4/23.
//

import Foundation

extension Data
{
    init(contentsOf url: URL) async throws
    {
        let result: Data = try await withCheckedThrowingContinuation
        {
            continuation in

            do
            {
                let data = try Data(contentsOf: url)
                continuation.resume(returning: data)
            }
            catch(let error)
            {
                continuation.resume(throwing: error)
            }
        }

        self = result
    }
}
