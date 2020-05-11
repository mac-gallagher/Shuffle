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
        expect(newOverlay.alpha).to(equal(0))
        expect(newOverlay.isUserInteractionEnabled).to(beFalse())
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
        expect(subject.setOverlayOverlays).to(equal([.left: overlay1, .right: overlay2]))
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
      let animated: Bool = false

      beforeEach {
        subject.swipe(direction: direction, animated: animated)
      }

      it("should call the swipeAction method with the correct parameters") {
        expect(subject.swipeActionDirection).to(equal(direction))
        expect(subject.swipeActionForced).to(equal(true))
        expect(subject.swipeActionAnimated).to(equal(animated))
      }
    }

    // MARK: Swipe Action

    describe("When calling swipeAction") {
      let direction: SwipeDirection = .left
      let forced: Bool = false

      context("and animated is true") {
        beforeEach {
          subject.swipeAction(direction: direction,
                              forced: forced,
                              animated: true)
        }

        it("should disable the user interaction on the card") {
          expect(subject.isUserInteractionEnabled).to(beFalse())
        }

        it("should call the didSwipe delegate method with the correct parameters") {
          expect(mockSwipeCardDelegate.didSwipeCalled).to(beTrue())
          expect(mockSwipeCardDelegate.didSwipeDirection).to(equal(direction))
          expect(mockSwipeCardDelegate.didSwipeForced).to(equal(forced))
        }

        it("call the animator's swipe method with the correct parameters") {
          expect(mockCardAnimator.animateSwipeCalled).to(beTrue())
          expect(mockCardAnimator.animateSwipeDirection).to(equal(direction))
          expect(mockCardAnimator.animateSwipeForced).to(equal(forced))
        }
      }

      context("and animated is false") {
        beforeEach {
          subject.swipeAction(direction: direction,
                              forced: forced,
                              animated: false)
        }

        it("should disable the user interaction on the card") {
          expect(subject.isUserInteractionEnabled).to(beFalse())
        }

        it("should call the didSwipe delegate method with the correct parameters") {
          expect(mockSwipeCardDelegate.didSwipeCalled).to(beTrue())
          expect(mockSwipeCardDelegate.didSwipeDirection).to(equal(direction))
          expect(mockSwipeCardDelegate.didSwipeForced).to(equal(forced))
        }

        it("should call the card's swipe completion block") {
          expect(subject.swipeCompletionBlockCalled).to(beTrue())
        }

        it("should not call the animator's swipe") {
          expect(mockCardAnimator.animateSwipeCalled).to(beFalse())
        }
      }
    }

    // MARK: Reverse Swipe

    describe("When calling reverseSwipe") {
      let direction: SwipeDirection = .left

      context("and animated is true") {
        beforeEach {
          subject.reverseSwipe(from: direction, animated: true)
        }

        it("should disable user interaction on the card") {
          expect(subject.isUserInteractionEnabled).to(beFalse())
        }

        it("should call the reverseSwipe delegate method with the correct parameters") {
          expect(mockSwipeCardDelegate.didReverseSwipeCalled).to(beTrue())
          expect(mockSwipeCardDelegate.didReverseSwipeDirection).to(equal(direction))
        }

        it("should call the animator's reverse swipe method with the correct direction") {
          expect(mockCardAnimator.animateReverseSwipeCalled).to(beTrue())
          expect(mockCardAnimator.animateReverseSwipeDirection).to(equal(direction))
        }
      }

      context("and animated is false") {
        beforeEach {
          subject.reverseSwipe(from: direction, animated: false)
        }

        it("should call the reverseSwipe delegate method with the correct parameters") {
          expect(mockSwipeCardDelegate.didReverseSwipeCalled).to(beTrue())
          expect(mockSwipeCardDelegate.didReverseSwipeDirection).to(equal(direction))
        }

        it("should not call the animator's reverse swipe method") {
          expect(mockCardAnimator.animateReverseSwipeCalled).to(beFalse())
        }

        it("should call the card's reverse swipe completion block") {
          expect(subject.reverseSwipeCompletionBlockCalled).to(beTrue())
        }
      }
    }

    // MARK: Remove All Animations

    describe("When calling removeAllAnimations") {
      beforeEach {

        // add animation key to card
        UIView.animate(withDuration: 100, animations: {
          subject.alpha = 0
        })
        subject.removeAllAnimations()
      }

      it("should remove all the current animations on it's layer") {
        expect(subject.layer.animationKeys()).to(beNil())
      }

      it("should call the animator's removeAllAnimations method") {
        expect(mockCardAnimator.removeAllAnimationsCalled).to(beTrue())
      }
    }
  }
}
