import Nimble
import Quick
@testable import Shuffle
import UIKit

class SwipeCardSpec: QuickSpec {

  override func spec() {
    describe("SwipeCard") {
      var mockCardAnimator: MockCardAnimator!
      var mockCardLayoutProvider: MockCardLayoutProvider!
      var mockCardTransformProvider: MockCardTransformProvider!
      var mockSwipeCardDelegate: MockSwipeCardDelegate!
      var notificationCenter: TestableNotificationCenter!
      var subject: TestableSwipeCard!

      beforeEach {
        mockCardAnimator = MockCardAnimator()
        mockCardLayoutProvider = MockCardLayoutProvider()
        mockCardTransformProvider = MockCardTransformProvider()
        mockSwipeCardDelegate = MockSwipeCardDelegate()
        notificationCenter = TestableNotificationCenter()

        subject = TestableSwipeCard(animator: mockCardAnimator,
                                    layoutProvider: mockCardLayoutProvider,
                                    transformProvider: mockCardTransformProvider,
                                    notificationCenter: notificationCenter)
        subject.delegate = mockSwipeCardDelegate
      }

      describe("Initialization") {
        var card: SwipeCard!

        context("When initializing a SwipeCard with the default initializer") {
          beforeEach {
            card = SwipeCard()
          }

          it("should have the correct default properties") {
            testDefaultProperties()
          }
        }

        context("When initializing a SwipeCard with the required initializer") {
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
          expect(card.footerHeight).to(equal(100))
          expect(card.content).to(beNil())
          expect(card.footer).to(beNil())
          expect(card.touchLocation).to(beNil())

          let overlayContainer = card.subviews.first
          expect(overlayContainer).toNot(beNil())
          expect(overlayContainer?.isUserInteractionEnabled).to(beFalse())
        }
      }

      // MARK: - Variables

      // MARK: Content

      describe("Content") {
        context("When setting the content variable when it has not been set") {
          beforeEach {
            subject.content = UIView()
          }

          it("should trigger a new layout cycle") {
            subject.setNeedsLayoutCalled = true
          }
        }

        context("When setting the content variable when it has already been set") {
          let oldContent = UIView()
          let newContent = UIView()

          beforeEach {
            oldContent.tag = 1
            newContent.tag = 2

            subject.content = oldContent
            subject.layoutIfNeeded()

            subject.content = newContent
            subject.layoutIfNeeded()
          }

          it("should remove the old content from the view hierarchy and add the new content") {
            expect(subject.subviews.filter{ $0.tag == 1 }.count).to(equal(0))
            expect(subject.subviews.filter{ $0.tag == 2 }.count).to(equal(1))
          }
        }
      }

      // MARK: Footer

      describe("Footer") {
        context("When setting the footer variable when it has not been set") {
          beforeEach {
            subject.footer = UIView()
          }

          it("should trigger a new layout cycle") {
            subject.setNeedsLayoutCalled = true
          }
        }

        context("When setting the footer variable when it has already been set") {
          let oldFooter = UIView()
          let newFooter = UIView()

          beforeEach {
            oldFooter.tag = 1
            newFooter.tag = 2

            subject.footer = oldFooter
            subject.layoutIfNeeded()

            subject.footer = newFooter
            subject.layoutIfNeeded()
          }

          it("should remove the old footer from the view hierarchy and add the new footer") {
            expect(subject.subviews.filter{ $0.tag == 1 }.count).to(equal(0))
            expect(subject.subviews.filter{ $0.tag == 2 }.count).to(equal(1))
          }
        }
      }

      // MARK: Footer Height

      describe("Footer Height") {
        context("When setting the footerHeight variable") {
          beforeEach {
            subject.footerHeight = 100
          }

          it("should trigger a new layout cycle") {
            subject.setNeedsLayoutCalled = true
          }
        }
      }

      // MARK: Swipe Completion Block

      describe("Swipe Completion Block") {
        context("When the swipe animation completion is called") {
          beforeEach {
            subject.swipeCompletionBlock()
          }

          it("should post the correct notification to the notification center") {
            expect(notificationCenter.postedNotificationName)
              .to(equal(CardDidFinishSwipeAnimationNotification))
            expect(notificationCenter.postedNotificationObject).to(be(subject))
          }
        }
      }

      // MARK: Reverse Swipe Completion Block

      describe("Reverse Swipe Completion Block") {
        context("When the reverse swipe animation completion is called") {
          beforeEach {
            subject.isUserInteractionEnabled = false
            subject.reverseSwipeCompletionBlock()
          }

          it("should enable user interaction on the card") {
            expect(subject.isUserInteractionEnabled).to(beTrue())
          }
        }
      }

      // MARK: - Layout

      describe("Layout") {
        context("When calling layoutSubviews") {
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
            expect(footer.frame).to(equal(footerFrame))
            expect(content.frame).to(equal(contentFrame))
          }

          it("should correctly layout the overlay container and its overlays") {
            let overlayContainer = subject.subviews.last
            expect(overlayContainer?.frame).to(equal(overlayContainerFrame))

            let expectedOverlayFrame = CGRect(origin: .zero, size: overlayContainerFrame.size)
            expect(overlay.frame).to(equal(expectedOverlayFrame))
          }
        }
      }

      // MARK: - Gesture Recognizer Methods

      // MARK: Tap Gesture

      describe("Tap Gesture") {
        context("When didTap is called") {
          let touchPoint = CGPoint(x: 50, y: 50)
          let testTapGestureRecognizer = TapGestureRecognizer()

          beforeEach {
            testTapGestureRecognizer.performTap(withLocation: touchPoint)
            subject.didTap(testTapGestureRecognizer)
          }

          it("should set the correct touch location") {
            expect(subject.touchLocation).to(equal(touchPoint))
          }

          it("should call the didTap delegate method") {
            expect(mockSwipeCardDelegate.didTapCalled).to(beTrue())
          }
        }
      }

      // MARK: Begin Swiping

      describe("Begin Swiping") {
        context("When the beginSwiping method is called") {
          let touchPoint = CGPoint(x: 50, y: 50)
          let testPanGestureRecognizer = PanGestureRecognizer()

          beforeEach {
            testPanGestureRecognizer.performPan(withLocation: touchPoint,
                                                translation: nil,
                                                velocity: nil)
            subject.beginSwiping(testPanGestureRecognizer)
          }

          it("should set the correct touch location") {
            expect(subject.touchLocation).to(equal(touchPoint))
          }

          it("should call the didBeginSwipe delegate method") {
            expect(mockSwipeCardDelegate.didBeginSwipeCalled).to(beTrue())
          }

          it("should remove all animations on the card") {
            expect(mockCardAnimator.removeAllAnimationsCalled).to(beTrue())
          }
        }
      }

      // MARK: Continue Swiping

      describe("Continue Swiping") {
        context("When the continueSwiping method is called") {
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
            expect(mockSwipeCardDelegate.didContinueSwipeCalled).to(beTrue())
          }

          it("should apply the proper transformation to the card") {
            expect(subject.transform).to(equal(transform))
          }

          it("should apply the proper overlay alpha values") {
            expect(overlay.alpha).to(equal(overlayPercentage))
          }
        }
      }

      // MARK: Did Swipe

      describe("Did Swipe") {
        context("When the didSwipe method is called") {
          let direction: SwipeDirection = .left

          beforeEach {
            subject.didSwipe(UIPanGestureRecognizer(), with: direction)
          }

          it("should call the swipeAction method with the correct parameters") {
            expect(subject.swipeActionDirection).to(equal(direction))
            expect(subject.swipeActionForced).to(equal(false))
            expect(subject.swipeActionAnimated).to(equal(true))
          }
        }
      }

      // MARK: Did Cancel Swipe

      describe("Did Cancel Swipe") {
        context("When the didCancelSwipe method is called") {
          beforeEach {
            subject.didCancelSwipe(UIPanGestureRecognizer())
          }

          it("should call the animator's reset method") {
            expect(mockCardAnimator.animateResetCalled).to(beTrue())
          }
        }
      }

      // MARK: - Main Methods

      // MARK: Set Overlay

      describe("Set Overlay") {
        context("When calling setOverlay") {
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
      }

      // MARK: Set Overlays

      describe("Set Overlays") {
        context("When calling setOverlays") {
          let overlay1 = UIView()
          let overlay2 = UIView()

          beforeEach {
            subject.setOverlays([.left: overlay1, .right: overlay2])
          }

          it("should call the setOverlay method for each provided direction/overlay pair") {
            expect(subject.setOverlayOverlays).to(equal([.left: overlay1, .right: overlay2]))
          }
        }
      }

      // MARK: Overlay Getter

      describe("Overlay Getter") {
        context("When calling the overlay getter function") {
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
      }

      // MARK: Programmatic Swipe

      describe("Programmatic Swipe") {
        context("When the swipe method is called") {
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
      }

      // MARK: Swipe Action

      describe("Swipe Action") {
        context("When the swipeAction method is called") {
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
      }

      // MARK: Reverse Swipe

      describe("Reverse Swipe") {
        context("When the reverse swipe method is called") {
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
      }

      // MARK: Remove All Animations

      describe("Remove All Animations") {
        context("When the removeAllAnimations method is called") {
          beforeEach {
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
  }
}
