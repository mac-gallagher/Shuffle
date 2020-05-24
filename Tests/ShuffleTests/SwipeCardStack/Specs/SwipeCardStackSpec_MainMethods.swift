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
// swiftlint:disable:next type_body_length
class SwipeCardStackSpec_MainMethods: QuickSpec {

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
      let topCard = SwipeCard()
      let forced = false
      let animated = false

      context("and topIndex is nil") {
        beforeEach {
          subject.testTopCardIndex = nil
          subject.visibleCards = [topCard]
          subject.swipeAction(topCard: topCard,
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
            subject.testSwipeCompletionBlock = {}
            subject.visibleCards = [topCard, SwipeCard()]
            subject.testLoadCard = testLoadCard
            subject.swipeAction(topCard: topCard,
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
            expect(subject.insertCardIndex) == numberOfVisibleCards - 1
          }
        }

        context("and there are no more cards to load") {
          beforeEach {
            mockStateManager.remainingIndices = [1, 2]
            subject.testSwipeCompletionBlock = {}
            subject.visibleCards = [topCard, SwipeCard(), SwipeCard()]
            subject.swipeAction(topCard: topCard,
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
            subject.testSwipeCompletionBlock = {}
            subject.visibleCards = [topCard]
            subject.swipeAction(topCard: topCard,
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
            expect(subject.visibleCards.contains(topCard)) == false
          }

          it("should disable user interaction") {
            expect(subject.isUserInteractionEnabled) == false
          }

          it("should call the animator's swipe method with the correct parameters") {
            expect(mockAnimator.animateSwipeCalled) == true
            expect(mockAnimator.animateSwipeTopCard) == topCard
            expect(mockAnimator.animateSwipeForced) == forced
            expect(mockAnimator.animateSwipeAnimated) == animated
            expect(mockAnimator.animateSwipeDirection) == direction
          }

          it("should call the swipeCompletionBlock once the animation has completed") {
            expect(subject.swipeCompletionBlockCalled) == true
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
              mockStateManager.undoSwipeSwipe = Swipe(previousSwipeIndex, previousSwipeDirection)
              subject.testUndoCompletionBlock = {}
              subject.undoLastSwipe(animated: animated)
            }

            it("should disable user interaction") {
              expect(subject.isUserInteractionEnabled) == false
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

              it("should invoke the undoCompletionBlock once the animation has completed") {
                expect(subject.undoCompletionBlockCalled) == true
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
              subject.visibleCards = [SwipeCard()]
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
            subject.testShiftCompletionBlock = {}
            subject.visibleCards = [SwipeCard(), SwipeCard()]
            subject.shift(withDistance: distance, animated: animated)
          }

          it("should disable user interaction") {
            expect(subject.isUserInteractionEnabled) == false
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

          it("should call the shiftCompletionBlock once the animation has completed") {
            expect(subject.shiftCompletionBlockCalled) == true
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
          subject.isUserInteractionEnabled = false
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

        it("should enable user interaction on the card stack") {
          expect(subject.isUserInteractionEnabled) == true
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
      let card = SwipeCard()
      let index: Int = 3

      var cardContainer: UIView?

      beforeEach {
        cardContainer = subject.subviews.first
        for _ in 0..<numberOfCards {
          cardContainer?.addSubview(SwipeCard())
          subject.visibleCards.append(SwipeCard())
        }
        subject.insertCard(card, at: index)
      }

      it("should insert the card at the correct level in the card container's view hierarchy") {
        expect(cardContainer?.subviews[numberOfCards - index]) == card
      }

      it("should call layoutCard with the correct parameters") {
        expect(subject.layoutCardCalled) == true
        expect(subject.layoutCardIndices) == [index]
        expect(subject.layoutCardCards) == [card]
      }

      it("should insert the card at the correct index of the visibleCard variable") {
        expect(subject.visibleCards[index]) == card
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
// swiftlint:enable closure_body_length implicitly_unwrapped_optional
