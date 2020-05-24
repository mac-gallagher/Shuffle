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
@testable import Shuffle
import UIKit

// swiftlint:disable implicitly_unwrapped_optional
class CardStackAnimationOptionsSpec: QuickSpec {

  override func spec() {
    var subject: CardStackAnimationOptions!

    // MARK: - Initialization

    describe("When initializing a CardStackAnimationOptions object") {
      beforeEach {
        subject = CardStackAnimationOptions()
      }

      it("should have the correct default properties") {
        expect(subject.resetDuration).to(beNil())
        expect(subject.shiftDuration) == 0.1
        expect(subject.swipeDuration).to(beNil())
        expect(subject.undoDuration).to(beNil())
      }
    }

    // MARK: - Reset Duration

    describe("When setting resetDuration to a value less than zero") {
      beforeEach {
        subject = CardStackAnimationOptions(resetDuration: -0.5)
      }

      it("should return zero") {
        expect(subject.resetDuration) == 0
      }
    }

    // MARK: - Shift Duration

    describe("When setting maximumRotationAngle to a value less than zero") {
      beforeEach {
        subject = CardStackAnimationOptions(shiftDuration: -0.5)
      }

      it("should return zero") {
        expect(subject.shiftDuration) == 0
      }
    }

    // MARK: - Swipe Duration

    describe("When setting swipeDuration to a value less than zero") {
      beforeEach {
        subject = CardStackAnimationOptions(swipeDuration: -0.5)
      }

      it("should return zero") {
        expect(subject.swipeDuration) == 0
      }
    }

    // MARK: - Undo Duration

    describe("When setting undoDuration to a value less than zero") {
      beforeEach {
        subject = CardStackAnimationOptions(undoDuration: -0.5)
      }

      it("should return zero") {
        expect(subject.undoDuration) == 0
      }
    }
  }
}
// swiftlint:enable implicitly_unwrapped_optional
