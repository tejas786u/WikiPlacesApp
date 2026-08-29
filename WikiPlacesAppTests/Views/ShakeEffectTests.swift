//
//  ShakeEffectTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 29/08/26.
//

import XCTest
import SwiftUI
@testable import WikiPlacesApp

// ShakeEffect formula: translation = amount * sin(animatableData * .pi * shakesPerUnit)
// ProjectionTransform from CGAffineTransform maps:  tx → m31,  ty → m32
final class ShakeEffectTests: XCTestCase {

    // MARK: - Default properties

    func testDefaultAmount_IsEight() {
        let effect = ShakeEffect(animatableData: 0)
        XCTAssertEqual(effect.amount, 8)
    }

    func testDefaultShakesPerUnit_IsThree() {
        let effect = ShakeEffect(animatableData: 0)
        XCTAssertEqual(effect.shakesPerUnit, 3)
    }

    func testAnimatableData_StoredCorrectly() {
        let effect = ShakeEffect(animatableData: 0.75)
        XCTAssertEqual(effect.animatableData, 0.75)
    }

    func testAnimatableData_CanBeMutated() {
        var effect = ShakeEffect(animatableData: 0)
        effect.animatableData = 0.5
        XCTAssertEqual(effect.animatableData, 0.5)
    }

    // MARK: - X-translation at key sin values

    func testEffectValue_AtZero_XTranslationIsZero() {
        // sin(0) = 0 → translation = 0
        let effect = ShakeEffect(animatableData: 0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 0, accuracy: 1e-4)
    }

    func testEffectValue_AtSinPeak_XTranslationEqualsAmount() {
        // animatableData = 1/(2*3) → sin(π/2) = 1 → translation = 8
        let effect = ShakeEffect(animatableData: 1.0 / 6.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 8, accuracy: 1e-4)
    }

    func testEffectValue_AtMidCycle_XTranslationIsNearZero() {
        // animatableData = 1/3 → sin(π) ≈ 0
        let effect = ShakeEffect(animatableData: 1.0 / 3.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 0, accuracy: 1e-4)
    }

    func testEffectValue_AtSinTrough_XTranslationIsNegativeAmount() {
        // animatableData = 0.5 → sin(3π/2) = -1 → translation = -8
        let effect = ShakeEffect(animatableData: 0.5)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, -8, accuracy: 1e-4)
    }

    func testEffectValue_AtFullCycle_XTranslationIsNearZero() {
        // animatableData = 1 → sin(3π) ≈ 0
        let effect = ShakeEffect(animatableData: 1.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 0, accuracy: 1e-4)
    }

    func testEffectValue_AtThreeQuarterCycle_XTranslationIsNegativeAmount() {
        // animatableData = 5/6 → sin(5π/2) = 1... wait
        // animatableData=5/6 → 5/6 * π * 3 = 5π/2 → sin(5π/2) = 1 → translation = 8
        let effect = ShakeEffect(animatableData: 5.0 / 6.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 8, accuracy: 1e-4)
    }

    // MARK: - Y-translation is always zero

    func testEffectValue_YTranslation_IsZero_AtRest() {
        let effect = ShakeEffect(animatableData: 0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m32, 0, accuracy: 1e-4)
    }

    func testEffectValue_YTranslation_IsZero_AtPeak() {
        let effect = ShakeEffect(animatableData: 1.0 / 6.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m32, 0, accuracy: 1e-4)
    }

    func testEffectValue_YTranslation_IsZero_AtTrough() {
        let effect = ShakeEffect(animatableData: 0.5)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m32, 0, accuracy: 1e-4)
    }

    // MARK: - Size independence

    func testEffectValue_SmallSize_SameTranslationAsLargeSize() {
        let effect = ShakeEffect(animatableData: 1.0 / 6.0)
        let small = effect.effectValue(size: CGSize(width: 10, height: 10))
        let large = effect.effectValue(size: CGSize(width: 1000, height: 1000))
        XCTAssertEqual(small.m31, large.m31, accuracy: 1e-4)
    }

    func testEffectValue_ZeroSize_DoesNotProduceNaN() {
        let effect = ShakeEffect(animatableData: 0.25)
        let result = effect.effectValue(size: .zero)
        XCTAssertFalse(result.m31.isNaN)
        XCTAssertFalse(result.m32.isNaN)
    }

    // MARK: - Custom amount

    func testEffectValue_DoubledAmount_DoublesTranslation() {
        let effect = ShakeEffect(amount: 16, shakesPerUnit: 3, animatableData: 1.0 / 6.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 16, accuracy: 1e-4)
    }

    func testEffectValue_HalfAmount_HalvesTranslation() {
        let effect = ShakeEffect(amount: 4, shakesPerUnit: 3, animatableData: 1.0 / 6.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 4, accuracy: 1e-4)
    }

    func testEffectValue_ZeroAmount_AlwaysProducesZeroTranslation() {
        let effect = ShakeEffect(amount: 0, shakesPerUnit: 3, animatableData: 1.0 / 6.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 0, accuracy: 1e-4)
    }

    // MARK: - Custom shakesPerUnit

    func testEffectValue_ShakesPerUnitOne_PeakAtHalfCycle() {
        // shakesPerUnit=1 → peak when animatableData * π * 1 = π/2 → animatableData = 0.5
        let effect = ShakeEffect(amount: 8, shakesPerUnit: 1, animatableData: 0.5)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 8, accuracy: 1e-4)
    }

    func testEffectValue_HigherShakesPerUnit_IncreasesFrequency() {
        // With shakesPerUnit=6, peak is at animatableData = 1/12
        let effect = ShakeEffect(amount: 8, shakesPerUnit: 6, animatableData: 1.0 / 12.0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(result.m31, 8, accuracy: 1e-4)
    }

    // MARK: - Symmetry

    func testEffectValue_PositiveAndNegativeAnimatableData_AreSymmetric() {
        // sin(-x) = -sin(x)
        let pos = ShakeEffect(animatableData: 1.0 / 6.0).effectValue(size: CGSize(width: 100, height: 50))
        let neg = ShakeEffect(animatableData: -1.0 / 6.0).effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertEqual(pos.m31, -neg.m31, accuracy: 1e-4)
    }

    // MARK: - animatableData mutation updates translation

    func testAnimatableData_Mutation_ChangesTranslation() {
        var effect = ShakeEffect(animatableData: 0)
        let atZero = effect.effectValue(size: CGSize(width: 100, height: 50)).m31
        effect.animatableData = 1.0 / 6.0
        let atPeak = effect.effectValue(size: CGSize(width: 100, height: 50)).m31
        XCTAssertNotEqual(atZero, atPeak)
    }

    // MARK: - Affine/identity checks

    func testEffectValue_ResultIsAffineTransform() {
        let effect = ShakeEffect(animatableData: 0.25)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertTrue(result.isAffine)
    }

    func testEffectValue_AtZeroAnimatableData_IsIdentity() {
        let effect = ShakeEffect(animatableData: 0)
        let result = effect.effectValue(size: CGSize(width: 100, height: 50))
        XCTAssertTrue(result.isIdentity)
    }
}
