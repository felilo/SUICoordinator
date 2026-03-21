//
//  SheetDismissalUITests.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest

final class SheetDismissalUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    /// Waits for an element to exist and be hittable, then taps it.
    @discardableResult
    private func tap(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        guard element.waitForExistence(timeout: timeout) else { return false }
        element.tap()
        return true
    }

    /// Swipes the frontmost sheet downward to dismiss it via gesture.
    private func swipeToDismissSheet() {
        // Drag from the top-center of the screen downward far enough to trigger
        // the system sheet dismiss gesture.
        let screen = app.windows.firstMatch.frame
        let start = CGPoint(x: screen.midX, y: screen.minY + 80)
        let end   = CGPoint(x: screen.midX, y: screen.maxY - 80)
        app.swipeDown()
        // Give SwiftUI time to fire the onDismiss callback.
        _ = XCTWaiter.wait(for: [XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "TRUEPREDICATE"), object: nil)],
            timeout: 0.8)
    }

    // MARK: - Tests

    /// Regression test for "close button frozen after swipe-dismiss" bug.
    ///
    /// Steps to reproduce (before fix):
    ///   App launch → Push NavigationView → Presents SheetView →
    ///   Presents SheetView (second) → swipe-dismiss top sheet →
    ///   tap "Close View" on the remaining sheet → must dismiss.
    func test_closeButton_worksAfterSwipeDismissOfUpperSheet() throws {
        // 1. Navigate to the push view from the home action list.
        let pushBtn = app.buttons["btn_pushNavigationView"]
        XCTAssertTrue(pushBtn.waitForExistence(timeout: 5), "Push NavigationView button not found")
        pushBtn.tap()

        // 2. Present the first sheet.
        let sheetBtn = app.buttons["btn_presentsSheetView"]
        XCTAssertTrue(sheetBtn.waitForExistence(timeout: 5), "Presents SheetView button not found")
        sheetBtn.tap()

        // Wait for the first sheet to be visible (it also has btn_presentsSheetView).
        sleep(1)

        // 3. Present a second sheet on top of the first.
        let sheetBtn2 = app.buttons["btn_presentsSheetView"]
        XCTAssertTrue(sheetBtn2.waitForExistence(timeout: 5), "Second Presents SheetView button not found")
        sheetBtn2.tap()

        sleep(1)

        // 4. Swipe-dismiss the top (second) sheet.
        swipeToDismissSheet()

        // Allow SwiftUI onDismiss and the queued removal to complete.
        sleep(2)

        // 5. The "Close View" button on the first sheet must be reachable and tappable.
        let closeBtn = app.buttons["btn_closeView"]
        XCTAssertTrue(
            closeBtn.waitForExistence(timeout: 5),
            "Close View button not found — the first sheet may have frozen or been removed unexpectedly"
        )

        closeBtn.tap()

        // 6. After tapping Close, the first sheet must be gone.
        // Verify by checking that the close button disappears (sheet dismissed).
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: closeBtn)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Close View button still visible — sheet was not dismissed after tapping close")
    }
}
