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

class SwipeCardStackSpec_SwipeCardDelegate: QuickSpec {

  override func spec() {
    var mockAnimator: MockCardStackAnimator!
    var mockDelegate: MockSwipeCardStackDelegate!
    var mockStateManager: MockCardStackStateManager!
    var mockTransformProvider: MockCardStackTransformProvider!
    var subject: TestableSwipeCardStack!

    beforeEach {
      mockAnimator = MockCardStackAnimator()
      mockDelegate = MockSwipeCardStackDelegate()
      mockStateManager = MockCardStackStateManager()
      mockTransformProvider = MockCardStackTransformProvider()
      subject = TestableSwipeCardStack(animator: mockAnimator,
                                       layoutProvider: MockCardStackLayoutProvider(),
                                       notificationCenter: NotificationCenter.default,
                                       stateManager: mockStateManager,
                                       transformProvider: mockTransformProvider)
      subject.delegate = mockDelegate
    }

    // MARK: - Did Tap

    describe("When calling didTap") {
      context("and topCardIndex is nil") {
        beforeEach {
          subject.testTopCardIndex = nil
          subject.card(didTap: SwipeCard())
        }

        it("should not call the cardStack's didSelectCard delegate method") {
          expect(mockDelegate.didSelectCardAtCalled).to(beFalse())
        }
      }

      context("and topCardIndex is not nil") {
        let topIndex: Int = 4

        beforeEach {
          subject.testTopCardIndex = topIndex
          subject.card(didTap: SwipeCard())
        }

        it("should call the cardStack's didSelectCard delegate method with the correct index") {
          expect(mockDelegate.didSelectCardAtCalled).to(beTrue())
          expect(mockDelegate.didSelectCardAtIndex).to(equal(topIndex))
        }
      }
    }

    // MARK: - Did Begin Swipe

    describe("When calling didBeginSwipe") {
      beforeEach {
        subject.card(didBeginSwipe: SwipeCard())
      }

      it("should call the animator's removeBackgroundCardAnimation method") {
        expect(mockAnimator.removeBackgroundCardAnimationsCalled).to(beTrue())
      }
    }

    // MARK: - Did Continue Swipe

    context("When calling didContinueSwipe") {
      var backgroundCards: [SwipeCard]!
      let cardTransform = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)

      beforeEach {
        backgroundCards = [SwipeCard(), SwipeCard(), SwipeCard()]
        subject.testBackgroundCards = backgroundCards
      }

      context("and there is no topCard") {
        beforeEach {
          subject.testTopCard = nil
          mockTransformProvider.testBackgroundCardDragTransform = cardTransform
          subject.card(didContinueSwipe: SwipeCard())
        }

        it("should not set the transforms on any of the background cards") {
          for card in backgroundCards {
            expect(card.transform).toNot(equal(cardTransform))
          }
        }
      }

      context("and there is a top card") {
        beforeEach {
          subject.testTopCard = SwipeCard()
          mockTransformProvider.testBackgroundCardDragTransform = cardTransform
          subject.card(didContinueSwipe: SwipeCard())
        }

        it("should set the transforms on any of the background cards") {
          for card in backgroundCards {
            expect(card.transform).to(equal(cardTransform))
          }
        }
      }
    }

    // MARK: - Did Cancel Swipe

    describe("When the calling didCancelSwipe") {
      beforeEach {
        subject.card(didCancelSwipe: SwipeCard())
      }

      it("should call the animator's reset method") {
        expect(mockAnimator.animateResetCalled).to(beTrue())
      }
    }

    // MARK: - Did Swipe

    context("When calling didSwipe") {
      let direction: SwipeDirection = .left
      let forced: Bool = false
      let topCard = SwipeCard()

      context("and topIndex is nil") {
        beforeEach {
          subject.testTopCardIndex = nil
          subject.visibleCards = [topCard]
          subject.card(didSwipe: SwipeCard(), with: .left, forced: true)
        }

        it("it should not call the didSwipeCardAtDelegate method") {
          expect(mockDelegate.didSwipeCardAtCalled).to(beFalse())
        }
      }

      context("and topIndex is not nil") {
        let index: Int = 2

        beforeEach {
          subject.testTopCardIndex = index
          subject.visibleCards = [topCard]
          subject.card(didSwipe: topCard, with: direction, forced: forced)
        }

        it("should call the didSwipeCardAt delegate method with the correct parameters") {
          expect(mockDelegate.didSwipeCardAtCalled).to(beTrue())
          expect(mockDelegate.didSwipeCardAtIndex).to(equal(index))
          expect(mockDelegate.didSwipeCardAtDirection).to(equal(direction))
        }
      }

      context("and there is at least one more card to load") {
        let testLoadCard = SwipeCard()
        let numberOfVisibleCards: Int = 2
        let remainingIndices = [0, 1, 2]

        beforeEach {
          mockStateManager.remainingIndices = remainingIndices
          subject.visibleCards = [topCard, SwipeCard()]
          subject.testLoadCard = testLoadCard
          subject.card(didSwipe: topCard, with: direction, forced: forced)
        }

        testSwipe()

        it("should not call the didSwipeAllCards delegate method") {
          expect(mockDelegate.didSwipeAllCardsCalled).to(beFalse())
        }

        it("should load the card from the correct data source index") {
          expect(subject.loadCardCalled).to(beTrue())
          expect(subject.loadCardCalledIndex).to(equal(remainingIndices[numberOfVisibleCards - 1]))
        }

        it("should insert the loaded card at the correct index in the card stack") {
          expect(subject.insertCardCalled).to(beTrue())
          expect(subject.insertCardCard).to(equal(testLoadCard))
          expect(subject.insertCardIndex).to(equal(numberOfVisibleCards - 1))
        }
      }

      context("and there are no more cards to load") {
        beforeEach {
          mockStateManager.remainingIndices = [1, 2]
          subject.visibleCards = [topCard, SwipeCard(), SwipeCard()]
          subject.card(didSwipe: topCard, with: direction, forced: forced)
        }

        testSwipe()

        it("should not call the didSwipeAllCards delegate method") {
          expect(mockDelegate.didSwipeAllCardsCalled).to(beFalse())
        }

        it("not load a new card") {
          expect(subject.loadCardCalled).to(beFalse())
        }
      }

      context("and there are no more cards to swipe") {
        beforeEach {
          mockStateManager.remainingIndices = []
          subject.visibleCards = [topCard]
          subject.card(didSwipe: topCard, with: direction, forced: forced)
        }

        testSwipe()

        it("should call the didSwipeAllCards delegate method") {
          expect(mockDelegate.didSwipeAllCardsCalled).to(beTrue())
        }
      }

      func testSwipe() {
        it("should call the state manager's swipe method with the correct direction") {
          expect(mockStateManager.swipeCalled).to(beTrue())
          expect(mockStateManager.swipeDirection).to(equal(direction))
        }

        it("should remove the top card from visibleCards") {
          expect(subject.visibleCards.contains(topCard)).to(beFalse())
        }

        it("should disable user interaction") {
          expect(subject.isUserInteractionEnabled).to(beFalse())
        }

        it("should call the animator's swipe method with the correct parameters") {
          expect(mockAnimator.animateSwipeCalled).to(beTrue())
          expect(mockAnimator.animateSwipeForced).to(equal(forced))
          expect(mockAnimator.animateSwipeTopCard).to(equal(topCard))
          expect(mockAnimator.animateSwipeDirection).to(equal(direction))
        }
      }
    }

    // MARK: - Did Reverse Swipe

    describe("When the calling didReverseSwipe") {
      beforeEach {
        subject.card(didReverseSwipe: SwipeCard(), from: .left)
      }

      it("should disable user interaction on the card") {
        expect(subject.isUserInteractionEnabled).to(beFalse())
      }

      it("should call the animator's undo method") {
        expect(mockAnimator.animateUndoCalled).to(beTrue())
      }
    }
  }
}
