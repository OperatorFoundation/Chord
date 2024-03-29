import Foundation
import XCTest

@testable import Chord
import Datable

final class ChordTests: XCTestCase {
    func testMap()
    {
        let correct = [2, 3, 4]
        
        let input = [1, 2, 3]
        
        let result = input.parallelMap
        {
            item -> Int in
            
            return item + 1
        }
                
        XCTAssertEqual(result, correct)
    }
    
    func testMap2()
    {
        let correct = ["1", "2", "3"]
        
        let input = [1, 2, 3]
        
        let result = input.parallelMap
        {
            item -> String in
            
            return item.string
        }
                
        XCTAssertEqual(result, correct)
    }
    
    func testReduce()
    {
        let correct = 6
        
        let input = [1, 2, 3]
        
        let result = input.parallelReduce(initialValue: 0)
        {
            (a, b) -> Int in
            
            return a + b
        }
                
        XCTAssertEqual(result, correct)
    }
    
    @available(macOS 12.0.0, *)
    func testBlockingQueue() async
    {
        let correct = 1
        let dequeued = expectation(description: "dequeued element")
        
        let queue = BlockingQueue<Int>()
        
        Task
        {
            let result = queue.dequeue()
            
            if result == correct
            {
                dequeued.fulfill()
            }
        }
                
        queue.enqueue(element: 1)
        
        wait(for: [dequeued], timeout: 30)
    }
    
    func testRepeatingTask()
    {
        let repeatingTask = RepeatingTask
        {
            let randomInt = Int.random(in: 0..<10)
            print(randomInt)
            sleep(2)
            // Keep running until we get a 5 or cancel is called
            return randomInt != 5
        }
        
        sleep(5)
        repeatingTask.cancel()
        repeatingTask.wait()
    }

    typealias URLSessionResult = (Data?, URLResponse?, (any Error)?)

    func testURLSession()
    {
        let session = URLSession.shared
        let url = URL(string: "https://google.com/")!
        let request = URLRequest(url: url)
        session.dataTask(with: request)
        {
            maybeData, maybeResponse, maybeError in

            return
        }

        let result: URLSessionResult = Synchronizer.sync<URLSessionResult>
        {
            callback in

            let task = session.dataTask(with: request)
            {
                maybeData, maybeResponse, maybeError in

                let result = (maybeData, maybeResponse, maybeError)
                callback(result)
            }
            task.resume()
        }

        print(result)
    }

    func testAsyncQueue() async
    {
        let dequeued = expectation(description: "dequeued")

        let queue: AsyncQueue<Int> = AsyncQueue<Int>()

        Task
        {
            await queue.enqueue(element: 4)
        }

        Task
        {
            let value = await queue.dequeue()
            XCTAssertEqual(value, 4)
            dequeued.fulfill()
        }

        await fulfillment(of: [dequeued], timeout: 5) // 5 seconds
    }

    func testConcurrencyTesterWorking() async
    {
        let tester = ConcurrencyTester()
        guard tester.test() else
        {
            XCTFail()
            return
        }
    }

    func testConcurrencyTesterNotWorking() async throws
    {
        Task
        {
            while true
            {
                try await Task.sleep(for: Duration.seconds(1))
            }
        }

        try await Task.sleep(for: Duration.seconds(1))

        let tester = ConcurrencyTester()
        if tester.test()
        {
            XCTFail()
            return
        }
    }

    func testAsyncTimer() throws
    {
        let lock = DispatchSemaphore(value: 0)

        Task
        {
            let timer = await AsyncTimer.scheduledTimer(withTimeInterval: 10, repeats: false)
            {
                timer in

                lock.signal()
            }
        }

        lock.wait()
    }
}
