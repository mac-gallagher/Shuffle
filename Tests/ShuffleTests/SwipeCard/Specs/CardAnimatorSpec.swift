import Nimble
import Quick
@testable import Shuffle
import UIKit

class CardAnimatorSpec: QuickSpec {

  override func spec() {
    describe("CardAnimator") {
      let cardWidth: CGFloat = 100
      let cardHeight: CGFloat = 200

      var card: TestableSwipeCard!
      var subject: TestableCardAnimator!

      beforeEach {
        subject = TestableCardAnimator()
        card = TestableSwipeCard(animator: MockCardAnimator(),
                                 layoutProvider: MockCardLayoutProvider(),
                                 transformProvider: MockCardTransformProvider(),
                                 notificationCenter: NotificationCenter.default)
        card.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
      }

      afterEach {
        UIView.setAnimationsEnabled(true)
      }

      //MARK: - Main Methods

      //MARK: Animate Reset

      describe("Animate Reset") {
        context("When calling the animateReset method") {
          let overlay = UIView()

          beforeEach {
            UIView.setAnimationsEnabled(false)

            card.transform = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
            card.testActiveDirection = .left
            card.setOverlay(overlay, forDirection: .left)
            overlay.alpha = 1

            subject.animateReset(on: card)
          }

          it("should remove all animations on the card") {
            expect(subject.removeAllAnimationsCalled).to(beTrue())
          }

          it("should reset the card's transform and set the active direction's overlay alpha to zero") {
            expect(card.transform).to(equal(.identity))
            expect(overlay.alpha).to(equal(0))
          }
        }
      }

      // MARK: Animate Reverse Swipe

      describe("Animate Reverse Swipe") {
        context("When calling the animateReverseSwipe method") {

          beforeEach {
            UIView.setAnimationsEnabled(false)
            subject.animateReverseSwipe(on: card, from: .left)
          }

          it("should remove all animations on the card") {
            expect(subject.removeAllAnimationsCalled).to(beTrue())
          }

          it("should recreate the swipe") {
            expect(subject.addSwipeAnimationKeyFramesCalled).to(beTrue())
          }

          it("should add the reverse swipe animation key frames") {
            expect(subject.addReverseSwipeAnimationKeyFramesCalled).to(beTrue())
          }

          it("should call the card's reverse swipe completion block once the animation has completed") {
            expect(card.reverseSwipeCompletionBlockCalled).toEventually(beTrue())
          }
        }
      }


      // MARK: Animate Swipe

      describe("Animate Swipe") {
        context("When calling the animateSwipe method") {
          beforeEach {
            UIView.setAnimationsEnabled(false)
            subject.animateSwipe(on: card, direction: .left, forced: false)
          }

          it("should remove all animations on the card") {
            expect(subject.removeAllAnimationsCalled).to(beTrue())
          }

          it("should add the swipe animation key frames") {
            expect(subject.addSwipeAnimationKeyFramesCalled).to(beTrue())
          }

          it("should call the card's swipe completion block once the animation has completed") {
            expect(card.swipeCompletionBlockCalled).toEventually(beTrue())
          }
        }
      }

      // MARK: Remove All Animations

      describe("Remove All Animations") {
        context("When calling the removeAllAnimations method") {
          let overlay = UIView()

          beforeEach {
            card.setOverlay(overlay, forDirection: .left)

            UIView.animate(withDuration: 100, animations: {
              card.alpha = 0
              overlay.transform = CGAffineTransform(a: 1, b: 2, c: 3,
                                                    d: 4, tx: 5, ty: 6)
            })

            subject.removeAllAnimations(on: card)
          }

          it("should remove all current animations on the card's layer") {
            expect(card.layer.animationKeys()).to(beNil())
          }

          it("should remove all current animations on each of the card's overlays") {
            expect(overlay.layer.animationKeys()).to(beNil())
          }
        }
      }

      // MARK: - Animation Calculations

      // MARK: Relative Swipe Overlay Fade Duration

      describe("Relative Swipe Overlay Fade Duration") {
        context("When accessing the relativeSwipeOverlayFadeDuration method") {
          let direction: SwipeDirection = .left

          context("and there is no overlay in the indicated direction") {
            beforeEach {
              card.setOverlay(nil, forDirection: direction)
            }

            it("should return a duration of zero") {
              let actualDuration = subject.relativeSwipeOverlayFadeDuration(card, direction: direction, forced: true)
              expect(actualDuration).to(equal(0.0))
            }
          }

          context("and there an overlay in the indicated direction") {
            let relativeDuration: TimeInterval = 0.9
            let totalDuration: TimeInterval = 50.0

            beforeEach {
              card.setOverlay(UIView(), forDirection: direction)
              card.animationOptions = CardAnimationOptions(relativeSwipeOverlayFadeDuration: relativeDuration,
                                                           totalSwipeDuration: totalDuration)
            }

            context("and it is forced") {
              it("should return the correct duration") {
                let actualDuration = subject.relativeSwipeOverlayFadeDuration(card, direction: direction, forced: true)
                expect(actualDuration).to(equal(relativeDuration))
              }
            }

            context("and it is not forced") {
              it("should return a duration of zero") {
                let actualDuration = subject.relativeSwipeOverlayFadeDuration(card, direction: direction, forced: false)
                expect(actualDuration).to(equal(0))
              }
            }
          }
        }
      }

      // MARK: Relative Reverse Swipe Overlay Fade Duration

      describe("Relative Reverse Swipe Overlay Fade Duration") {
        context("When calling the relativeReverseSwipeOverlayFadeDuration method") {
          let direction: SwipeDirection = .left

          context("and there is no overlay in the indicated direction") {
            beforeEach {
              card.setOverlay(nil, forDirection: direction)
            }

            it("should return a duration of zero") {
              let actualDuration = subject.relativeReverseSwipeOverlayFadeDuration(card, direction: direction)
              expect(actualDuration).to(equal(0.0))
            }
          }

          context("and there is an overlay in the indicated direction") {
            let relativeDuration: TimeInterval = 0.9
            let totalDuration: TimeInterval = 50.0

            beforeEach {
              card.setOverlay(UIView(), forDirection: direction)
              card.animationOptions = CardAnimationOptions(relativeReverseSwipeOverlayFadeDuration: relativeDuration,
                                                           totalReverseSwipeDuration: totalDuration)
            }

            it("should return the should return the correct duration") {
              let actualDuration = subject.relativeReverseSwipeOverlayFadeDuration(card, direction: direction)
              expect(actualDuration).to(equal(relativeDuration))
            }
          }
        }
      }

      // MARK: Swipe Duration

      describe("Swipe Duration") {
        context("When calling the swipeDuration method") {
          let direction: SwipeDirection = .left
          let totalDuration: TimeInterval = 30
          let minimumSwipeSpeed: CGFloat = 100

          beforeEach {
            card.animationOptions = CardAnimationOptions(totalSwipeDuration: totalDuration)
            card.testMinimumSwipeSpeed = minimumSwipeSpeed
          }

          context("and forced is true") {
            it("should return totalSwipeDuration from card.animationOptions") {
              let actualDuration = subject.swipeDuration(card, direction: direction, forced: true)
              expect(actualDuration).to(equal(totalDuration))
            }
          }

          context("and forced is false") {
            context("and the card was swiped at least the minimum swipe speed") {
              let swipeFactor: CGFloat = 2.0

              beforeEach {
                card.testDragSpeed = swipeFactor * minimumSwipeSpeed
              }

              it("should return the correct relative swipe duration") {
                let actualDuration = subject.swipeDuration(card, direction: direction, forced: false)
                expect(actualDuration).to(equal(1 / TimeInterval(swipeFactor)))
              }
            }

            context("and the card was swiped at less than the minimum swipe speed") {
              beforeEach {
                card.testDragSpeed = minimumSwipeSpeed / 2
              }

              it("should return totalSwipeDuration from card.animationOptions") {
                let actualDuration = subject.swipeDuration(card, direction: direction, forced: false)
                expect(actualDuration).to(equal(totalDuration))
              }
            }
          }
        }
      }

      // MARK: Swipe Rotation Angle

      describe("Swipe Rotation Angle") {
        context("When calling the swipeRotationAngle method") {
          context("and the direction is vertical") {
            it("should return zero") {
              let actualRotation = subject.swipeRotationAngle(card, direction: .up, forced: false)
              expect(actualRotation).to(equal(0.0))
            }
          }

          for direction in [SwipeDirection.left, SwipeDirection.right] {
            context("When the direction is horizontal") {
              let maximumRotationAngle: CGFloat = CGFloat.pi / 4

              beforeEach {
                card.animationOptions
                  = CardAnimationOptions(maximumRotationAngle: maximumRotationAngle)
              }

              context("and forced is true") {
                it("should return the twice the maximum rotation angle") {
                  let actualRotation = subject.swipeRotationAngle(card, direction: direction, forced: true)
                  let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                  expect(actualRotation).to(equal(expectedRotation))
                }
              }

              context("and forced is false") {
                let cardCenterX: CGFloat = cardWidth / 2
                let cardCenterY: CGFloat = cardHeight / 2

                context("and the touch point is nil") {
                  beforeEach {
                    card.testTouchLocation = nil
                  }

                  it("should return the twice the maximum rotation angle") {
                    let actualRotation = subject.swipeRotationAngle(card, direction: direction, forced: false)
                    let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                    expect(actualRotation).to(equal(expectedRotation))
                  }
                }

                context("and the touch point is in the first quadrant of the card's bounds") {
                  beforeEach {
                    card.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
                  }

                  it("should return the correct rotation angle") {
                    let actualRotation = subject.swipeRotationAngle(card, direction: direction, forced: false)
                    let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                    expect(actualRotation).to(equal(expectedRotation))
                  }
                }

                context("and the touch point is in the second quadrant of the card's bounds") {
                  beforeEach {
                    card.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
                  }

                  it("should return the correct rotation angle") {
                    let actualRotation = subject.swipeRotationAngle(card, direction: direction, forced: false)
                    let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                    expect(actualRotation).to(equal(expectedRotation))
                  }
                }

                context("and the touch point is in the third quadrant of the card's bounds") {
                  beforeEach {
                    card.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
                  }

                  it("should return the correct rotation angle") {
                    let actualRotation = subject.swipeRotationAngle(card, direction: direction, forced: false)
                    let expectedRotation = 2 * (direction == .right ? -1 : 1) * maximumRotationAngle
                    expect(actualRotation).to(equal(expectedRotation))
                  }
                }

                context("and the touch point is in the fourth quadrant of the card's bounds") {
                  beforeEach {
                    card.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
                  }

                  it("should return the correct rotation angle") {
                    let actualRotation = subject.swipeRotationAngle(card, direction: direction, forced: false)
                    let expectedRotation = 2 * (direction == .right ? -1 : 1) * maximumRotationAngle
                    expect(actualRotation).to(equal(expectedRotation))
                  }
                }
              }
            }
          }
        }
      }

      // MARK: Swipe Transform

      describe("Swipe Transform") {
        context("When calling the swipeTransform method") {
          let testRotationAngle: CGFloat = CGFloat.pi / 4
          let testTranslation: CGVector = CGVector(dx: 100, dy: 200)

          let testTransform: CGAffineTransform = {
            let rotation = CGAffineTransform(rotationAngle: testRotationAngle)
            let translation = CGAffineTransform(translationX: testTranslation.dx, y: testTranslation.dy)
            return rotation.concatenating(translation)
          }()

          beforeEach {
            subject.testSwipeRotationAngle = testRotationAngle
            subject.testSwipeTranslation = testTranslation
          }

          it("should return a transform with the proper rotation and translation") {
            let actualTranslation = subject.swipeTransform(card, direction: .left, forced: false)
            expect(actualTranslation).to(equal(testTransform))

          }
        }
      }

      // MARK: Swipe Translation

      describe("Swipe Translation") {
        context("When calling the swipeTranslation method") {
          let screenBounds: CGRect = UIScreen.main.bounds
          let minimumSwipeSpeed: CGFloat = 100

          beforeEach {
            card.testMinimumSwipeSpeed = minimumSwipeSpeed
          }

          context("and the swipe is below the minimum swipe speed") {
            beforeEach {
              card.testDragSpeed = minimumSwipeSpeed / 2
            }

            it("should return a translation far enough to swipe the card off screen") {
              let direction: SwipeDirection = .left
              let actualTranslation = subject.swipeTranslation(card, direction: direction, directionVector: direction.vector)
              let translatedCardBounds = CGRect(x: actualTranslation.dx,
                                                y: actualTranslation.dy,
                                                width: cardWidth,
                                                height: cardHeight)
              expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
            }
          }

          context("and the swipe is at least the minimum swipe speed") {
            beforeEach {
              card.testDragSpeed = minimumSwipeSpeed
            }

            it("should return a translation far enough to swipe the card off screen") {
              let direction: SwipeDirection = .left
              let actualTranslation = subject.swipeTranslation(card, direction: direction, directionVector: direction.vector)
              let translatedCardBounds = CGRect(x: actualTranslation.dx,
                                                y: actualTranslation.dy,
                                                width: cardWidth,
                                                height: cardHeight)
              expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
            }
          }
        }
      }
    }
  }
}
