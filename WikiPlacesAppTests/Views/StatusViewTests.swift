//
//  StatusViewTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 29/08/26.
//

import XCTest
import SwiftUI
import UIKit
@testable import WikiPlacesApp

final class StatusViewTests: XCTestCase {

    // MARK: - ErrorStateView — Instantiation

    func testErrorStateView_CanBeInstantiated() {
        let view = ErrorStateView(message: "Something failed") {}
        XCTAssertNotNil(view)
    }

    func testErrorStateView_StoresMessage() {
        let view = ErrorStateView(message: "Network error") {}
        XCTAssertEqual(view.message, "Network error")
    }

    func testErrorStateView_EmptyMessage_IsValid() {
        let view = ErrorStateView(message: "") {}
        XCTAssertEqual(view.message, "")
    }

    func testErrorStateView_LongMessage_IsPreserved() {
        let long = String(repeating: "error ", count: 50)
        let view = ErrorStateView(message: long) {}
        XCTAssertEqual(view.message, long)
    }

    // MARK: - ErrorStateView — Retry callback

    func testErrorStateView_RetryCallback_IsInvokedOnce() {
        var callCount = 0
        let view = ErrorStateView(message: "Error") { callCount += 1 }
        view.retry()
        XCTAssertEqual(callCount, 1)
    }

    func testErrorStateView_RetryCallback_IsNotInvokedBeforeCalling() {
        var callCount = 0
        _ = ErrorStateView(message: "Error") { callCount += 1 }
        XCTAssertEqual(callCount, 0)
    }

    func testErrorStateView_RetryCallback_IsInvokedMultipleTimes() {
        var callCount = 0
        let view = ErrorStateView(message: "Error") { callCount += 1 }
        view.retry()
        view.retry()
        view.retry()
        XCTAssertEqual(callCount, 3)
    }

    func testErrorStateView_RetryCallback_CapturesExternalState() {
        var triggered = false
        let view = ErrorStateView(message: "Error") { triggered = true }
        XCTAssertFalse(triggered)
        view.retry()
        XCTAssertTrue(triggered)
    }

    func testErrorStateView_RetryCallback_CanMutateExternalArray() {
        var log: [Int] = []
        let view = ErrorStateView(message: "Error") { log.append(log.count) }
        view.retry()
        view.retry()
        XCTAssertEqual(log, [0, 1])
    }

    // MARK: - ErrorStateView — Two independent instances

    func testErrorStateView_TwoInstances_HaveIndependentCallbacks() {
        var count1 = 0, count2 = 0
        let view1 = ErrorStateView(message: "Error A") { count1 += 1 }
        let view2 = ErrorStateView(message: "Error B") { count2 += 1 }
        view1.retry()
        XCTAssertEqual(count1, 1)
        XCTAssertEqual(count2, 0)
    }

    func testErrorStateView_TwoInstances_MessagesAreIndependent() {
        let view1 = ErrorStateView(message: "Timeout") {}
        let view2 = ErrorStateView(message: "Not found") {}
        XCTAssertNotEqual(view1.message, view2.message)
    }

    // MARK: - ErrorStateView — Rendering

    @MainActor
    func testErrorStateView_RendersWithoutCrash() {
        let view = ErrorStateView(message: "Failed to load") {}
        let host = UIHostingController(rootView: view)
        host.loadView()
        XCTAssertNotNil(host.view)
    }

    @MainActor
    func testErrorStateView_EmptyMessage_RendersWithoutCrash() {
        let view = ErrorStateView(message: "") {}
        let host = UIHostingController(rootView: view)
        host.loadView()
        XCTAssertNotNil(host.view)
    }

    // MARK: - EmptyLocationsView — Instantiation

    func testEmptyLocationsView_CanBeInstantiated() {
        let view = EmptyLocationsView {}
        XCTAssertNotNil(view)
    }

    // MARK: - EmptyLocationsView — Retry callback

    func testEmptyLocationsView_RetryCallback_IsInvokedOnce() {
        var callCount = 0
        let view = EmptyLocationsView { callCount += 1 }
        view.retry()
        XCTAssertEqual(callCount, 1)
    }

    func testEmptyLocationsView_RetryCallback_IsNotInvokedBeforeCalling() {
        var callCount = 0
        _ = EmptyLocationsView { callCount += 1 }
        XCTAssertEqual(callCount, 0)
    }

    func testEmptyLocationsView_RetryCallback_IsInvokedMultipleTimes() {
        var callCount = 0
        let view = EmptyLocationsView { callCount += 1 }
        view.retry()
        view.retry()
        view.retry()
        XCTAssertEqual(callCount, 3)
    }

    func testEmptyLocationsView_RetryCallback_CapturesExternalState() {
        var triggered = false
        let view = EmptyLocationsView { triggered = true }
        XCTAssertFalse(triggered)
        view.retry()
        XCTAssertTrue(triggered)
    }

    func testEmptyLocationsView_RetryCallback_CanMutateExternalArray() {
        var log: [String] = []
        let view = EmptyLocationsView { log.append("refresh") }
        view.retry()
        view.retry()
        XCTAssertEqual(log, ["refresh", "refresh"])
    }

    // MARK: - EmptyLocationsView — Two independent instances

    func testEmptyLocationsView_TwoInstances_HaveIndependentCallbacks() {
        var count1 = 0, count2 = 0
        let view1 = EmptyLocationsView { count1 += 1 }
        let view2 = EmptyLocationsView { count2 += 1 }
        view2.retry()
        XCTAssertEqual(count1, 0)
        XCTAssertEqual(count2, 1)
    }

    // MARK: - EmptyLocationsView — Rendering

    @MainActor
    func testEmptyLocationsView_RendersWithoutCrash() {
        let view = EmptyLocationsView {}
        let host = UIHostingController(rootView: view)
        host.loadView()
        XCTAssertNotNil(host.view)
    }

    // MARK: - Cross-type independence

    func testErrorStateAndEmptyLocationsView_CallbacksAreIndependent() {
        var errorCount = 0, emptyCount = 0
        let errorView = ErrorStateView(message: "Error") { errorCount += 1 }
        let emptyView = EmptyLocationsView { emptyCount += 1 }
        errorView.retry()
        errorView.retry()
        emptyView.retry()
        XCTAssertEqual(errorCount, 2)
        XCTAssertEqual(emptyCount, 1)
    }
}
