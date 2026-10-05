import XCTest
@testable import TikTokCleaner

final class TaskQueueTests: XCTestCase {
    
    func testQueueLoading() {
        let queue = TaskQueue.shared
        let items = [
            CleanableItem(id: "1", category: .likes, title: "Item 1", timestamp: Date()),
            CleanableItem(id: "2", category: .likes, title: "Item 2", timestamp: Date()),
            CleanableItem(id: "3", category: .likes, title: "Item 3", timestamp: Date())
        ]
        
        queue.loadTasks(items: items)
        XCTAssertEqual(queue.tasks.count, 3)
        XCTAssertEqual(queue.state, .idle)
        XCTAssertEqual(queue.completedCount, 0)
        XCTAssertEqual(queue.failedCount, 0)
    }
    
    func testRetryStrategyBackoff() {
        let strategy = RetryStrategy(maxAttempts: 3, initialDelay: 2.0, multiplier: 2.0, maxDelay: 20.0)
        
        XCTAssertEqual(strategy.delay(forAttempt: 1), 2.0)
        XCTAssertEqual(strategy.delay(forAttempt: 2), 4.0)
        XCTAssertEqual(strategy.delay(forAttempt: 3), 8.0)
    }
}
