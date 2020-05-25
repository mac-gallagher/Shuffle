///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

import Nimble
import Quick
import Shuffle
import UIKit

// swiftlint:disable function_body_length implicitly_unwrapped_optional
class CardAnimationOptionsSpec: QuickSpec {

  override func spec() {
    var subject: CardAnimationOptions!

    // MARK: - Initialization

    describe("When initializing a CardAnimationOptions object") {
      beforeEach {
        subject = CardAnimationOptions()
      }

      it("should have the correct default properties") {
        expect(subject.maximumRotationAngle) == CGFloat.pi / 10
        expect(subject.relativeSwipeOverlayFadeDuration) == 0.15
        expect(subject.relativeReverseSwipeOverlayFadeDuration) == 0.15
        expect(subject.resetSpringDamping) == 0.5
        expect(subject.totalResetDuration) == 0.6
        expect(subject.totalReverseSwipeDuration) == 0.25
        expect(subject.totalSwipeDuration) == 0.7
      }
    }

    // MARK: - Maximum Rotation Angle

    describe("When setting maximumRotationAngle") {
      context("to a value less than -.pi/2") {
        beforeEach {
          subject = CardAnimationOptions(maximumRotationAngle: -.pi)
        }

        it("should return -.pi/2") {
          expect(subject.maximumRotationAngle) == -.pi / 2
        }
      }

      context("to a value greater than .pi/2") {
        beforeEach {
          subject = CardAnimationOptions(maximumRotationAngle: .pi)
        }

        it("should return CGFloat.pi/2") {
          expect(subject.maximumRotationAngle) == .pi / 2
        }
      }
    }

    // MARK: - Relative Swipe Overlay Fade Duration

    describe("When setting relativeSwipeOverlayFadeDuration") {
      context("to a value less than zero") {
        beforeEach {
          subject = CardAnimationOptions(relativeSwipeOverlayFadeDuration: -0.5)
        }

        it("should return zero") {
          expect(subject.relativeSwipeOverlayFadeDuration) == 0
        }
      }

      context("to a value greater than 1") {
        beforeEach {
          subject = CardAnimationOptions(relativeSwipeOverlayFadeDuration: 1.5)
        }

        it("should return 1") {
          expect(subject.relativeSwipeOverlayFadeDuration) == 1
        }
      }
    }

    // MARK: - Relative Reverse Swipe Overlay Fade Duration

    describe("When setting relativeReverseSwipeOverlayFadeDuration") {
      context("to a value less than zero") {
        beforeEach {
          subject = CardAnimationOptions(relativeReverseSwipeOverlayFadeDuration: -0.5)
        }

        it("should return zero") {
          expect(subject.relativeReverseSwipeOverlayFadeDuration) == 0
        }
      }

      context("to a value greater than 1") {
        beforeEach {
          subject = CardAnimationOptions(relativeReverseSwipeOverlayFadeDuration: 1.5)
        }

        it("should return 1") {
          expect(subject.relativeReverseSwipeOverlayFadeDuration) == 1
        }
      }
    }

    // MARK: - Reset Spring Damping

    describe("When setting resetSpringDamping") {
      context("to a value less than zero") {
        beforeEach {
          subject = CardAnimationOptions(resetSpringDamping: -0.5)
        }

        it("should return zero") {
          expect(subject.resetSpringDamping) == 0
        }
      }

      context("to a value greater than 1") {
        beforeEach {
          subject = CardAnimationOptions(resetSpringDamping: 1.5)
        }

        it("should return 1") {
          expect(subject.resetSpringDamping) == 1
        }
      }
    }

    // MARK: - Total Reset Duration

    describe("When setting totalResetDuration to a value less than or equal to zero") {
      beforeEach {
        subject = CardAnimationOptions(totalResetDuration: 0)
      }

      it("should return zero") {
        expect(subject.totalResetDuration) == 0
      }
    }

    // MARK: - Total Reverse Swipe Duration

    describe("When setting totalReverseSwipeDuration to a value less than or equal to zero") {
      beforeEach {
        subject = CardAnimationOptions(totalReverseSwipeDuration: 0)
      }

      it("should return zero") {
        expect(subject.totalReverseSwipeDuration) == 0
      }
    }

    // MARK: - Total Swipe Duration

    describe("When setting totalSwipeDuration to a value less than or equal to zero") {
      beforeEach {
        subject = CardAnimationOptions(totalSwipeDuration: 0)
      }

      it("should return zero") {
        expect(subject.totalSwipeDuration) == 0
      }
    }
  }
}
// swiftlint:enable function_body_length implicitly_unwrapped_optional
