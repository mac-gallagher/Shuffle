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
class SwipeCardTest_Layout: QuickSpec {

  override func spec() {
    let cardWidth: CGFloat = 100
    let cardHeight: CGFloat = 200
    let cardCenterX = cardWidth / 2
    let cardCenterY = cardHeight / 2

    var subject: TestableSwipeCard!
    var testPanGestureRecognizer: PanGestureRecognizer!

    beforeEach {
      subject = TestableSwipeCard(animator: MockCardAnimator())
      subject.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)

      testPanGestureRecognizer = subject.panGestureRecognizer as? PanGestureRecognizer
    }

    // MARK: - Layout

    describe("When calling layoutSubviews") {
      let content = UIView()
      let overlay = UIView()
      let cardWidth: CGFloat = 100
      let cardHeight: CGFloat = 200
      let footerHeight: CGFloat = 50

      beforeEach {
        subject.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        subject.footerHeight = footerHeight
        subject.content = content
        subject.setOverlay(overlay, forDirection: .left)
      }

      context("and there is a footer") {
        let footer = UIView()

        beforeEach {
          subject.footer = footer
        }

        context("and the footer is opaque") {
          beforeEach {
            footer.isOpaque = true
            subject.layoutSubviews()
          }

          it("should correctly layout the footer") {
            let expectedFrame = CGRect(x: 0, y: cardHeight - footerHeight, width: cardWidth, height: footerHeight)
            expect(footer.frame) == expectedFrame
          }

          it("should layout the content above the footer") {
            let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
            expect(content.frame) == expectedFrame
          }

          it("the overlays should be laid out above the footer") {
            let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
            expect(overlay.frame) == expectedFrame
          }
        }

        context("and the footer is not opaque") {
          beforeEach {
            footer.isOpaque = false
            subject.layoutSubviews()
          }

          it("should correctly layout the footer") {
            let expectedFrame = CGRect(x: 0, y: cardHeight - footerHeight, width: cardWidth, height: footerHeight)
            expect(footer.frame) == expectedFrame
          }

          it("should layout the content behind the footer") {
            let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
            expect(content.frame) == expectedFrame
          }

          it("the overlays should be laid out above the footer") {
            let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
            expect(overlay.frame) == expectedFrame
          }
        }
      }

      context("and there is no footer") {
        beforeEach {
          subject.footer = nil
          subject.layoutSubviews()
        }

        it("the content should be laid out over the entire card") {
          let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
          expect(content.frame) == expectedFrame
        }

        it("the overlays should be laid out over the entire card") {
          let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
          expect(overlay.frame) == expectedFrame
        }
      }
    }

    // MARK: - Overlay Percentage

    describe("When calling overlayPercentage") {
      context("and there is no active direction") {
        beforeEach {
          subject.testActiveDirection = nil
        }

        it("should return zero") {
          expect(subject.swipeOverlayPercentage(forDirection: .left)) == 0
        }
      }

      context("and the drag percentage is nonzero in exactly one direction") {
        let dragPercentage: CGFloat = 0.1

        beforeEach {
          subject.testDragPercentage[.left] = dragPercentage
        }

        it("should return the drag percentage in the dragged direction") {
          let actualPercentage = subject.swipeOverlayPercentage(forDirection: .left)
          expect(actualPercentage) == dragPercentage
        }

        it("should return zero for all other directions") {
          for direction in [SwipeDirection.up, .right, .down] {
            let actualPercentage = subject.swipeOverlayPercentage(forDirection: direction)
            expect(actualPercentage) == 0
          }
        }
      }

      context("and the card is dragged in a direction below its minimum swipe distance") {
        let direction = SwipeDirection.left
        let dragPercentage: CGFloat = 0.99

        beforeEach {
          subject.testDragPercentage[direction] = dragPercentage
        }

        it("should return a value less than 1 that direction") {
          let expectedPercentage: CGFloat = subject.swipeOverlayPercentage(forDirection: direction)
          expect(expectedPercentage) == dragPercentage
        }
      }

      context("and the card is dragged in a direction at least its minimum swipe distance") {
        let direction = SwipeDirection.left

        beforeEach {
          subject.testDragPercentage[direction] = 1.5
        }

        it("should return 1 in that direction") {
          let expectedPercentage: CGFloat = subject.swipeOverlayPercentage(forDirection: direction)
          expect(expectedPercentage) == 1
        }
      }

      context("and the card is dragged in more than one direction") {
        let direction1 = SwipeDirection.left
        let direction2 = SwipeDirection.up

        context("and the drag percentage in the two directions are equal") {
          beforeEach {
            subject.testDragPercentage[direction1] = 0.1
            subject.testDragPercentage[direction2] = 0.1
          }

          it("should return zero for both directions") {
            expect(subject.swipeOverlayPercentage(forDirection: direction1)) == 0
            expect(subject.swipeOverlayPercentage(forDirection: direction2)) == 0
          }
        }

        context("and the drag percentage in the two directions are not equal") {
          let largerPercentage: CGFloat = 0.4
          let smallerPercentage: CGFloat = 0.1

          beforeEach {
            subject.testDragPercentage[direction1] = largerPercentage
            subject.testDragPercentage[direction2] = smallerPercentage
          }

          it("should return the difference of percentages for the larger direction and zero for the other") {
            let direction1Percentage = subject.swipeOverlayPercentage(forDirection: direction1)
            let direction2Percentage = subject.swipeOverlayPercentage(forDirection: direction2)

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
          let actualRotationAngle = subject.swipeRotationAngle()
          expect(actualRotationAngle) == 0
        }
      }

      for rotationDirection in [CGFloat(-1), CGFloat(1)] {
        context("When the card is dragged horizontally") {
          let maximumRotationAngle = CGFloat.pi / 4

          beforeEach {
            subject.testSwipeRotationDirectionY = rotationDirection
            subject.animationOptions.maximumRotationAngle = maximumRotationAngle
          }

          context("and less than the screen's width") {
            let translation = CGPoint(x: SwipeDirection.left.vector.dx * (UIScreen.main.bounds.width - 1), y: 0)

            beforeEach {
              testPanGestureRecognizer.performPan(withLocation: nil,
                                                  translation: translation,
                                                  velocity: nil)
            }

            it("should return a rotation angle less than the maximum rotation angle") {
              let actualRotationAngle = subject.swipeRotationAngle()
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
              let actualRotationAngle = subject.swipeRotationAngle()
              expect(abs(actualRotationAngle)) == maximumRotationAngle
            }
          }
        }
      }
    }

    // MARK: - Rotation Direction Y

    describe("When calling the swipeRotationDirectionY method") {
      context("and the touch point is nil") {
        it("should return zero") {
          expect(subject.swipeRotationDirectionY()) == 0
        }
      }

      context("and the touch location is in the first quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
          subject.testTouchLocation = location
        }

        it("should return 1") {
          expect(subject.swipeRotationDirectionY()) == 1
        }
      }

      context("and the touch location is in the second quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
          subject.testTouchLocation = location
        }

        it("should return 1") {
          expect(subject.swipeRotationDirectionY()) == 1
        }
      }

      context("and the touch location is in the third quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
          subject.testTouchLocation = location
        }

        it("should return -1") {
          expect(subject.swipeRotationDirectionY()) == -1
        }
      }

      context("and the touch location is in the fourth quadrant of the card's bounds") {
        beforeEach {
          let location = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
          subject.testTouchLocation = location
        }

        it("should return -1") {
          expect(subject.swipeRotationDirectionY()) == -1
        }
      }
    }

    // MARK: - Transform

    describe("When calling transform") {
      let rotationAngle = CGFloat.pi / 4
      let translation = CGPoint(x: 100, y: 100)

      beforeEach {
        subject.testSwipeRotationAngle = rotationAngle
        testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil)
      }

      it("should return the transform with the proper rotation and translation") {
        let expectedTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
          .concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        expect(subject.swipeTransform()) == expectedTransform
      }
    }
  }
}
// swiftlint:enable closure_body_length function_body_length implicitly_unwrapped_optional
