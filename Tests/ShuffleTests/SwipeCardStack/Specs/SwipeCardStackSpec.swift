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

class SwipeCardStackSpec_Base: QuickSpec {

  override func spec() {
    var mockAnimator: MockCardStackAnimator!
    var mockDelegate: MockSwipeCardStackDelegate!
    var mockLayoutProvider: MockCardStackLayoutProvider!
    var mockStateManager: MockCardStackStateManager!
    var mockTransformProvider: MockCardStackTransformProvider!
    var subject: TestableSwipeCardStack!

    beforeEach {
      mockAnimator = MockCardStackAnimator()
      mockDelegate = MockSwipeCardStackDelegate()
      mockLayoutProvider = MockCardStackLayoutProvider()
      mockStateManager = MockCardStackStateManager()
      mockTransformProvider = MockCardStackTransformProvider()
      subject = TestableSwipeCardStack(animator: mockAnimator,
                                       layoutProvider: mockLayoutProvider,
                                       notificationCenter: NotificationCenter.default,
                                       stateManager: mockStateManager,
                                       transformProvider: mockTransformProvider)
      subject.delegate = mockDelegate
    }

    // MARK: - Initialization

    describe("Initialization") {
      var cardStack: SwipeCardStack!

      describe("When initializing a SwipeCard with the default initializer") {
        beforeEach {
          cardStack = SwipeCardStack()
        }

        it("should have the correct default properties") {
          testDefaultProperties()
        }
      }

      describe("When initializing a SwipeCard with the required initializer") {
        beforeEach {
          // TODO: - Find a non-deprecated way to accomplish this
          let coder = NSKeyedUnarchiver(forReadingWith: Data())
          cardStack = SwipeCardStack(coder: coder)
        }

        it("should have the correct default properties") {
          testDefaultProperties()
        }
      }

      func testDefaultProperties() {
        expect(cardStack.numberOfVisibleCards).to(equal(2))
        expect(cardStack.animationOptions).to(be(CardStackAnimationOptions.default))

        let expectedInsets = UIEdgeInsets(top: 10, left: 10,
                                          bottom: 10, right: 10)
        expect(cardStack.cardStackInsets).to(equal(expectedInsets))

        expect(cardStack.delegate).to(beNil())
        expect(cardStack.dataSource).to(beNil())
        expect(cardStack.topCardIndex).to(beNil())

        expect(cardStack.topCard).to(beNil())
        expect(cardStack.visibleCards).to(equal([]))
        expect(cardStack.backgroundCards).to(equal([]))

        expect(cardStack.subviews.count).to(equal(1))
      }
    }

    // MARK: - Variables

    // MARK: Data Source

    describe("When setting dataSource") {
      beforeEach {
        subject.dataSource = nil
      }

      it("should call reloadData") {
        expect(subject.reloadDataCalled).to(beTrue())
      }
    }

    // MARK: Number Of Visible Cards

    describe("When setting numberOfVisibleCards") {
      beforeEach {
        subject.numberOfVisibleCards = 0
      }

      it("should call reloadData") {
        expect(subject.reloadDataCalled).to(beTrue())
      }
    }

    // MARK: Insets

    describe("When setting cardStackInsets") {
      beforeEach {
        subject.cardStackInsets = .zero
      }

      it("should trigger a new layout cycle") {
        expect(subject.setNeedsLayoutCalled).to(beTrue())
      }
    }

    // MARK: Top Card Index

    describe("When getting topCardIndex") {
      context("and there are no remaining indices in the state manager") {
        beforeEach {
          mockStateManager.remainingIndices = []
        }

        it("should return nil") {
          expect(subject.topCardIndex).to(beNil())
        }
      }

      context("and there is at least one remaining index in the state manager") {
        let index: Int = 2

        beforeEach {
          mockStateManager.remainingIndices = [index]
        }

        it("should return the first remaining index from the state manager") {
          expect(subject.topCardIndex).to(equal(index))
        }
      }
    }

    // MARK: Top Card

    describe("When getting topCard") {
      context("and there are no visible cards") {
        beforeEach {
          subject.visibleCards = []
        }

        it("should return nil") {
          expect(subject.topCard).to(beNil())
        }
      }

      context("and there is at least one visible card") {
        let firstCard = SwipeCard()

        beforeEach {
          subject.visibleCards = [firstCard, SwipeCard(), SwipeCard()]
        }

        it("should return the first visible card") {
          expect(subject.topCard).to(equal(firstCard))
        }
      }
    }

    // MARK: Background Cards

    describe("When getting backgroundCards") {
      let visibleCards = [SwipeCard(), SwipeCard(), SwipeCard()]

      beforeEach {
        subject.visibleCards = visibleCards
      }

      it("should return the visible cards expect the first card") {
        let expectedCards = Array(visibleCards.dropFirst())
        expect(subject.backgroundCards).to(equal(expectedCards))
      }
    }

    // MARK: Is Enabled

    for isUserInteractionEnabled in [false, true] {
      describe("When getting isEnabled") {
        beforeEach {
          subject.isUserInteractionEnabled = isUserInteractionEnabled
        }

        context("and there is no top card") {
          beforeEach {
            subject.testTopCard = nil
          }

          it("should return isUserInteractionEnabled") {
            expect(subject.isEnabled).to(equal(isUserInteractionEnabled))
          }
        }

        context("and there is a top card") {
          let topCard = SwipeCard()

          beforeEach {
            subject.testTopCard = topCard
          }

          context("and the card's user interaction is false") {
            beforeEach {
              topCard.isUserInteractionEnabled = false
            }

            it("should return false") {
              expect(subject.isEnabled).to(beFalse())
            }
          }

          context("and the card's user interaction is true") {
            beforeEach {
              topCard.isUserInteractionEnabled = true
            }

            it("should return isUserInteractionEnabled") {
              expect(subject.isEnabled).to(equal(isUserInteractionEnabled))
            }
          }
        }
      }
    }

    // MARK: - Completion Blocks

    // MARK: Swipe Completion Block

    describe("When the swipe completion block is called") {
      beforeEach {
        subject.isUserInteractionEnabled = false
        subject.swipeCompletionBlock()
      }

      it("should enable user interaction on the card stack") {
        expect(subject.isUserInteractionEnabled).to(beTrue())
      }
    }

    // MARK: Undo Completion

    describe("When the undo completion block is called") {
      beforeEach {
        subject.isUserInteractionEnabled = false
        subject.undoCompletionBlock()
      }

      it("should enable user interaction on the card stack") {
        expect(subject.isUserInteractionEnabled).to(beTrue())
      }
    }

    // MARK: Shift Completion

    describe("When the shift completion block is called") {
      beforeEach {
        subject.isUserInteractionEnabled = false
        subject.shiftCompletionBlock()
      }

      it("should enable user interaction on the card stack") {
        expect(subject.isUserInteractionEnabled).to(beTrue())
      }
    }

    // MARK: - Layout

    // MARK: Layout Subviews

    describe("When calling layoutSubviews") {
      let cardContainerFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
      let numberOfCards: Int = 3
      let visibleCards: [SwipeCard] = [SwipeCard(), SwipeCard(), SwipeCard()]

      beforeEach {
        mockLayoutProvider.testCardContainerFrame = cardContainerFrame
        subject.visibleCards = visibleCards
        subject.layoutSubviews()
      }

      it("should correctly layout the card container") {
        let cardContainer = subject.subviews.first
        expect(cardContainer?.frame).to(equal(cardContainerFrame))
      }

      it("should call layoutCard for each card") {
        expect(subject.layoutCardCalled).to(beTrue())
        expect(subject.layoutCardIndices).to(equal(Array(0..<numberOfCards)))
        expect(subject.visibleCards).to(equal(visibleCards))
      }
    }

    // MARK - Layout Card

    describe("When calling layoutCard") {
      let cardFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
      let cardTransform = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
      let card = SwipeCard()

      let transformedFrame: CGRect = {
        let tempView = UIView(frame: cardFrame)
        tempView.transform = cardTransform
        return tempView.frame
      }()

      beforeEach {
        mockLayoutProvider.testCardFrame = cardFrame
      }

      context("and index is zero") {
        let index = 0

        beforeEach {
          subject.testTransformForCard = cardTransform
          subject.layoutCard(card, at: index)
        }

        testLayoutCard(index: index)
      }

      context("and index is greater than zero") {
        let index = 1

        beforeEach {
          subject.testTransformForCard = cardTransform
          subject.layoutCard(card, at: index)
        }

        testLayoutCard(index: index)
      }

      func testLayoutCard(index: Int) {
        it("should correctly layout the card and disable user interaction") {
          expect(card.frame).to(equal(transformedFrame))
          expect(card.transform).to(equal(cardTransform))
          expect(card.isUserInteractionEnabled).to(equal(index == 0))

        }
      }
    }

    // MARK: Scale Factor For Card

    describe("When calling scaleFactorForCardAtIndex") {
      context("and the index is equal to zero") {
        it("should return a 100% scale") {
          let expectedScaleFactor = CGPoint(x: 1.0, y: 1.0)
          let actualScaleFactor = subject.scaleFactor(forCardAtIndex: 0)
          expect(actualScaleFactor).to(equal(expectedScaleFactor))
        }
      }

      context("and the index is greater than zero") {
        it("should return a 95% scale") {
          let actualScaleFactor = subject.scaleFactor(forCardAtIndex: 1)
          let expectedScaleFactor = CGPoint(x: 0.95, y: 0.95)
          expect(actualScaleFactor).to(equal(expectedScaleFactor))
        }
      }
    }

    // MARK: Transform For Card

    context("When calling transformForCard") {
      let scaleFactor = CGPoint(x: 0.4, y: 0.7)

      beforeEach {
        subject.testScaleFactor = scaleFactor
      }

      it("should return the identity transform") {
        let actualTransform = subject.transform(forCardAtIndex: 0)
        let expectedTransform = CGAffineTransform(scaleX: scaleFactor.x,
                                                  y: scaleFactor.y)
        expect(actualTransform).to(equal(expectedTransform))
      }
    }

    // MARK: - Main Methods

    // MARK: Swipe

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

    // MARK: Undo Last Swipe

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

    // MARK: Shift

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

          beforeEach {
            mockStateManager.remainingIndices = [1, 2, 3]
            subject.isUserInteractionEnabled = false
            subject.visibleCards = [SwipeCard(), SwipeCard()]
          }

          context("and animated is true") {
            beforeEach {
              subject.shift(withDistance: distance, animated: true)
            }

            it("should call the state manager's shift method with the correct distance") {
              expect(mockStateManager.shiftCalled).to(beTrue())
              expect(mockStateManager.shiftDistance).to(equal(distance))
            }

            it("it should call the reloadVisibleCards method") {
              expect(subject.reloadVisibleCardsCalled).to(beTrue())
            }

            it("should disable user interaction and call the animator's shift method with the correct parameters") {
              expect(subject.isUserInteractionEnabled).to(beFalse())
              expect(mockAnimator.animateShiftCalled).to(beTrue())
              expect(mockAnimator.animateShiftDistance).to(equal(distance))
            }
          }

          context("and animated is false") {
            beforeEach {
              subject.shift(withDistance: distance, animated: false)
            }

            it("should call the state manager's shift method with the correct distance") {
              expect(mockStateManager.shiftCalled).to(beTrue())
              expect(mockStateManager.shiftDistance).to(equal(distance))
            }

            it("it should call the reloadVisibleCards method") {
              expect(subject.reloadVisibleCardsCalled).to(beTrue())
            }

            it("should not call the animator's shift method") {
              expect(mockAnimator.animateShiftCalled).to(beFalse())
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

    describe("Reload Visible Cards") {
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

        it("should return the correct card and set it's delegate") {
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

        it("should remove the card from it's superview") {
          expect(swipeCard.superview).to(beNil())
        }
      }
    }

    // MARK: - SwipeCardDelegate

    // MARK: Did Tap

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

    // MARK: Did Begin Swipe

    describe("When calling didBeginSwipe") {
      beforeEach {
        subject.card(didBeginSwipe: SwipeCard())
      }

      it("should call the animator's removeBackgroundCardAnimation method") {
        expect(mockAnimator.removeBackgroundCardAnimationsCalled).to(beTrue())
      }
    }

    // MARK: Did Continue Swipe

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

    // MARK: Did Cancel Swipe

    describe("When the calling didCancelSwipe") {
      beforeEach {
        subject.card(didCancelSwipe: SwipeCard())
      }

      it("should call the animator's reset method") {
        expect(mockAnimator.animateResetCalled).to(beTrue())
      }
    }

    // MARK: Swipe

    describe("Swipe") {
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
    }

    // MARK: Reverse Swipe

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
