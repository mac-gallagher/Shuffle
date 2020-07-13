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

// swiftlint:disable type_body_length closure_body_length implicitly_unwrapped_optional
class SwipeCardStackSpec_MainMethods: QuickSpec {

  typealias Card = SwipeCardStack.Card

  // swiftlint:disable:next function_body_length
  override func spec() {
    var mockAnimator: MockCardStackAnimator!
    var mockDelegate: MockSwipeCardStackDelegate!
    var mockStateManager: MockCardStackStateManager!
    var subject: TestableSwipeCardStack!

    beforeEach {
      mockAnimator = MockCardStackAnimator()
      mockDelegate = MockSwipeCardStackDelegate()
      mockStateManager = MockCardStackStateManager()
      subject = TestableSwipeCardStack(animator: mockAnimator,
                                       layoutProvider: MockCardStackLayoutProvider(),
                                       notificationCenter: NotificationCenter.default,
                                       stateManager: mockStateManager,
                                       transformProvider: MockCardStackTransformProvider())
      subject.delegate = mockDelegate
    }

    // MARK: - Swipe

    describe("When calling swipe") {
      context("and isEnabled is false") {
        beforeEach {
          subject.testIsEnabled = false
          subject.swipe(.left, animated: false)
        }

        it("should not call swipeAction") {
          expect(subject.swipeActionCalled) == false
        }
      }

      for animated in [false, true] {
        context("and isEnabled is true and topCard is not nil") {
          let topCard = TestableSwipeCard()
          let direction = SwipeDirection.left
          let superview = UIView()

          beforeEach {
            subject.testTopCard = topCard
            subject.testIsEnabled = true
            superview.addSubview(topCard)
            subject.swipe(direction, animated: animated)
          }

          if animated {
            it("should call the top card's swipe method with the correct direction") {
              expect(topCard.swipeCalled) == true
              expect(topCard.swipeDirection) == direction
            }
          } else {
            it("remove the topCard from it's superview") {
              expect(topCard.superview).to(beNil())
            }
          }

          it("should call swipeAction with the correct parameters") {
            expect(subject.swipeActionCalled) == true
            expect(subject.swipeActionDirection) == direction
            expect(subject.swipeActionForced) == true
          }
        }
      }
    }

    // MARK: - Swipe Action

    describe("When calling swipeAction") {
      let direction: SwipeDirection = .left
      let topCard = Card(index: 0, card: SwipeCard())
      let forced = false
      let animated = false

      context("and topIndex is nil") {
        beforeEach {
          subject.testTopCardIndex = nil
          subject.swipeAction(topCard: topCard.card,
                              direction: direction,
                              forced: forced,
                              animated: animated)
        }

        it("it should not call the didSwipeCardAtDelegate method") {
          expect(mockDelegate.didSwipeCardAtCalled) == false
        }

        it("it should not call the animator's animateSwipe method") {
          expect(mockAnimator.animateSwipeCalled) == false
        }
      }

      context("and topIndex is not nil") {
        let topCardIndex: Int = 2

        beforeEach {
          subject.testTopCardIndex = topCardIndex
        }

        context("and there is at least one more card to load") {
          let testLoadCard = SwipeCard()
          let numberOfVisibleCards: Int = 2
          let remainingIndices = [0, 1, 2]

          beforeEach {
            mockStateManager.remainingIndices = remainingIndices
            subject.visibleCards = [topCard, Card(index: 1, card: SwipeCard())]
            subject.testLoadCard = testLoadCard
            subject.swipeAction(topCard: topCard.card,
                                direction: direction,
                                forced: forced,
                                animated: animated)
          }

          testSwipeAction()

          it("should not call the didSwipeAllCards delegate method") {
            expect(mockDelegate.didSwipeAllCardsCalled) == false
          }

          it("should load the card from the correct data source index") {
            expect(subject.loadCardCalled) == true
            expect(subject.loadCardCalledIndex) == remainingIndices[numberOfVisibleCards - 1]
          }

          it("should insert the loaded card at the correct index in the card stack") {
            expect(subject.insertCardCalled) == true
            expect(subject.insertCardCard) == testLoadCard
            expect(subject.insertCardPosition) == numberOfVisibleCards - 1
          }
        }

        context("and there are no more cards to load") {
          beforeEach {
            mockStateManager.remainingIndices = [1, 2]
            subject.visibleCards = [topCard,
                                    Card(index: 1, card: SwipeCard()),
                                    Card(index: 2, card: SwipeCard())]
            subject.swipeAction(topCard: topCard.card,
                                direction: direction,
                                forced: forced,
                                animated: animated)
          }

          testSwipeAction()

          it("should not call the didSwipeAllCards delegate method") {
            expect(mockDelegate.didSwipeAllCardsCalled) == false
          }

          it("not load a new card") {
            expect(subject.loadCardCalled) == false
          }
        }

        context("and there are no more cards to swipe") {
          beforeEach {
            mockStateManager.remainingIndices = []
            subject.visibleCards = [topCard]
            subject.swipeAction(topCard: topCard.card,
                                direction: direction,
                                forced: forced,
                                animated: animated)
          }

          it("should call the didSwipeAllCards delegate method") {
            expect(mockDelegate.didSwipeAllCardsCalled) == true
          }
        }

        func testSwipeAction() {
          it("should call the didSwipeCardAt delegate method with the correct parameters") {
            expect(mockDelegate.didSwipeCardAtCalled) == true
            expect(mockDelegate.didSwipeCardAtIndex) == topCardIndex
            expect(mockDelegate.didSwipeCardAtDirection) == direction
          }

          it("should call the state manager's swipe method with the correct direction") {
            expect(mockStateManager.swipeCalled) == true
            expect(mockStateManager.swipeDirection) == direction
          }

          it("should remove the top card from visibleCards") {
            expect(subject.visibleCards[0].index) != topCard.index
            expect(subject.visibleCards[0].card) != topCard.card
          }

          it("should call the animator's swipe method with the correct parameters") {
            expect(mockAnimator.animateSwipeCalled) == true
            expect(mockAnimator.animateSwipeTopCard) == topCard.card
            expect(mockAnimator.animateSwipeForced) == forced
            expect(mockAnimator.animateSwipeAnimated) == animated
            expect(mockAnimator.animateSwipeDirection) == direction
          }
        }
      }
    }

    // MARK: - Undo Last Swipe

    describe("When calling undoLastSwipe") {
      var topCard: TestableSwipeCard!

      beforeEach {
        topCard = TestableSwipeCard()
        subject.testTopCard = topCard
      }

      context("and isEnabled is false") {
        beforeEach {
          subject.testIsEnabled = false
          subject.undoLastSwipe(animated: false)
        }

        it("should not trigger an undo action") {
          testNoUndoAction()
        }
      }

      context("and isEnabled is true") {
        beforeEach {
          subject.testIsEnabled = true
        }

        context("and the state manager does not have a previous swipe") {
          beforeEach {
            mockStateManager.undoSwipeSwipe = nil
            subject.undoLastSwipe(animated: false)
          }

          it("should not trigger an undo action") {
            testNoUndoAction()
          }
        }

        for animated in [false, true] {
          context("and the state manager has at least one previous swipe") {
            let previousSwipeIndex: Int = 3
            let previousSwipeDirection: SwipeDirection = .left

            beforeEach {
              mockStateManager.undoSwipeSwipe = Swipe(index: previousSwipeIndex,
                                                      direction: previousSwipeDirection)
              subject.undoLastSwipe(animated: animated)
            }

            it("should call the reloadVisibleCards method") {
              expect(subject.reloadVisibleCardsCalled) == true
            }

            it("should call the didUndoCardAt delegate method with the correct parameters") {
              expect(mockDelegate.didUndoCardAtCalled) == true
              expect(mockDelegate.didUndoCardAtIndex) == previousSwipeIndex
              expect(mockDelegate.didUndoCardAtDirection) == previousSwipeDirection
            }

            it("should call the animator's animateUndo method with the correct parameters") {
              expect(mockAnimator.animateUndoCalled) == true
              expect(mockAnimator.animateUndoTopCard) == topCard
              expect(mockAnimator.animateUndoAnimated) == animated
            }

            if animated {
              it("should call the reverseSwipe method on the new topCard with the correct parameters") {
                expect(topCard.reverseSwipeCalled) == true
                expect(topCard.reverseSwipeDirection) == previousSwipeDirection
              }
            }
          }
        }
      }

      func testNoUndoAction() {
        expect(mockDelegate.didUndoCardAtCalled) == false
        expect(subject.reloadVisibleCardsCalled) == false
        expect(topCard.reverseSwipeCalled) == false
      }
    }

    // MARK: - Shift

    describe("When calling shift") {
      context("and isEnabled is false") {
        beforeEach {
          subject.testIsEnabled = false
          subject.shift(withDistance: 0, animated: false)
        }

        it("should not trigger a shift action") {
          testNoShiftAction()
        }
      }

      context("and isEnabled is true") {
        beforeEach {
          subject.testIsEnabled = true
        }

        context("and distance is zero") {
          beforeEach {
            subject.shift(withDistance: 0, animated: false)
          }

          it("should not trigger a shift action") {
            testNoShiftAction()
          }
        }

        context("and the distance is greater than zero") {
          context("and there are less than two visible cards") {
            beforeEach {
              subject.visibleCards = [Card(index: 0, card: SwipeCard())]
              subject.shift(withDistance: 1, animated: false)
            }

            it("should not trigger a shift action") {
              testNoShiftAction()
            }
          }
        }

        context("and distance is greater than zero and there are at least two visible cards") {
          let distance: Int = 2
          let animated: Bool = false

          beforeEach {
            mockStateManager.remainingIndices = [1, 2, 3]
            subject.visibleCards = [Card(index: 0, card: SwipeCard()),
                                    Card(index: 0, card: SwipeCard())]
            subject.shift(withDistance: distance, animated: animated)
          }

          it("should call the state manager's shift method with the correct distance") {
            expect(mockStateManager.shiftCalled) == true
            expect(mockStateManager.shiftDistance) == distance
          }

          it("it should call the reloadVisibleCards method") {
            expect(subject.reloadVisibleCardsCalled) == true
          }

          it("should call the animator's shift method with the correct parameters") {
            expect(mockAnimator.animateShiftCalled) == true
            expect(mockAnimator.animateShiftDistance) == distance
            expect(mockAnimator.animateShiftAnimated) == animated
          }
        }
      }
    }

    func testNoShiftAction() {
      expect(subject.reloadVisibleCardsCalled) == false
      expect(mockAnimator.animateShiftCalled) == false
    }

    // MARK: - Data Source

    // MARK: Reload Data

    context("When calling reloadData") {
      afterEach {
        subject.resetReloadData()
      }

      context("and there is no dataSource") {
        beforeEach {
          subject.reloadData()
        }

        it("should not call the reloadVisibleCards method") {
          expect(subject.reloadVisibleCardsCalled) == false
        }

        it("should not call the reset method on the state manager") {
          expect(mockStateManager.resetCalled) == false
        }
      }

      context("and there is a dataSource") {
        let numberOfCards: Int = 10
        var mockDataSource: MockSwipeCardStackDataSource!

        beforeEach {
          mockDataSource = MockSwipeCardStackDataSource()
          mockDataSource.testNumberOfCards = numberOfCards

          subject.dataSource = mockDataSource
          subject.isAnimating = true
          subject.reloadData()
        }

        it("should retrieve the number of cards from the dataSource") {
          expect(mockDataSource.numberOfCardsCalled) == true
        }

        it("should call the reset method on the state manager with the correct number cards") {
          expect(mockStateManager.resetCalled) == true
          expect(mockStateManager.resetNumberOfCards) == numberOfCards
        }

        it("should call the reloadVisibleCards method") {
          expect(subject.reloadVisibleCardsCalled) == true
        }

        it("should set isAnimating to false") {
          expect(subject.isAnimating) == false
        }
      }
    }

    // MARK: Position For Card At Index

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

    // MARK: Reload Visible Cards

    describe("When calling reloadVisibleCards") {
      // TODO
    }

    // MARK: Insert Card

    describe("When calling insertCard") {
      let numberOfCards: Int = 5
      let card = Card(index: 0, card: SwipeCard())
      let position: Int = 3

      var cardContainer: UIView?

      beforeEach {
        cardContainer = subject.subviews.first
        for position in 0..<numberOfCards {
          let pair = Card(index: position, card: SwipeCard())
          cardContainer?.addSubview(pair.card)
          subject.visibleCards.append(pair)
        }
        subject.insertCard(card, at: position)
      }

      it("should insert the card at the correct level in the card container's view hierarchy") {
        expect(cardContainer?.subviews[numberOfCards - position]) == card.card
      }

      it("should call layoutCard with the correct parameters") {
        expect(subject.layoutCardCalled) == true
        expect(subject.layoutCardPositions) == [position]
        expect(subject.layoutCardCards) == [card.card]
      }

      it("should insert the card at the correct position of the visibleCard variable") {
        expect(subject.visibleCards[position].index) == card.index
        expect(subject.visibleCards[position].card) == card.card
      }
    }

    // MARK: Load Card

    describe("When calling loadCard") {
      context("and there is no data source") {
        it("should not return a card") {
          let actualCard = subject.loadCard(at: 0)
          expect(actualCard).to(beNil())
        }
      }

      context("and there is a data source") {
        let numberOfCards: Int = 3
        var dataSource: MockSwipeCardStackDataSource!

        beforeEach {
          dataSource = MockSwipeCardStackDataSource()
          dataSource.testNumberOfCards = numberOfCards
          subject.dataSource = dataSource
        }

        it("should return the correct card and set its delegate") {
          let index: Int = 0

          let actualCard = subject.loadCard(at: index)
          expect(actualCard?.delegate).to(be(subject))

          let expectedCard = dataSource.testCards[index]
          expect(actualCard) == expectedCard
        }
      }
    }

    // MARK: - Did Finish Swipe Animation

    describe("When calling didFinishSwipeAnimation") {
      context("and the notification object is not a SwipeCard") {
        beforeEach {
          let notification = NSNotification(name: CardDidFinishSwipeAnimationNotification,
                                            object: UIView())
          subject.didFinishSwipeAnimation(notification)
        }

        it("should do nothing!") {
          //do nothing
        }
      }

      context("and the notification object is a SwipeCard") {
        let swipeCard = SwipeCard()

        beforeEach {
          let superview = UIView()
          superview.addSubview(swipeCard)

          let notification = NSNotification(name: CardDidFinishSwipeAnimationNotification,
                                            object: swipeCard)
          subject.didFinishSwipeAnimation(notification)
        }

        it("should remove the card from its superview") {
          expect(swipeCard.superview).to(beNil())
        }
      }
    }
  }
}
// swiftlint:enable type_body_length closure_body_length implicitly_unwrapped_optional
