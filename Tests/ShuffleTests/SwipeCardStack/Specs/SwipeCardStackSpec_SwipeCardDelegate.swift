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

// swiftlint:disable function_body_length implicitly_unwrapped_optional
class SwipeCardStackSpec_SwipeCardDelegate: QuickSpec {

  override func spec() {
    var mockAnimator: MockCardStackAnimator!
    var mockDelegate: MockSwipeCardStackDelegate!
    var mockStateManager: MockCardStackStateManager!
    var mockTransformProvider: MockCardStackTransformProvider!
    var subject: TestableSwipeCardStack!

    beforeEach {
      mockAnimator = MockCardStackAnimator()
      mockDelegate = MockSwipeCardStackDelegate()
      mockStateManager = MockCardStackStateManager()
      mockTransformProvider = MockCardStackTransformProvider()
      subject = TestableSwipeCardStack(animator: mockAnimator,
                                       layoutProvider: MockCardStackLayoutProvider(),
                                       notificationCenter: NotificationCenter(),
                                       stateManager: mockStateManager,
                                       transformProvider: mockTransformProvider)
      subject.delegate = mockDelegate
    }

    // MARK: - Did Tap

    describe("When calling didTap") {
      context("and topCardIndex is nil") {
        beforeEach {
          subject.testTopCardIndex = nil
          subject.card(didTap: SwipeCard())
        }

        it("should not call the cardStack's didSelectCard delegate method") {
          expect(mockDelegate.didSelectCardAtCalled) == false
        }
      }

      context("and topCardIndex is not nil") {
        let topIndex: Int = 4

        beforeEach {
          subject.testTopCardIndex = topIndex
          subject.card(didTap: SwipeCard())
        }

        it("should call the cardStack's didSelectCard delegate method with the correct index") {
          expect(mockDelegate.didSelectCardAtCalled) == true
          expect(mockDelegate.didSelectCardAtIndex) == topIndex
        }
      }
    }

    // MARK: - Did Begin Swipe

    describe("When calling didBeginSwipe") {
      beforeEach {
        subject.card(didBeginSwipe: SwipeCard())
      }

      it("should call the animator's removeBackgroundCardAnimation method") {
        expect(mockAnimator.removeBackgroundCardAnimationsCalled) == true
      }
    }

    // MARK: - Did Continue Swipe

    context("When calling didContinueSwipe") {
      var backgroundCards: [SwipeCard]!
      let cardTransform = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)

      beforeEach {
        backgroundCards = [SwipeCard(), SwipeCard(), SwipeCard()]
        subject.testBackgroundCards = backgroundCards
        mockTransformProvider.testBackgroundCardDragTransform = cardTransform
        subject.card(didContinueSwipe: SwipeCard())
      }

      it("should set the transforms on any of the background cards") {
        for card in backgroundCards {
          expect(card.transform) == cardTransform
        }
      }
    }

    // MARK: - Did Cancel Swipe

    describe("When the calling didCancelSwipe") {
      beforeEach {
        subject.card(didCancelSwipe: SwipeCard())
      }

      it("should call the animator's reset method") {
        expect(mockAnimator.animateResetCalled) == true
      }
    }

    // MARK: - Did Swipe

    context("When calling didSwipe") {
      let direction: SwipeDirection = .left

      beforeEach {
        subject.card(didSwipe: SwipeCard(), with: direction)
      }

      it("and should call swipeAction with the correct parameters") {
        expect(subject.swipeActionCalled) == true
        expect(subject.swipeActionDirection) == direction
        expect(subject.swipeActionForced) == false
        expect(subject.swipeActionAnimated) == true
      }
    }
  }
}
// swiftlint:enable function_body_length implicitly_unwrapped_optional
