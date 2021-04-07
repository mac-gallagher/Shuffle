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
@testable import Shuffle_iOS
import UIKit

// swiftlint:disable closure_body_length function_body_length implicitly_unwrapped_optional
class SwipeCardTest_Base: QuickSpec {

  override func spec() {
    var mockCardAnimator: MockCardAnimator!
    var mockSwipeCardDelegate: MockSwipeCardDelegate!
    var subject: TestableSwipeCard!

    beforeEach {
      mockCardAnimator = MockCardAnimator()
      mockSwipeCardDelegate = MockSwipeCardDelegate()

      subject = TestableSwipeCard(animator: mockCardAnimator)
      subject.delegate = mockSwipeCardDelegate
    }

    describe("Initialization") {
      var card: SwipeCard!

      describe("When initializing a SwipeCard with the default initializer") {
        beforeEach {
          card = SwipeCard()
        }

        it("should have the correct default properties") {
          testDefaultProperties()
        }
      }

      describe("When initializing a SwipeCard with the required initializer") {
        beforeEach {
          // TODO: - Find a non-deprecated way to accomplish this
          let coder = NSKeyedUnarchiver(forReadingWith: Data())
          card = SwipeCard(coder: coder)
        }

        it("should have the correct default properties") {
          testDefaultProperties()
        }
      }

      func testDefaultProperties() {
        expect(card.delegate).to(beNil())
        expect(card.animationOptions).to(be(CardAnimationOptions.default))
        expect(card.footerHeight) == 100
        expect(card.content).to(beNil())
        expect(card.footer).to(beNil())
        expect(card.touchLocation).to(beNil())

        let overlayContainer = card.subviews.first
        expect(overlayContainer).toNot(beNil())
        expect(overlayContainer?.isUserInteractionEnabled) == false
      }
    }

    // MARK: Content

    describe("When setting the content variable") {
      context("and it has not already been set") {
        beforeEach {
          subject.content = UIView()
        }

        it("should trigger a new layout cycle") {
          subject.setNeedsLayoutCalled = true
        }
      }

      context("and it has already been set") {
        let oldContentTag = 1
        let newContentTag = 2

        beforeEach {
          let oldContent = UIView()
          oldContent.tag = oldContentTag

          let newContent = UIView()
          newContent.tag = newContentTag

          subject.content = oldContent
          subject.layoutIfNeeded()

          subject.content = newContent
          subject.layoutIfNeeded()
        }

        it("should remove the old content from the view hierarchy and add the new content") {
          expect(subject.subviews.filter { $0.tag == oldContentTag }.count) == 0
          expect(subject.subviews.filter { $0.tag == newContentTag }.count) == 1
        }
      }
    }

    // MARK: Footer

    describe("When setting the footer variable") {
      context("and it has not already been set") {
        beforeEach {
          subject.footer = UIView()
        }

        it("should trigger a new layout cycle") {
          subject.setNeedsLayoutCalled = true
        }
      }

      context("and it has already been set") {
        let oldFooterTag = 1
        let newFooterTag = 2

        beforeEach {
          let oldFooter = UIView()
          oldFooter.tag = oldFooterTag

          let newFooter = UIView()
          newFooter.tag = newFooterTag

          subject.footer = oldFooter
          subject.layoutIfNeeded()

          subject.footer = newFooter
          subject.layoutIfNeeded()
        }

        it("should remove the old footer from the view hierarchy and add the new footer") {
          expect(subject.subviews.filter { $0.tag == oldFooterTag }.count) == 0
          expect(subject.subviews.filter { $0.tag == newFooterTag }.count) == 1
        }
      }
    }

    // MARK: Footer Height

    describe("When setting the footerHeight variable") {
      beforeEach {
        subject.footerHeight = 100
      }

      it("should trigger a new layout cycle") {
        subject.setNeedsLayoutCalled = true
      }
    }

    // MARK: - Gesture Recognizer Methods

    // MARK: Tap Gesture

    describe("When calling didTap") {
      let touchPoint = CGPoint(x: 50, y: 50)
      let testTapGestureRecognizer = TapGestureRecognizer()

      beforeEach {
        testTapGestureRecognizer.performTap(withLocation: touchPoint)
        subject.didTap(testTapGestureRecognizer)
      }

      it("should set the correct touch location") {
        expect(subject.touchLocation) == touchPoint
      }

      it("should call the didTap delegate method") {
        expect(mockSwipeCardDelegate.didTapCalled) == true
      }
    }

    // MARK: Begin Swiping

    describe("When calling beginSwiping") {
      let touchPoint = CGPoint(x: 50, y: 50)
      let testPanGestureRecognizer = PanGestureRecognizer()

      beforeEach {
        testPanGestureRecognizer.performPan(withLocation: touchPoint,
                                            translation: nil,
                                            velocity: nil)
        subject.beginSwiping(testPanGestureRecognizer)
      }

      it("should set the correct touch location") {
        expect(subject.touchLocation) == touchPoint
      }

      it("should call the didBeginSwipe delegate method") {
        expect(mockSwipeCardDelegate.didBeginSwipeCalled) == true
      }

      it("should remove all animations on the card") {
        expect(mockCardAnimator.removeAllAnimationsCalled) == true
      }
    }

    // MARK: Continue Swiping

    describe("When calling continueSwiping") {
      let overlay = UIView()
      let overlayPercentage: CGFloat = 0.5

      let transform: CGAffineTransform = {
        let rotation = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        let translation = CGAffineTransform(translationX: 100, y: 100)
        return rotation.concatenating(translation)
      }()

      beforeEach {
        subject.setOverlay(overlay, forDirection: .left)
        subject.testSwipeOverlayPercentage[.left] = overlayPercentage
        subject.testSwipeTransform = transform
        subject.continueSwiping(UIPanGestureRecognizer())
      }

      it("should call the didContinueSwipe delegate method") {
        expect(mockSwipeCardDelegate.didContinueSwipeCalled) == true
      }

      it("should apply the proper transformation to the card") {
        expect(subject.transform) == transform
      }

      it("should apply the proper overlay alpha values") {
        expect(overlay.alpha) == overlayPercentage
      }
    }

    // MARK: Did Swipe

    describe("When calling didSwipe") {
      let direction: SwipeDirection = .left

      beforeEach {
        subject.didSwipe(UIPanGestureRecognizer(), with: direction)
      }

      it("should call the delegate's didSwipe method") {
        expect(mockSwipeCardDelegate.didSwipeCalled) == true
      }

      it("should call the swipeAction method with the correct parameters") {
        expect(subject.swipeActionCalled) == true
        expect(subject.swipeActionDirection) == direction
        expect(subject.swipeActionForced) == false
      }
    }

    // MARK: Did Cancel Swipe

    describe("When calling didCancelSwipe") {
      beforeEach {
        subject.didCancelSwipe(UIPanGestureRecognizer())
      }

      it("should call the animator's reset method") {
        expect(mockCardAnimator.animateResetCalled) == true
      }
    }
  }
}
// swiftlint:enable closure_body_length function_body_length implicitly_unwrapped_optional
