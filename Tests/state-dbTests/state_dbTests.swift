import XCTest
@testable import state_db

final class state_dbTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(state_db().text, "Hello, World!")
    }
}
