import XCTest
@testable import Swift_Boost_Context

final class Swift_Boost_ContextTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Swift_Boost_Context().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
