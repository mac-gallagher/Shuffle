import Nimble
import Quick
@testable import Shuffle
import UIKit

class CardTransformProviderSpec: QuickSpec {

  override func spec() {
    describe("CardTransformProvider") {
      let cardWidth: CGFloat = 100
      let cardHeight: CGFloat = 200
      let cardCenterX = cardWidth / 2
      let cardCenterY = cardHeight / 2

      var subject: TestableCardTransformProvider!
      var card: TestableSwipeCard!
      var testPanGestureRecognizer: PanGestureRecognizer!

      beforeEach {
        subject = TestableCardTransformProvider()
        card = TestableSwipeCard(animator: MockCardAnimator(),
                                 layoutProvider: MockCardLayoutProvider(),
                                 transformProvider: MockCardTransformProvider(),
                                 notificationCenter: TestableNotificationCenter())
        card.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)

        testPanGestureRecognizer = card.panGestureRecognizer as? PanGestureRecognizer
      }

      // MARK: - Overlay Percentage

      describe("Overlay Percentage") {
        context("When there is no active direction") {
          beforeEach {
            card.testActiveDirection = nil
          }

          it("should return an overlay percentage of zero") {
            expect(subject.overlayPercentage(for: card, direction: .left)).to(equal(0))
          }
        }

        context("When the drag percentage is nonzero in exactly one direction") {
          let dragPercentage: CGFloat = 0.1

          beforeEach {
            card.testDragPercentage[.left] = dragPercentage
          }

          it("should return the drag percentage in the dragged direction") {
            let actualPercentage = subject.overlayPercentage(for: card, direction: .left)
            expect(actualPercentage).to(equal(dragPercentage))
          }

          it("should return and overlay percentage of zero for all other directions") {
            for direction in [SwipeDirection.up, .right, .down] {
              let actualPercentage = subject.overlayPercentage(for: card, direction: direction)
              expect(actualPercentage).to(equal(0))
            }
          }
        }

        context("When the card is dragged a direction below its minimum swipe distance") {
          let direction = SwipeDirection.left
          let dragPercentage: CGFloat = 0.99

          beforeEach {
            card.testDragPercentage[direction] = dragPercentage
          }

          it("should have an overlay percentage less than 1 that direction") {
            let expectedPercentage: CGFloat = subject.overlayPercentage(for: card, direction: direction)
            expect(expectedPercentage).to(equal(dragPercentage))
          }
        }

        context("When the card is dragged in a direction at least its minimum swipe distance") {
          let direction = SwipeDirection.left

          beforeEach {
            card.testDragPercentage[direction] = 1.5
          }

          it("should have an overlay percentage equal to 1 in that direction") {
            let expectedPercentage: CGFloat = subject.overlayPercentage(for: card, direction: direction)
            expect(expectedPercentage).to(equal(1))
          }
        }
      }

      context("When the card is dragged in more than one direction") {
        let direction1 = SwipeDirection.left
        let direction2 = SwipeDirection.up

        context("and the drag percentage in the two directions are equal") {
          beforeEach {
            card.testDragPercentage[direction1] = 0.1
            card.testDragPercentage[direction2] = 0.1
          }

          it("should return an overlay percentage equal to 0 for both directions") {
            expect(subject.overlayPercentage(for: card, direction: direction1)).to(equal(0))
            expect(subject.overlayPercentage(for: card, direction: direction2)).to(equal(0))
          }
        }

        context("and the drag percentage in the two directions are not equal") {
          let largerPercentage: CGFloat = 0.4
          let smallerPercentage: CGFloat = 0.1

          beforeEach {
            card.testDragPercentage[direction1] = largerPercentage
            card.testDragPercentage[direction2] = smallerPercentage
          }

          it("should return the difference of percentages for the larger direction and 0 for the other") {
            let direction1Percentage = subject.overlayPercentage(for: card, direction: direction1)
            let direction2Percentage = subject.overlayPercentage(for: card, direction: direction2)

            expect(direction1Percentage).to(beCloseTo(largerPercentage - smallerPercentage))
            expect(direction2Percentage).to(equal(0))
          }
        }
      }

      // MARK: - Rotation Angle

      describe("Drag Rotation Angle") {
        context("When the card is dragged vertically") {
          beforeEach {
            testPanGestureRecognizer.performPan(withLocation: nil,
                                                translation: CGPoint(SwipeDirection.up.vector),
                                                velocity: nil)
          }

          it("should have rotation angle equal to zero") {
            let actualRotationAngle = subject.rotationAngle(for: card)
            expect(actualRotationAngle).to(equal(0))
          }
        }

        for rotationDirection in [CGFloat(-1), CGFloat(1)] {
          context("When the card is dragged horizontally") {
            let maximumRotationAngle: CGFloat = CGFloat.pi / 4

            beforeEach {
              subject.testRotationDirectionY = rotationDirection
              card.animationOptions = CardAnimationOptions(maximumRotationAngle: maximumRotationAngle)
            }

            context("and less than the screen's width") {
              let translation = CGPoint(x: SwipeDirection.left.vector.dx * (UIScreen.main.bounds.width - 1), y: 0)

              beforeEach {
                testPanGestureRecognizer.performPan(withLocation: nil,
                                                    translation: translation,
                                                    velocity: nil)
              }

              it("should return a rotation angle less than the maximum rotation angle") {
                let actualRotationAngle = subject.rotationAngle(for: card)
                expect(abs(actualRotationAngle)).to(beLessThan(maximumRotationAngle))
              }
            }

            context("and at least the length of the screen's width") {
              let translation = CGPoint(x: SwipeDirection.left.vector.dx * UIScreen.main.bounds.width, y: 0)

              beforeEach {
                testPanGestureRecognizer.performPan(withLocation: nil,
                                                    translation: translation,
                                                    velocity: nil)
              }

              it("should return a rotation angle equal to the maximum rotation angle") {
                let actualRotationAngle = subject.rotationAngle(for: card)
                expect(abs(actualRotationAngle)).to(equal(maximumRotationAngle))
              }
            }
          }
        }
      }

      // MARK: - Rotation Direction Y

      describe("Rotation Direction Y") {
        context("When the touch point is nil") {
          it("should have rotation direction equal to 0") {
            expect(subject.rotationDirectionY(for: card)).to(equal(0))
          }
        }

        context("When the touch point is in the first quadrant of the card's bounds") {
          beforeEach {
            let location = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
            card.testTouchLocation = location
          }

          it("should have rotation direction equal to 1") {
            expect(subject.rotationDirectionY(for: card)).to(equal(1))
          }
        }

        context("When the touch point is in the second quadrant of the card's bounds") {
          beforeEach {
            let location = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
            card.testTouchLocation = location
          }

          it("should have rotation direction equal to 1") {
            expect(subject.rotationDirectionY(for: card)).to(equal(1))
          }
        }

        context("When the touch point is in the third quadrant of the card's bounds") {
          beforeEach {
            let location = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
            card.testTouchLocation = location
          }

          it("should have rotation direction equal to -1") {
            expect(subject.rotationDirectionY(for: card)).to(equal(-1))
          }
        }

        context("When the touch point is in the fourth quadrant of the card's bounds") {
          beforeEach {
            let location = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
            card.testTouchLocation = location
          }

          it("should have rotation direction equal to -1") {
            expect(subject.rotationDirectionY(for: card)).to(equal(-1))
          }
        }
      }

      // MARK: - Transform

      describe("Transform") {
        context("When the card is dragged") {
          let rotationAngle: CGFloat = CGFloat.pi / 4
          let translation: CGPoint = CGPoint(x: 100, y: 100)

          beforeEach {
            subject.testRotationAngle = rotationAngle
            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil)
          }

          it("should return the transform with the proper rotation and translation") {
            let expectedTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
              .concatenating(CGAffineTransform(rotationAngle: rotationAngle))
            expect(subject.transform(for: card)).to(equal(expectedTransform))
          }
        }
      }
    }
  }
}
