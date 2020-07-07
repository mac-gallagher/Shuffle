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

// swiftlint:disable closure_body_length function_body_length implicitly_unwrapped_optional
class SwipeCardSpec_Base: QuickSpec {

  override func spec() {
    var mockCardAnimator: MockCardAnimator!
    var mockCardLayoutProvider: MockCardLayoutProvider!
    var mockCardTransformProvider: MockCardTransformProvider!
    var mockSwipeCardDelegate: MockSwipeCardDelegate!
    var mockNotificationCenter: TestableNotificationCenter!
    var subject: TestableSwipeCard!

    beforeEach {
      mockCardAnimator = MockCardAnimator()
      mockCardLayoutProvider = MockCardLayoutProvider()
      mockCardTransformProvider = MockCardTransformProvider()
      mockSwipeCardDelegate = MockSwipeCardDelegate()
      mockNotificationCenter = TestableNotificationCenter()

      subject = TestableSwipeCard(animator: mockCardAnimator,
                                  layoutProvider: mockCardLayoutProvider,
                                  notificationCenter: mockNotificationCenter,
                                  transformProvider: mockCardTransformProvider)
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

    // MARK: Swipe Completion Block

    describe("When the swipe animation completion block is called") {
      beforeEach {
        subject.swipeCompletionBlock()
      }

      it("should post the correct notification to the notification center") {
        expect(mockNotificationCenter.postedNotificationName) == CardDidFinishSwipeAnimationNotification
        expect(mockNotificationCenter.postedNotificationObject).to(be(subject))
      }
    }

    // MARK: Reverse Swipe Completion Block

    describe("When the reverse swipe animation completion block is called") {
      beforeEach {
        subject.isUserInteractionEnabled = false
        subject.reverseSwipeCompletionBlock()
      }

      it("should enable user interaction on the card") {
        expect(subject.isUserInteractionEnabled) == true
      }
    }

    // MARK: - Layout

    describe("When calling layoutSubviews") {
      let overlayContainerFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
      let contentFrame = CGRect(x: 5, y: 6, width: 7, height: 8)
      let footerFrame = CGRect(x: 9, y: 10, width: 11, height: 12)
      let content = UIView()
      let footer = UIView()
      let overlay = UIView()

      beforeEach {
        mockCardLayoutProvider.testContentFrame = contentFrame
        mockCardLayoutProvider.testFooterFrame = footerFrame
        mockCardLayoutProvider.testOverlayContainerFrame = overlayContainerFrame

        subject.content = content
        subject.footer = footer
        subject.setOverlay(overlay, forDirection: .left)

        subject.layoutSubviews()
      }

      it("should correctly layout the footer and the content") {
        expect(footer.frame) == footerFrame
        expect(content.frame) == contentFrame
      }

      it("should correctly layout the overlay container and its overlays") {
        let overlayContainer = subject.subviews.last
        expect(overlayContainer?.frame) == overlayContainerFrame

        let expectedOverlayFrame = CGRect(origin: .zero, size: overlayContainerFrame.size)
        expect(overlay.frame) == expectedOverlayFrame
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
        mockCardTransformProvider.testOverlayPercentage[.left] = overlayPercentage
        mockCardTransformProvider.testTranform = transform
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
