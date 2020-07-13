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
class SwipeCardStackSpec_Base: QuickSpec {

  typealias Card = SwipeCardStack.Card

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
        expect(cardStack.numberOfVisibleCards) == 2
        expect(cardStack.animationOptions) === CardStackAnimationOptions.default

        let expectedInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        expect(cardStack.cardStackInsets) == expectedInsets

        expect(cardStack.delegate).to(beNil())
        expect(cardStack.dataSource).to(beNil())
        expect(cardStack.topCardIndex).to(beNil())

        expect(cardStack.shouldRecognizeHorizontalDrag) == true
        expect(cardStack.shouldRecognizeVerticalDrag) == true

        expect(cardStack.topCard).to(beNil())
        expect(cardStack.visibleCards.isEmpty) == true
        expect(cardStack.backgroundCards) == []

        expect(cardStack.subviews.count) == 1
      }
    }

    // MARK: - Variables

    // MARK: Data Source

    describe("When setting dataSource") {
      beforeEach {
        subject.dataSource = nil
      }

      it("should call reloadData") {
        expect(subject.reloadDataCalled) == true
      }
    }

    // MARK: Insets

    describe("When setting cardStackInsets") {
      beforeEach {
        subject.cardStackInsets = .zero
      }

      it("should trigger a new layout cycle") {
        expect(subject.setNeedsLayoutCalled) == true
      }
    }

    // MARK: Top Card Index

    describe("When getting topCardIndex") {
      context("and there are no visible cards") {
        beforeEach {
          subject.visibleCards = []
        }

        it("should return nil") {
          expect(subject.topCardIndex).to(beNil())
        }
      }

      context("and there is at least one visible card") {
        let index: Int = 2

        beforeEach {
          subject.visibleCards = [Card(index: index, card: SwipeCard())]
        }

        it("should return the first index from visibleCards") {
          expect(subject.topCardIndex) == index
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
          subject.visibleCards = [Card(index: 0, card: firstCard),
                                  Card(index: 1, card: SwipeCard()),
                                  Card(index: 2, card: SwipeCard())]
        }

        it("should return the first visible card") {
          expect(subject.topCard) == firstCard
        }
      }
    }

    // MARK: Background Cards

    describe("When getting backgroundCards") {
      let visibleCards = [SwipeCard(), SwipeCard(), SwipeCard()]

      beforeEach {
        subject.visibleCards = [Card(index: 0, card: visibleCards[0]),
                                Card(index: 1, card: visibleCards[1]),
                                Card(index: 2, card: visibleCards[2])]
      }

      it("should return the visible cards expect the first card") {
        let expectedCards = Array(visibleCards.dropFirst())
        expect(subject.backgroundCards) == expectedCards
      }
    }

    // MARK: Is Enabled

    for isAnimating in [false, true] {
      describe("When getting isEnabled") {
        beforeEach {
          subject.isAnimating = isAnimating
        }

        context("and there is no top card") {
          beforeEach {
            subject.testTopCard = nil
          }

          it("should return !isAnimating") {
            expect(subject.isEnabled) == !isAnimating
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
              expect(subject.isEnabled) == false
            }
          }

          context("and the card's user interaction is true") {
            beforeEach {
              topCard.isUserInteractionEnabled = true
            }

            it("should return !isAnimating") {
              expect(subject.isEnabled) == !isAnimating
            }
          }
        }
      }
    }

    // MARK: - Layout

    // MARK: Layout Subviews

    describe("When calling layoutSubviews") {
      let cardContainerFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
      let numberOfCards: Int = 3
      let visibleCards = [SwipeCard(), SwipeCard(), SwipeCard()]

      beforeEach {
        mockLayoutProvider.testCardContainerFrame = cardContainerFrame
        subject.visibleCards = [Card(index: 0, card: visibleCards[0]),
                                Card(index: 1, card: visibleCards[1]),
                                Card(index: 2, card: visibleCards[2])]
        subject.layoutSubviews()
      }

      it("should correctly layout the card container") {
        let cardContainer = subject.subviews.first
        expect(cardContainer?.frame) == cardContainerFrame
      }

      it("should call layoutCard for each card") {
        expect(subject.layoutCardCalled) == true
        expect(subject.layoutCardPositions) == Array(0..<numberOfCards)
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

      context("and position is zero") {
        let position = 0

        beforeEach {
          subject.testTransformForCard = cardTransform
          subject.layoutCard(card, at: position)
        }

        testLayoutCard(position: position)
      }

      context("and position is greater than zero") {
        let position = 1

        beforeEach {
          subject.testTransformForCard = cardTransform
          subject.layoutCard(card, at: position)
        }

        testLayoutCard(position: position)
      }

      func testLayoutCard(position: Int) {
        it("should correctly layout the card and disable user interaction") {
          expect(card.frame) == transformedFrame
          expect(card.transform) == cardTransform
          expect(card.isUserInteractionEnabled) == (position == 0)
        }
      }
    }

    // MARK: Scale Factor For Card

    describe("When calling scaleFactorForCardAtPosition") {
      context("and the position is equal to zero") {
        it("should return a 100% scale") {
          let expectedScaleFactor = CGPoint(x: 1.0, y: 1.0)
          let actualScaleFactor = subject.scaleFactor(forCardAtPosition: 0)
          expect(actualScaleFactor) == expectedScaleFactor
        }
      }

      context("and the position is greater than zero") {
        it("should return a 95% scale") {
          let actualScaleFactor = subject.scaleFactor(forCardAtPosition: 1)
          let expectedScaleFactor = CGPoint(x: 0.95, y: 0.95)
          expect(actualScaleFactor) == expectedScaleFactor
        }
      }
    }

    // MARK: Transform For Card

    describe("When calling transformForCard") {
      let scaleFactor = CGPoint(x: 0.4, y: 0.7)

      beforeEach {
        subject.testScaleFactor = scaleFactor
      }

      it("should return the correct scaled transform") {
        let actualTransform = subject.transform(forCardAtPosition: 0)
        let expectedTransform = CGAffineTransform(scaleX: scaleFactor.x,
                                                  y: scaleFactor.y)
        expect(actualTransform) == expectedTransform
      }
    }

    // MARK: Gesture Recognizer Should Begin

    describe("When calling gestureRecognizerShouldBegin") {
      context("and the gesture recognizer is not the top card's panGestureRecognizer") {
        it("should return the value from the card stack's superclass") {
          let actualResult = subject.gestureRecognizerShouldBegin(UIGestureRecognizer())
          expect(actualResult) == true
        }
      }

      context("and the gesture recognizer is the top card's pan gesture recognizer") {
        let topCard = SwipeCard()
        var topCardPanGestureRecognizer: PanGestureRecognizer!

        beforeEach {
          subject.testTopCard = topCard
          topCardPanGestureRecognizer = topCard.panGestureRecognizer as? PanGestureRecognizer
        }

        context("and the drag is horizontal") {
          let shouldRecognizeHorizontalDrag: Bool = false

          beforeEach {
            subject.shouldRecognizeHorizontalDrag = shouldRecognizeHorizontalDrag
            topCardPanGestureRecognizer.performPan(withLocation: nil,
                                                   translation: nil,
                                                   velocity: CGPoint(x: 1, y: 0))
          }

          it("should return recognizeHorizontalDrag") {
            let actualResult = subject.gestureRecognizerShouldBegin(topCardPanGestureRecognizer)
            expect(actualResult) == shouldRecognizeHorizontalDrag
          }
        }

        context("and the drag is vertical") {
          let shouldRecognizeVerticalDrag: Bool = false

          beforeEach {
            subject.shouldRecognizeVerticalDrag = shouldRecognizeVerticalDrag
            topCardPanGestureRecognizer.performPan(withLocation: nil,
                                                   translation: nil,
                                                   velocity: CGPoint(x: 0, y: 1))
          }

          it("should return recognizeHorizontalDrag") {
            let actualResult = subject.gestureRecognizerShouldBegin(topCardPanGestureRecognizer)
            expect(actualResult) == shouldRecognizeVerticalDrag
          }
        }

        context("and the drag has no direction") {
          beforeEach {
            topCardPanGestureRecognizer.performPan(withLocation: nil,
                                                   translation: nil,
                                                   velocity: CGPoint(x: 0, y: 0))
          }

          it("should return the value from the card's superclass") {
            let actualResult = subject.gestureRecognizerShouldBegin(topCardPanGestureRecognizer)
            expect(actualResult) == true
          }
        }
      }
    }
  }
}
// swiftlint:enable closure_body_length  function_body_length implicitly_unwrapped_optional
