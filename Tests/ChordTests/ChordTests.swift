@preconcurrency import XCTest
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
}
