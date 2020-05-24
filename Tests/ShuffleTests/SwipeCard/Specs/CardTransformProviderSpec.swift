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
class CardTransformProviderSpec: QuickSpec {

  override func spec() {
    let cardWidth: CGFloat = 100
    let cardHeight: CGFloat = 200
    let cardCenterX = cardWidth / 2
    let cardCenterY = cardHeight / 2

    var card: TestableSwipeCard!
    var testPanGestureRecognizer: PanGestureRecognizer!
    var subject: TestableCardTransformProvider!

    beforeEach {
      subject = TestableCardTransformProvider()
      card = TestableSwipeCard(animator: MockCardAnimator(),
                               layoutProvider: MockCardLayoutProvider(),
                               notificationCenter: NotificationCenter.default,
                               transformProvider: MockCardTransformProvider())
      card.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)

      testPanGestureRecognizer = card.panGestureRecognizer as? PanGestureRecognizer
    }

    // MARK: - Overlay Percentage

    describe("When calling overlayPercentage") {
      context("and there is no active direction") {
        beforeEach {
          card.testActiveDirection = nil
        }

        it("should return zero") {
          expect(subject.overlayPercentage(for: card, direction: .left)) == 0
        }
      }

      context("and the drag percentage is nonzero in exactly one direction") {
        let dragPercentage: CGFloat = 0.1

        beforeEach {
          card.testDragPercentage[.left] = dragPercentage
        }

        it("should return the drag percentage in the dragged direction") {
          let actualPercentage = subject.overlayPercentage(for: card, direction: .left)
          expect(actualPercentage) == dragPercentage
        }

        it("should return zero for all other directions") {
          for direction in [SwipeDirection.up, .right, .down] {
            let actualPercentage = subject.overlayPercentage(for: card, direction: direction)
            expect(actualPercentage) == 0
          }
        }
      }

      context("and the card is dragged in a direction below its minimum swipe distance") {
        let direction = SwipeDirection.left
        let dragPercentage: CGFloat = 0.99

        beforeEach {
          card.testDragPercentage[direction] = dragPercentage
        }

        it("should return a value less than 1 that direction") {
          let expectedPercentage: CGFloat = subject.overlayPercentage(for: card, direction: direction)
          expect(expectedPercentage) == dragPercentage
        }
      }

      context("and the card is dragged in a direction at least its minimum swipe distance") {
        let direction = SwipeDirection.left

        beforeEach {
          card.testDragPercentage[direction] = 1.5
        }

        it("should return 1 in that direction") {
          let expectedPercentage: CGFloat = subject.overlayPercentage(for: card, direction: direction)
          expect(expectedPercentage) == 1
        }
      }

      context("and the card is dragged in more than one direction") {
        let direction1 = SwipeDirection.left
        let direction2 = SwipeDirection.up

        context("and the drag percentage in the two directions are equal") {
          beforeEach {
            card.testDragPercentage[direction1] = 0.1
            card.testDragPercentage[direction2] = 0.1
          }

          it("should return zero for both directions") {
            expect(subject.overlayPercentage(for: card, direction: direction1)) == 0
            expect(subject.overlayPercentage(for: card, direction: direction2)) == 0
          }
        }

        context("and the drag percentage in the two directions are not equal") {
          let largerPercentage: CGFloat = 0.4
          let smallerPercentage: CGFloat = 0.1

          beforeEach {
            card.testDragPercentage[direction1] = largerPercentage
            card.testDragPercentage[direction2] = smallerPercentage
          }

          it("should return the difference of percentages for the larger direction and zero for the other") {
            let direction1Percentage = subject.overlayPercentage(for: card, direction: direction1)
            let direction2Percentage = subject.overlayPercentage(for: card, direction: direction2)

            expect(direction1Percentage).to(beCloseTo(largerPercentage - smallerPercentage))
            expect(direction2Percentage) == 0
          }
        }
      }
    }

    // MARK: - Rotation Angle

    describe("When calling dragRotationAngle") {
      context("When the card is dragged vertically") {
        beforeEach {
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: CGPoint(SwipeDirection.up.vector),
                                              velocity: nil)
        }

        it("should return zero") {
          let actualRotationAngle = subject.rotationAngle(for: card)
          expect(actualRotationAngle) == 0
        }
      }

      for rotationDirection in [CGFloat(-1), CGFloat(1)] {
        context("When the card is dragged horizontally") {
          let maximumRotationAngle = CGFloat.pi / 4

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
              expect(abs(actualRotationAngle)) < maximumRotationAngle
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
              expect(abs(actualRotationAngle)) == maximumRotationAngle
            }
          }
        }
      }
    }

    // MARK: - Rotation Direction Y

    describe("When calling the rotationDirectionY method") {
      context("and the touch point is nil") {
        it("should return zero") {
          expect(subject.rotationDirectionY(for: card)) == 0
        }
      }

      context("and the touch location is in the first quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
          card.testTouchLocation = location
        }

        it("should return 1") {
          expect(subject.rotationDirectionY(for: card)) == 1
        }
      }

      context("and the touch location is in the second quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
          card.testTouchLocation = location
        }

        it("should return 1") {
          expect(subject.rotationDirectionY(for: card)) == 1
        }
      }

      context("and the touch location is in the third quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
          card.testTouchLocation = location
        }

        it("should return -1") {
          expect(subject.rotationDirectionY(for: card)) == -1
        }
      }

      context("and the touch location is in the fourth quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
          card.testTouchLocation = location
        }

        it("should return -1") {
          expect(subject.rotationDirectionY(for: card)) == -1
        }
      }
    }

    // MARK: - Transform

    describe("When calling transform") {
      let rotationAngle = CGFloat.pi / 4
      let translation = CGPoint(x: 100, y: 100)

      beforeEach {
        subject.testRotationAngle = rotationAngle
        testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil)
      }

      it("should return the transform with the proper rotation and translation") {
        let expectedTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
          .concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        expect(subject.transform(for: card)) == expectedTransform
      }
    }
  }
}
// swiftlint:enable closure_body_length function_body_length implicitly_unwrapped_optional
