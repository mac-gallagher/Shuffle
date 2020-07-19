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

// swiftlint:disable function_body_length closure_body_length implicitly_unwrapped_optional
class CardStackStateManagerSpec: QuickSpec {

  override func spec() {
    var subject: TestableCardStackStateManager!

    beforeEach {
      subject = TestableCardStackStateManager()
    }

    // MARK: - Initialization

    describe("When initializaing a CardStackStateManager object") {
      beforeEach {
        subject = TestableCardStackStateManager()
      }

      it("should have the correct default properties") {
        expect(subject.remainingIndices).to(beEmpty())
        expect(subject.swipes).to(beEmpty())
      }
    }

    // MARK: - Insert

    describe("When calling insert") {
      context("and index is less than zero") {
        let index: Int = -1

        it("should throw a fatal error") {
          expect(subject.insert(index, at: 0)).to(throwAssertion())
        }
      }

      context("and index is greater than totalIndexCount") {
        let index: Int = 5

        beforeEach {
          subject.swipes = [Swipe(index: 0, direction: .left),
                            Swipe(index: 1, direction: .left)]
          subject.remainingIndices = [2, 3]
        }

        it("should throw a fatal error") {
          expect(subject.insert(index, at: 0)).to(throwAssertion())
        }
      }

      context("and position is less than zero") {
        let position: Int = -1

        it("should throw a fatal error") {
          expect(subject.insert(0, at: position)).to(throwAssertion())
        }
      }

      context("and position is greater than the number of remaining indices") {
        let position: Int = 4

        beforeEach {
          subject.remainingIndices = [1, 2, 3]
        }

        it("should throw a fatal error") {
          expect(subject.insert(0, at: position)).to(throwAssertion())
        }
      }

      context("and position and index are within the expected ranges") {
        let oldRemainingIndices: [Int] = [3, 2, 5, 6, 0]
        let oldSwipes = [Swipe(index: 1, direction: .left),
                         Swipe(index: 4, direction: .left),
                         Swipe(index: 7, direction: .left)]
        let index: Int = 4
        let position: Int = 2

        beforeEach {
          subject.remainingIndices = oldRemainingIndices
          subject.swipes = oldSwipes
          subject.insert(index, at: position)
        }

        it("should correctly update the swipes and remaining indices") {
          let expectedSwipes = [Swipe(index: 1, direction: .left),
                                Swipe(index: 5, direction: .left),
                                Swipe(index: 8, direction: .left)]
          expect(subject.swipes) == expectedSwipes

          let expectedRemainingIndices = [3, 2, 4, 6, 7, 0]
          expect(subject.remainingIndices) == expectedRemainingIndices
        }
      }
    }

    // MARK: - Delete Index

    describe("When calling delete:index") {
      context("and index is less than zero") {
        let index: Int = -1

        it("should throw a fatal error") {
          expect(subject.delete(index)).to(throwAssertion())
        }
      }

      context("and index is greater than the totalIndexCount - 1") {
        let index: Int = 4

        beforeEach {
          subject.swipes = [Swipe(index: 0, direction: .left)]
          subject.remainingIndices = [1, 2, 3]
        }

        it("should throw a fatal error") {
          expect(subject.delete(index)).to(throwAssertion())
        }
      }

      context("and index is in the expect range") {
        let oldRemainingIndices: [Int] = [3, 2, 5, 6, 0]
        let oldSwipes = [Swipe(index: 1, direction: .left),
                         Swipe(index: 4, direction: .left),
                         Swipe(index: 7, direction: .left)]

        beforeEach {
          subject.remainingIndices = oldRemainingIndices
          subject.swipes = oldSwipes
        }

        context("and the index has been swiped") {
          let index: Int = 4

          beforeEach {
            subject.delete(index)
          }

          it("should correctly update the swipes and remaining indices") {
            let expectedSwipes = [Swipe(index: 1, direction: .left),
                                  Swipe(index: 6, direction: .left)]
            expect(subject.swipes) == expectedSwipes

            let expectedRemainingIndices = [3, 2, 4, 5, 0]
            expect(subject.remainingIndices) == expectedRemainingIndices
          }
        }

        context("and the index has not been swiped") {
          let index: Int = 2

          beforeEach {
            subject.delete(index)
          }

          it("should correctly update the swipes and remaining indices") {
            let expectedSwipes =  [Swipe(index: 1, direction: .left),
                                   Swipe(index: 3, direction: .left),
                                   Swipe(index: 6, direction: .left)]
            expect(subject.swipes) == expectedSwipes

            let expectedRemainingIndices = [2, 4, 5, 0]
            expect(subject.remainingIndices) == expectedRemainingIndices
          }
        }
      }
    }

    // MARK: - Delete Indices

    describe("When calling delete:indices") {
      let indices: [Int] = [2, 2, 1, 3]

      beforeEach {
        subject.remainingIndices = [3, 2, 4, 0, 1]
        subject.delete(indices)
      }

      it("should remove all duplicate indices") {
        expect(subject.deleteIndices.count) == indices.removingDuplicates().count
      }

      it("should call delete:index with the correct adjusted indices") {
        let expectedDeleteIndices: [Int] = [2, 1, 1]
        expect(subject.deleteIndices) == expectedDeleteIndices
      }
    }

    // MARK: - Delete Index At Position

    describe("When calling delete:indexAtPosition") {
      context("and position is less than zero") {
        let position: Int = -1

        it("should throw a fatal error") {
          expect(subject.delete(indexAtPosition: position)).to(throwAssertion())
        }
      }

      context("and position is greater than the number of remaining indices - 1") {
        let position: Int = 3

        beforeEach {
          subject.remainingIndices = [1, 2, 3]
        }

        it("should throw a fatal error") {
          expect(subject.delete(indexAtPosition: position)).to(throwAssertion())
        }
      }

      context("and position is within the expect range") {
        let oldRemainingIndices: [Int] = [3, 2, 5, 6, 0]
        let oldSwipes = [Swipe(index: 1, direction: .left),
                         Swipe(index: 4, direction: .left),
                         Swipe(index: 7, direction: .left)]
        let position: Int = 2

        beforeEach {
          subject.remainingIndices = oldRemainingIndices
          subject.swipes = oldSwipes
          subject.delete(indexAtPosition: position)
        }

        it("should correctly update the swipes and remaining indices") {
          let expectedSwipes = [Swipe(index: 1, direction: .left),
                                Swipe(index: 4, direction: .left),
                                Swipe(index: 6, direction: .left)]
          expect(subject.swipes) == expectedSwipes

          let expectedRemainingIndices = [3, 2, 5, 0]
          expect(subject.remainingIndices) == expectedRemainingIndices
          expect(subject.remainingIndices.count) == oldRemainingIndices.count - 1
        }
      }
    }

    // MARK: - Delete Indices At Positions

    describe("When calling delete:indicesAtPositions") {
      let positions = [2, 2, 0, 3]

      beforeEach {
        subject.remainingIndices = [3, 2, 5, 6, 0]
        subject.delete(indicesAtPositions: positions)
      }

      it("should remove all duplicate positions") {
        expect(subject.deletePositions.count) == positions.removingDuplicates().count
      }

      it("should call delete:indexAtPosition with the correct adjusted positions") {
        let expectedDeletePositions: [Int] = [2, 0, 1]
        expect(subject.deletePositions) == expectedDeletePositions
      }
    }

    // MARK: - Swipe

    describe("When calling swipe") {
      let direction: SwipeDirection = .left

      context("and there are no remaining indices") {
        beforeEach {
          subject.remainingIndices = []
          subject.swipe(direction)
        }

        it("should not add a new swipe to swipes") {
          expect(subject.swipes).to(beEmpty())
        }
      }

      context("and there is at least one remaining index") {
        let remainingIndices: [Int] = [0, 1, 2]

        beforeEach {
          subject.remainingIndices = remainingIndices
          subject.swipe(direction)
        }

        it("should remove the first index of remainingIndices") {
          let expectedRemainingIndices = Array(remainingIndices.dropFirst())
          expect(subject.remainingIndices) == expectedRemainingIndices
        }
      }
    }

    // MARK: - Undo Swipe

    describe("When calling undoSwipe") {
      let remainingIndices = [0, 1, 2]
      var actualSwipe: Swipe?

      context("and there are no swipes") {
        beforeEach {
          subject.remainingIndices = remainingIndices
          subject.swipes = []
          actualSwipe = subject.undoSwipe()
        }

        it("should return nil") {
          expect(actualSwipe).to(beNil())
        }

        it("should not update the remaining indices") {
          expect(subject.remainingIndices) == remainingIndices
        }
      }

      context("and there is at least one swipe") {
        let swipe = Swipe(index: 5, direction: .left)

        beforeEach {
          subject.swipes = [swipe]
          subject.remainingIndices = remainingIndices
          actualSwipe = subject.undoSwipe()
        }

        it("should return the correct swipe") {
          expect(actualSwipe?.index) == swipe.index
          expect(actualSwipe?.direction) == swipe.direction
        }

        it("should add the swiped index to remaining indices") {
          let expectedRemainingIndices = [swipe.index] + remainingIndices
          expect(subject.remainingIndices) == expectedRemainingIndices
        }
      }
    }

    // MARK: - Shift

    describe("When calling shift") {
      let remainingIndices = [0, 1, 2, 3]

      beforeEach {
        subject.remainingIndices = remainingIndices
        subject.shift(withDistance: 2)
      }

      it("it should correctly shift the remaining indices") {
        let expectedRemainingIndices: [Int] = [2, 3, 0, 1]
        expect(subject.remainingIndices) == expectedRemainingIndices
      }
    }

    // MARK: - Reset

    describe("When calling reset") {
      let numberOfCards: Int = 4

      beforeEach {
        subject.remainingIndices = [2, 3, 4]
        subject.swipes = [Swipe(index: 0, direction: .left),
                          Swipe(index: 1, direction: .up)]
        subject.reset(withNumberOfCards: numberOfCards)
      }

      it("should correctly reset the remaining indices and swipes") {
        expect(subject.remainingIndices) == Array(0..<numberOfCards)
        expect(subject.swipes).to(beEmpty())
      }
    }
  }
}
// swiftlint:enable function_body_length closure_body_length implicitly_unwrapped_optional
