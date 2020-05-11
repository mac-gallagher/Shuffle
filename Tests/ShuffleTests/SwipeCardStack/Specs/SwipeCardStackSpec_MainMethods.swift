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

class SwipeCardStackSpec_MainMethods: QuickSpec {

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
      let direction: SwipeDirection = .left
      let animated: Bool = false

      var topCard: TestableSwipeCard!

      beforeEach {
        topCard = TestableSwipeCard()
        subject.testTopCard = topCard
      }

      context("and isEnabled is false") {
        beforeEach {
          subject.testIsEnabled = false
          subject.swipe(direction, animated: animated)
        }

        it("should not call the top card's swipe method") {
          expect(topCard.swipeCalled).to(beFalse())
        }
      }

      context("and isEnabled is true") {
        beforeEach {
          subject.testIsEnabled = true
          subject.swipe(direction, animated: animated)
        }

        it("should call the top card's swipe method with the correct parameters") {
          expect(topCard.swipeCalled).to(beTrue())
          expect(topCard.swipeAnimated).to(equal(animated))
          expect(topCard.swipeDirection).to(equal(direction))
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

        context("and the state manager has at least one previous swipe") {
          let index: Int = 3
          let direction: SwipeDirection = .left
          let animated: Bool = false

          beforeEach {
            mockStateManager.undoSwipeSwipe = Swipe(index, direction)
            subject.undoLastSwipe(animated: false)
          }

          it("should call the reloadVisibleCards method") {
            expect(subject.reloadVisibleCardsCalled).to(beTrue())
          }

          it("should call the didUndoCardAt delegate method with the correct parameters") {
            expect(mockDelegate.didUndoCardAtCalled).to(beTrue())
            expect(mockDelegate.didUndoCardAtIndex).to(equal(index))
            expect(mockDelegate.didUndoCardAtDirection).to(equal(direction))
          }

          it("should call the reverseSwipe method on the new topCard with the correct parameters") {
            expect(topCard.reverseSwipeCalled).to(beTrue())
            expect(topCard.reverseSwipeAnimated).to(equal(animated))
            expect(topCard.reverseSwipeDirection).to(equal(direction))
          }
        }
      }

      func testNoUndoAction() {
        expect(mockDelegate.didUndoCardAtCalled).to(beFalse())
        expect(subject.reloadVisibleCardsCalled).to(beFalse())
        expect(topCard.reverseSwipeCalled).to(beFalse())
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

        for animated in [false, true] {
          context("and distance is greater than zero and there are at least two visible cards") {
            let distance: Int = 2

            beforeEach {
              mockStateManager.remainingIndices = [1, 2, 3]
              subject.isUserInteractionEnabled = false
              subject.visibleCards = [SwipeCard(), SwipeCard()]
              subject.shift(withDistance: distance, animated: animated)
            }

            it("should call the state manager's shift method with the correct distance") {
              expect(mockStateManager.shiftCalled).to(beTrue())
              expect(mockStateManager.shiftDistance).to(equal(distance))
            }

            it("it should call the reloadVisibleCards method") {
              expect(subject.reloadVisibleCardsCalled).to(beTrue())
            }

            if animated {
              it("should disable user interaction and call the animator's shift method with the correct parameters") {
                expect(subject.isUserInteractionEnabled).to(beFalse())
                expect(mockAnimator.animateShiftCalled).to(beTrue())
                expect(mockAnimator.animateShiftDistance).to(equal(distance))
              }
            } else {
              it("should not call the animator's shift method") {
                expect(mockAnimator.animateShiftCalled).to(beFalse())
              }
            }
          }
        }
      }
    }

    func testNoShiftAction() {
      expect(subject.reloadVisibleCardsCalled).to(beFalse())
      expect(mockAnimator.animateShiftCalled).to(beFalse())
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
          expect(subject.reloadVisibleCardsCalled).to(beFalse())
        }

        it("should not call the reset method on the state manager") {
          expect(mockStateManager.resetCalled).to(beFalse())
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
          expect(mockDataSource.numberOfCardsCalled).to(beTrue())
        }

        it("should call the reset method on the state manager with the correct number cards") {
          expect(mockStateManager.resetCalled).to(beTrue())
          expect(mockStateManager.resetNumberOfCards).to(equal(numberOfCards))
        }

        it("should call the reloadVisibleCards method") {
          expect(subject.reloadVisibleCardsCalled).to(beTrue())
        }

        it("should enable user interaction on the card stack") {
          expect(subject.isUserInteractionEnabled).to(beTrue())
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

      var cardContainer: UIView!

      beforeEach {
        cardContainer = subject.subviews.first!
        for _ in 0..<numberOfCards {
          cardContainer.addSubview(SwipeCard())
          subject.visibleCards.append(SwipeCard())
        }
        subject.insertCard(card, at: index)
      }

      it("should insert the card at the correct level in the card container's view hierarchy") {
        expect(cardContainer.subviews[numberOfCards - index]).to(equal(card))
      }

      it("should call layoutCard with the correct parameters") {
        expect(subject.layoutCardCalled).to(beTrue())
        expect(subject.layoutCardIndices).to(equal([index]))
        expect(subject.layoutCardCards).to(equal([card]))
      }

      it("should insert the card at the correct index of the visibleCard variable") {
        expect(subject.visibleCards[index]).to(equal(card))
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
          expect(actualCard).to(equal(expectedCard))
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
