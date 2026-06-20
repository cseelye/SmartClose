import XCTest
import ApplicationServices
@testable import SmartClose

final class WindowClassifierTests: XCTestCase {
    func testCountsNormalWindow() {
        let classifier = WindowClassifier()
        let window = WindowInfo(
            role: kAXWindowRole as String,
            subrole: kAXStandardWindowSubrole as String,
            isMinimized: false,
            isVisible: true,
            title: "Main"
        )
        let settings = Settings.default
        let result = classifier.classify(windows: [window], appIsHidden: false, settings: settings)
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result.ambiguous)
    }

    func testIgnoresMinimizedWhenConfigured() {
        let classifier = WindowClassifier()
        let window = WindowInfo(
            role: kAXWindowRole as String,
            subrole: kAXStandardWindowSubrole as String,
            isMinimized: true,
            isVisible: true,
            title: "Main"
        )
        var settings = Settings.default
        settings.countMinimizedWindows = false
        let result = classifier.classify(windows: [window], appIsHidden: false, settings: settings)
        XCTAssertEqual(result.count, 0)
        XCTAssertFalse(result.ambiguous)
    }

    func testMissingVisibilityStillCountsVisibleStandardWindow() {
        let classifier = WindowClassifier()
        let window = WindowInfo(
            role: kAXWindowRole as String,
            subrole: kAXStandardWindowSubrole as String,
            isMinimized: false,
            isVisible: nil,
            title: "Main"
        )
        let settings = Settings.default
        let result = classifier.classify(windows: [window], appIsHidden: false, settings: settings)
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result.ambiguous)
    }

    func testUnknownSubroleIsAmbiguous() {
        let classifier = WindowClassifier()
        let window = WindowInfo(
            role: kAXWindowRole as String,
            subrole: "AXUnknown",
            isMinimized: false,
            isVisible: true,
            title: "Main"
        )
        let settings = Settings.default
        let result = classifier.classify(windows: [window], appIsHidden: false, settings: settings)
        XCTAssertTrue(result.ambiguous)
    }

    // MARK: - isStandardWindow (issue #6: closing an auxiliary window must not quit)

    func testIsStandardWindowTrueForStandardWindow() {
        let classifier = WindowClassifier()
        XCTAssertTrue(classifier.isStandardWindow(role: kAXWindowRole as String, subrole: kAXStandardWindowSubrole as String))
    }

    func testIsStandardWindowFalseForAuxiliaryWindows() {
        let classifier = WindowClassifier()
        XCTAssertFalse(classifier.isStandardWindow(role: kAXWindowRole as String, subrole: kAXDialogSubrole as String))
        XCTAssertFalse(classifier.isStandardWindow(role: kAXWindowRole as String, subrole: kAXFloatingWindowSubrole as String))
        XCTAssertFalse(classifier.isStandardWindow(role: kAXWindowRole as String, subrole: kAXSystemDialogSubrole as String))
        XCTAssertFalse(classifier.isStandardWindow(role: kAXWindowRole as String, subrole: "AXUnknown"))
    }

    func testIsStandardWindowFalseForMissingOrNonWindowRole() {
        let classifier = WindowClassifier()
        XCTAssertFalse(classifier.isStandardWindow(role: nil, subrole: kAXStandardWindowSubrole as String))
        XCTAssertFalse(classifier.isStandardWindow(role: kAXWindowRole as String, subrole: nil))
        XCTAssertFalse(classifier.isStandardWindow(role: "AXButton", subrole: kAXStandardWindowSubrole as String))
    }
}
