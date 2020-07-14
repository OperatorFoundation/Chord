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
}
