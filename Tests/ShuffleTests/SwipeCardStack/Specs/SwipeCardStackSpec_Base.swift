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
    var mockLayoutProvider: MockCardStackLayoutProvider!
    var mockStateManager: MockCardStackStateManager!
    var subject: TestableSwipeCardStack!

    beforeEach {
      mockLayoutProvider = MockCardStackLayoutProvider()
      mockStateManager = MockCardStackStateManager()
      subject = TestableSwipeCardStack(animator: MockCardStackAnimator(),
                                       layoutProvider: mockLayoutProvider,
                                       notificationCenter: NotificationCenter.default,
                                       stateManager: mockStateManager,
                                       transformProvider: MockCardStackTransformProvider())
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

    // MARK: Layout Card

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

    describe("When calling transformForCard") {
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
  }
}
