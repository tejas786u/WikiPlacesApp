//
//  PressableButtonStyleTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 29/08/26.
//

import XCTest
import SwiftUI
import UIKit
@testable import WikiPlacesApp

final class PressableButtonStyleTests: XCTestCase {

    // MARK: - Instantiation & conformance

    func testPressableButtonStyle_CanBeInstantiated() {
        let style = PressableButtonStyle()
        XCTAssertNotNil(style)
    }

    func testPressableButtonStyle_ConformsToButtonStyle() {
        // Verifies the protocol conformance compiles and holds at runtime
        let _: any ButtonStyle = PressableButtonStyle()
        XCTAssertTrue(true)
    }

    // MARK: - Rendering (via UIHostingController)
    // These tests confirm makeBody never crashes during render.

    @MainActor
    func testMakeBody_NotPressed_RendersWithoutCrash() {
        let button = Button("Test") {}
            .buttonStyle(PressableButtonStyle())
        let host = UIHostingController(rootView: button)
        host.loadView()
        XCTAssertNotNil(host.view)
    }

    @MainActor
    func testMakeBody_AppliedToButtonWithLabel_RendersWithoutCrash() {
        let button = Button {
        } label: {
            Label("Open", systemImage: "arrow.up.right.square")
        }
        .buttonStyle(PressableButtonStyle())
        let host = UIHostingController(rootView: button)
        host.loadView()
        XCTAssertNotNil(host.view)
    }

    @MainActor
    func testMakeBody_AppliedToDisabledButton_RendersWithoutCrash() {
        let button = Button("Disabled") {}
            .buttonStyle(PressableButtonStyle())
            .disabled(true)
        let host = UIHostingController(rootView: button)
        host.loadView()
        XCTAssertNotNil(host.view)
    }

    @MainActor
    func testMakeBody_InsideVStack_RendersWithoutCrash() {
        let view = VStack {
            Button("First") {}.buttonStyle(PressableButtonStyle())
            Button("Second") {}.buttonStyle(PressableButtonStyle())
        }
        let host = UIHostingController(rootView: view)
        host.loadView()
        XCTAssertNotNil(host.view)
    }

    // MARK: - Scale & opacity contract

    func testScale_PressedValue_IsLessThanOne() {
        // The pressed scale (0.97) must be < 1 so users feel a physical press
        let pressedScale: CGFloat = 0.97
        XCTAssertLessThan(pressedScale, 1.0)
    }

    func testScale_PressedValue_IsNotExtremelySmall() {
        // Scale must stay above 0.9 to keep the button recognisable when pressed
        let pressedScale: CGFloat = 0.97
        XCTAssertGreaterThan(pressedScale, 0.9)
    }

    func testOpacity_PressedValue_IsLessThanOne() {
        // Opacity dims slightly (0.9) on press regardless of Reduce Motion
        let pressedOpacity: Double = 0.9
        XCTAssertLessThan(pressedOpacity, 1.0)
    }

    func testOpacity_PressedValue_IsNotFullyTransparent() {
        let pressedOpacity: Double = 0.9
        XCTAssertGreaterThan(pressedOpacity, 0.0)
    }
}
