import XCTest
@testable import TikTokCleaner

final class CleanupEngineTests: XCTestCase {
    
    func testCleanupSummaryCalculations() {
        let start = Date()
        let end = start.addingTimeInterval(120) // 2 minutes
        let failedTask = CleanupTask(
            item: CleanableItem(id: "99", category: .likes, title: "Failed", timestamp: Date()),
            status: .failed,
            attempts: 3,
            lastError: .rateLimited(retryAfterSeconds: 30)
        )
        
        let summary = CleanupSummary(
            totalPlanned: 100,
            successfulCount: 95,
            failedCount: 5,
            skippedCount: 0,
            startedAt: start,
            finishedAt: end,
            failedTasks: [failedTask]
        )
        
        XCTAssertEqual(summary.durationSeconds, 120)
        XCTAssertEqual(summary.successRate, 0.95)
        XCTAssertEqual(summary.formattedSuccessRate, "95%")
        XCTAssertEqual(summary.failedTasks.count, 1)
    }
    
    func testCircuitBreakerTripsAfterThreshold() async {
        let breaker = CircuitBreaker(failureThreshold: 3)
        
        let tripped1 = await breaker.recordFailure()
        XCTAssertFalse(tripped1)
        
        let tripped2 = await breaker.recordFailure()
        XCTAssertFalse(tripped2)
        
        let tripped3 = await breaker.recordFailure()
        XCTAssertTrue(tripped3) // Seuil atteint, le coupe-circuit s'ouvre
    }
}
