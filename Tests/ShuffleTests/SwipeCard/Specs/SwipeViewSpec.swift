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
class SwipeViewSpec: QuickSpec {

  override func spec() {
    var subject: TestableSwipeView!
    var testPanGestureRecognizer: PanGestureRecognizer!
    var testTapGestureRecognizer: TapGestureRecognizer!

    beforeEach {
      subject = TestableSwipeView()
      testPanGestureRecognizer = subject.panGestureRecognizer as? PanGestureRecognizer
      testTapGestureRecognizer = subject.tapGestureRecognizer as? TapGestureRecognizer
    }

    // MARK: - Initialization

    describe("Initialization") {
      var swipeView: SwipeView!

      describe("When initializing a new swipe view with the default initializer") {
        beforeEach {
          swipeView = SwipeView()
        }

        it("should have the correct default properties") {
          testDefaultProperties()
        }
      }

      describe("When initializing a new swipe view with the required initializer") {
        beforeEach {
          // TODO: - Find a non-deprecated way to accomplish this
          let coder = NSKeyedUnarchiver(forReadingWith: Data())
          swipeView = SwipeView(coder: coder)
        }

        it("should have the correct default properties") {
          testDefaultProperties()
        }
      }

      func testDefaultProperties() {
        expect(swipeView.swipeDirections) == SwipeDirection.allDirections
        expect(swipeView.tapGestureRecognizer).toNot(beNil())
        expect(swipeView.panGestureRecognizer).toNot(beNil())
      }
    }

    // MARK: - Active Direction

    describe("When calling activeDirection") {
      let minimumSwipeDistance: CGFloat = 100

      beforeEach {
        subject.minSwipeDistance = minimumSwipeDistance
      }

      context("and the drag percentage is zero in all directions") {
        beforeEach {
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: .zero,
                                              velocity: nil)
        }

        it("should return nil") {
          expect(subject.activeDirection()).to(beNil())
        }
      }

      context("and the drag percentage is nonzero in exactly one direction") {
        let direction = SwipeDirection.left

        beforeEach {
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: CGPoint(direction.vector),
                                              velocity: nil)
        }

        it("should return the correct direction") {
          expect(subject.activeDirection()) == direction
        }
      }

      context("and the drag percentage is nonzero in exactly two directions") {
        let direction1 = SwipeDirection.left
        let direction2 = SwipeDirection.up

        beforeEach {
          let direction1Translation = 2 * direction1.vector * minimumSwipeDistance
          let direction2Translation = direction2.vector * minimumSwipeDistance
          let translation = direction1Translation + direction2Translation
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: CGPoint(translation),
                                              velocity: nil)
        }

        it("should return the direction with the highest drag percentage") {
          expect(subject.activeDirection()) == direction1
        }
      }
    }

    // MARK: - Drag Speed

    for direction in SwipeDirection.allDirections {
      describe("When calling dragSpeed with the specified direction") {
        beforeEach {
          let velocity = direction.vector
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: nil,
                                              velocity: CGPoint(velocity))
        }

        it("should return a positive drag speed") {
          expect(subject.dragSpeed(on: direction)) > 0
        }
      }
    }

    // MARK: - Drag Percentage

    describe("When calling the dragPercentage") {
      let minimumSwipeDistance: CGFloat = 100
      let swipeFactor: CGFloat = 0.5
      let direction = SwipeDirection.left

      beforeEach {
        subject.minSwipeDistance = minimumSwipeDistance
        let translation = swipeFactor * minimumSwipeDistance * direction.vector
        testPanGestureRecognizer.performPan(withLocation: nil,
                                            translation: CGPoint(translation),
                                            velocity: nil)
      }

      it("should return the correct drag percentage") {
        let actualPercentage = subject.dragPercentage(on: direction)
        expect(actualPercentage) == swipeFactor
      }
    }

    // MARK: - Minimum Swipe Speed

    describe("When calling minimumSwipeSpeed") {
      it("should return 1100") {
        expect(subject.minimumSwipeSpeed(on: .left)) == 1100
      }
    }

    // MARK: - Minimum Swipe Distance

    describe("When calling minimumSwipeDistance") {
      it("should return UIScreen.main.bounds.width / 4") {
        let expectedDistance = subject.minimumSwipeDistance(on: .left)
        expect(expectedDistance) == UIScreen.main.bounds.width / 4
      }
    }

    // MARK: - Tap Gesture

    describe("When a tap gesture is recognized") {
      beforeEach {
        testTapGestureRecognizer.performTap(withLocation: .zero)
      }

      it("should call the didTap method") {
        expect(subject.didTapCalled) == true
      }
    }

    // MARK: - Pan Gesture

    describe("Pan Gesture") {
      for state in [UIPanGestureRecognizer.State.began, UIPanGestureRecognizer.State.possible] {
        describe("When a .began or .possible  pan gesture state is recognized") {
          beforeEach {
            testPanGestureRecognizer.performPan(withLocation: nil,
                                                translation: nil,
                                                velocity: nil,
                                                state: state)
          }

          it("should call the beginSwiping method") {
            expect(subject.beginSwipingCalled) == true
          }
        }
      }

      describe("When a .change pan gesture state is recognized") {
        beforeEach {
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: nil,
                                              velocity: nil,
                                              state: .changed)
        }

        it("should call the continueSwiping method") {
          expect(subject.continueSwipingCalled) == true
        }
      }

      for state in [UIPanGestureRecognizer.State.ended, UIPanGestureRecognizer.State.cancelled] {
        describe("When an .ended or .cancelled pan gesture state is recognized") {
          beforeEach {
            testPanGestureRecognizer.performPan(withLocation: nil,
                                                translation: nil,
                                                velocity: nil,
                                                state: state)
          }

          it("should call the endSwiping method") {
            expect(subject.endSwipingCalled) == true
          }
        }
      }

      describe("When a .failed gesture state is recognized") {
        beforeEach {
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: nil,
                                              velocity: nil,
                                              state: .failed)
        }

        it("should call not call any of the swipe methods") {
          expect(subject.beginSwipingCalled) == false
          expect(subject.continueSwipingCalled) == false
          expect(subject.endSwipingCalled) == false
        }
      }
    }

    // MARK: - End Swiping

    describe("When endSwiping is called") {
      let minimumSwipeDistance: CGFloat = 100
      let minimumSwipeSpeed: CGFloat = 500
      let direction: SwipeDirection = .left

      beforeEach {
        subject.minSwipeDistance = minimumSwipeDistance
        subject.minSwipeSpeed = minimumSwipeSpeed
      }

      context("and there is no active direction") {
        beforeEach {
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: nil,
                                              velocity: nil)
          subject.endSwiping(testPanGestureRecognizer)
        }

        it("should call the didCancelSwipe method and not the didSwipe method") {
          expect(subject.didCancelSwipeCalled) == true
          expect(subject.didSwipeCalled) == false
        }
      }

      context("and the swipe translation is less than the minimum swipe distance") {
        beforeEach {
          let translation = CGPoint((minimumSwipeDistance / 2) * direction.vector)
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: translation,
                                              velocity: nil)
          subject.endSwiping(testPanGestureRecognizer)
        }

        it("should call the didCancelSwipe method and not the didSwipe method") {
          expect(subject.didCancelSwipeCalled) == true
          expect(subject.didSwipeCalled) == false
        }
      }

      context("and the swipe translation is at least the minimum swipe distance") {
        beforeEach {
          let translation = CGPoint(minimumSwipeDistance * direction.vector)
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: translation,
                                              velocity: nil)
          subject.endSwiping(testPanGestureRecognizer)
        }

        it("should call the didSwipe method with the correct direction") {
          expect(subject.didSwipeCalled) == true
          expect(subject.didSwipeDirection) == direction
        }

        it("should not call the didCancelSwipe method") {
          expect(subject.didCancelSwipeCalled) == false
        }
      }

      context("and the swipe speed is less than the minimum swipe speed") {
        beforeEach {
          let velocity = CGPoint(x: direction.vector.dx * (minimumSwipeSpeed - 1),
                                 y: direction.vector.dy * (minimumSwipeSpeed - 1))
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: CGPoint(direction.vector),
                                              velocity: velocity)
          subject.endSwiping(testPanGestureRecognizer)
        }

        it("should call the didCancelSwipe method and not the didSwipe method") {
          expect(subject.didCancelSwipeCalled) == true
          expect(subject.didSwipeCalled) == false
        }
      }

      context("and the swipe speed is at least the minimum swipe speed") {
        beforeEach {
          let velocity = CGPoint(x: direction.vector.dx * minimumSwipeSpeed,
                                 y: direction.vector.dy * minimumSwipeSpeed)
          testPanGestureRecognizer.performPan(withLocation: nil,
                                              translation: CGPoint(direction.vector),
                                              velocity: velocity)
          subject.endSwiping(testPanGestureRecognizer)
        }

        it("should call the didSwipe method with the correct direction") {
          expect(subject.didSwipeCalled) == true
          expect(subject.didSwipeDirection) == direction
        }

        it("should not call the didCancelSwipe delegate method") {
          expect(subject.didCancelSwipeCalled) == false
        }
      }
    }
  }
}
// swiftlint:enable closure_body_length function_body_length implicitly_unwrapped_optional
