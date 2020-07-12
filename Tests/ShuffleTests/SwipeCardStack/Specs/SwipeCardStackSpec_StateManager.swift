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

// swiftlint:disable closure_body_length implicitly_unwrapped_optional
class SwipeCardStackSpec_StateManager: QuickSpec {

  // swiftlint:disable:next function_body_length
  override func spec() {
    var mockStateManager: MockCardStackStateManager!
    var subject: TestableSwipeCardStack!

    beforeEach {
      mockStateManager = MockCardStackStateManager()
      subject = TestableSwipeCardStack(animator: MockCardStackAnimator(),
                                       layoutProvider: MockCardStackLayoutProvider(),
                                       notificationCenter: NotificationCenter(),
                                       stateManager: mockStateManager,
                                       transformProvider: MockCardStackTransformProvider())
    }

    // MARK: - Card For Index At

    describe("When calling cardForIndexAt") {
      let visibleCards = [Card(0, SwipeCard()), Card(1, SwipeCard())]

      beforeEach {
        subject.visibleCards = visibleCards
      }

      context("and the index does not correspond to a visible card") {
        it("should return nil") {
          let actualCard = subject.card(forIndexAt: 2)
          expect(actualCard).to(beNil())
        }
      }

      context("and the index corresponds to a visible card") {
        it("should return the corresponding visible card") {
          let actualCard = subject.card(forIndexAt: 0)
          expect(actualCard) == visibleCards[0].card
        }
      }
    }

    // MARK: - Position For Card At Index

    describe("When calling positionForCardAtIndex") {
      beforeEach {
        mockStateManager.remainingIndices = [3, 4, 5, 4]
      }

      context("and the index is not contained in the state manager's remaining indices") {
        let index: Int = 2

        it("should return nil") {
          let actualPosition = subject.positionforCard(at: index)
          expect(actualPosition).to(beNil())
        }
      }

      context("and the index is contained in the state manager's remaining indices") {
        let index: Int = 4

        it("should return the first index of the specified position in the state manager's remaining indices") {
          let actualPosition = subject.positionforCard(at: index)
          expect(actualPosition) == 1
        }
      }
    }

    // MARK: - Number of Remaining Cards

    describe("When calling numberOfRemainingCards") {
      beforeEach {
        mockStateManager.remainingIndices = [3, 4, 5, 4]
      }

      it("should return the number of elements in the state manager's remainingIndices") {
        expect(subject.numberOfRemainingCards()) == mockStateManager.remainingIndices.count
      }
    }

    // MARK: - Insert Card At Index

    describe("When calling insertCardAtIndex") {
      let index: Int = 1
      let position: Int = 2

      context("and there is no data source") {
        beforeEach {
          subject.insertCard(atIndex: index, position: position)
        }

        it("should not call the stateManager's insert method or reloadVisibleCards") {
          expect(mockStateManager.insertCalled) == false
          expect(subject.reloadVisibleCardsCalled) == false
        }
      }

      context("and there is a data source") {
        let newNumberOfCards: Int = 10
        var dataSource: MockSwipeCardStackDataSource!

        beforeEach {
          dataSource = MockSwipeCardStackDataSource()
          dataSource.testNumberOfCards = newNumberOfCards
          subject.dataSource = dataSource
        }

        context("and the new number of cards is not equal to the old number of cards plus one") {
          beforeEach {
            mockStateManager.totalIndexCount = newNumberOfCards - 2
          }

          it("should throw a fatal error") {
            expect(subject.insertCard(atIndex: index, position: position)).to(throwAssertion())
          }
        }

        context("and the new number of cards is not equal to the old number of cards plus one") {
          beforeEach {
            mockStateManager.totalIndexCount = newNumberOfCards - 1
            subject.insertCard(atIndex: index, position: position)
          }

          it("should call the stateManager's insert method with the correct parameters") {
            expect(mockStateManager.insertCalled) == true
            expect(mockStateManager.insertIndices) == [index]
            expect(mockStateManager.insertPositions) == [position]
          }

          it("should call reloadVisibleCards") {
            expect(subject.reloadVisibleCardsCalled) == true
          }
        }
      }
    }

    // MARK: - Append Cards

    describe("When calling appendCards") {
      let indices: [Int] = [1, 2, 3]
      let remainingIndices: [Int] = [0, 1, 2, 3, 4]

      beforeEach {
        mockStateManager.remainingIndices = remainingIndices
      }

      context("and there is no data source") {
        beforeEach {
          subject.appendCards(atIndices: indices)
        }

        it("should not call the stateManager's insert method or reloadVisibleCards") {
          expect(mockStateManager.insertCalled) == false
          expect(subject.reloadVisibleCardsCalled) == false
        }
      }

      context("and there is a data source") {
        let newNumberOfCards: Int = 8
        var dataSource: MockSwipeCardStackDataSource!

        beforeEach {
          dataSource = MockSwipeCardStackDataSource()
          dataSource.testNumberOfCards = newNumberOfCards
          subject.dataSource = dataSource
        }

        context("and the new number of cards is not equal to the old number of cards plus the number of new cards") {
          beforeEach {
            mockStateManager.totalIndexCount = newNumberOfCards - 2
          }

          it("should throw a fatal error") {
            expect(subject.appendCards(atIndices: indices)).to(throwAssertion())
          }
        }

        context("and the new number of cards is equal to the old number of cards plus the number of new cards") {
          beforeEach {
            mockStateManager.totalIndexCount = newNumberOfCards - indices.count
            subject.appendCards(atIndices: indices)
          }

          it("should call the stateManager's insert method with the correct parameters") {
            expect(mockStateManager.insertCalled) == true
            expect(mockStateManager.insertIndices) == indices
            expect(mockStateManager.insertPositions) == Array(repeating: remainingIndices.count,
                                                              count: indices.count)
          }

          it("should call reloadVisibleCards") {
            expect(subject.reloadVisibleCardsCalled) == true
          }
        }
      }
    }

    // MARK: - Delete Card

    describe("When calling deleteCard") {
      let index: Int = 2
      let remainingIndices: [Int] = [1, 2, 3]

      beforeEach {
        mockStateManager.remainingIndices = remainingIndices
      }

      context("and there is no data source") {
        beforeEach {
          subject.deleteCard(atIndex: index)
        }

        it("should not call the stateManager's delete method or reloadVisibleCards") {
          expect(mockStateManager.deleteCalled) == false
          expect(subject.reloadVisibleCardsCalled) == false
        }
      }

      context("and there is a data source") {
        let newNumberOfCards: Int = 8
        var dataSource: MockSwipeCardStackDataSource!

        beforeEach {
          dataSource = MockSwipeCardStackDataSource()
          dataSource.testNumberOfCards = newNumberOfCards
          subject.dataSource = dataSource
        }

        context("and the new number of cards is not equal to the old number of cards minus one") {
          beforeEach {
            mockStateManager.totalIndexCount = newNumberOfCards + 2
          }

          it("should throw a fatal error") {
            expect(subject.deleteCard(atIndex: index)).to(throwAssertion())
          }
        }

        context("and the new number of cards is equal to the old number of cards minus one") {
          beforeEach {
            mockStateManager.totalIndexCount = newNumberOfCards + 1
            subject.deleteCard(atIndex: index)
          }

          it("should call the stateManager's delete method with the correct index") {
            expect(mockStateManager.deleteCalled) == true
            expect(mockStateManager.deleteIndex) == index
          }

          it("should call reloadVisibleCards") {
            expect(subject.reloadVisibleCardsCalled) == true
          }
        }
      }
    }
  }
}
// swiftlint:enable closure_body_length implicitly_unwrapped_optional
