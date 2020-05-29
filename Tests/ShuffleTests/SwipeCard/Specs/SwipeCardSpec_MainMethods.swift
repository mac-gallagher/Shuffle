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
class SwipeCardSpec_MainMethods: QuickSpec {

  override func spec() {
    var mockCardAnimator: MockCardAnimator!
    var mockSwipeCardDelegate: MockSwipeCardDelegate!
    var subject: TestableSwipeCard!

    beforeEach {
      mockCardAnimator = MockCardAnimator()
      mockSwipeCardDelegate = MockSwipeCardDelegate()

      subject = TestableSwipeCard(animator: mockCardAnimator,
                                  layoutProvider: MockCardLayoutProvider(),
                                  notificationCenter: NotificationCenter.default,
                                  transformProvider: MockCardTransformProvider())
      subject.delegate = mockSwipeCardDelegate
    }

    // MARK: - Main Methods

    // MARK: Set Overlay

    describe("When calling setOverlay") {
      let oldOverlay = UIView()
      let newOverlay = UIView()
      let direction = SwipeDirection.left

      var overlayContainer: UIView!

      beforeEach {
        overlayContainer = subject.subviews.last
        subject.setOverlay(oldOverlay, forDirection: direction)
        subject.setOverlay(newOverlay, forDirection: direction)
      }

      it("should remove the old overlay from the view hierarchy") {
        expect(oldOverlay.superview).to(beNil())
      }

      it("add the new overlay to the overlay container's view hierarchy") {
        expect(newOverlay.superview).to(be(overlayContainer))
      }

      it("should set the overlay's alpha value to 0 and disable user interaction") {
        expect(newOverlay.alpha) == 0
        expect(newOverlay.isUserInteractionEnabled) == false
      }
    }

    // MARK: Set Overlays

    describe("When calling setOverlays") {
      let overlay1 = UIView()
      let overlay2 = UIView()

      beforeEach {
        subject.setOverlays([.left: overlay1, .right: overlay2])
      }

      it("should call the setOverlay method for each provided direction/overlay pair") {
        expect(subject.setOverlayOverlays) == [.left: overlay1, .right: overlay2]
      }
    }

    // MARK: Overlay Getter

    describe("When calling overlayForDirection") {
      let overlay = UIView()
      let direction = SwipeDirection.left

      beforeEach {
        subject.setOverlay(overlay, forDirection: direction)
      }

      it("should return the overlay in the indicated direction") {
        let actualOverlay = subject.overlay(forDirection: direction)
        expect(actualOverlay).to(be(overlay))
      }
    }

    // MARK: Programmatic Swipe

    describe("When calling swipe") {
      let direction: SwipeDirection = .left

      beforeEach {
        subject.swipe(direction: direction)
      }

      it("should call the swipeAction method with the correct parameters") {
        expect(subject.swipeActionCalled) == true
        expect(subject.swipeActionDirection) == direction
        expect(subject.swipeActionForced) == true
      }
    }

    // MARK: Swipe Action

    describe("When calling swipeAction") {
      let direction: SwipeDirection = .left
      let forced: Bool = false

      beforeEach {
        subject.swipeAction(direction: direction, forced: forced)
      }

      it("should disable the user interaction on the card") {
        expect(subject.isUserInteractionEnabled) == false
      }

      it("should not call the didSwipe delegate method") {
        expect(mockSwipeCardDelegate.didSwipeCalled) == false
      }

      it("should call the animator's swipe method with the correct parameters") {
        expect(mockCardAnimator.animateSwipeCalled) == true
        expect(mockCardAnimator.animateSwipeDirection) == direction
        expect(mockCardAnimator.animateSwipeForced) == forced
      }

      it("should invoke the swipe completion block once the animation has completed") {
        expect(subject.swipeCompletionBlockCalled) == true
      }
    }

    // MARK: Reverse Swipe

    describe("When calling reverseSwipe") {
      let direction: SwipeDirection = .left

      beforeEach {
        subject.testReverseSwipeCompletionBlock = {}
        subject.reverseSwipe(from: direction)
      }

      it("should disable user interaction on the card") {
        expect(subject.isUserInteractionEnabled) == false
      }

      it("should call the animator's reverse swipe method with the correct direction") {
        expect(mockCardAnimator.animateReverseSwipeCalled) == true
        expect(mockCardAnimator.animateReverseSwipeDirection) == direction
      }

      it("should invoke the reverse swipe completion block once the animation has completed") {
        expect(subject.reverseSwipeCompletionBlockCalled) == true
      }
    }

    // MARK: Remove All Animations

    describe("When calling removeAllAnimations") {
      beforeEach {
        // add animation key to card
        UIView.animate(withDuration: 100) {
          subject.alpha = 0
        }
        subject.removeAllAnimations()
      }

      it("should remove all the current animations on it's layer") {
        expect(subject.layer.animationKeys()).to(beNil())
      }

      it("should call the animator's removeAllAnimations method") {
        expect(mockCardAnimator.removeAllAnimationsCalled) == true
      }
    }
  }
}
// swiftlint:enable function_body_length implicitly_unwrapped_optional
