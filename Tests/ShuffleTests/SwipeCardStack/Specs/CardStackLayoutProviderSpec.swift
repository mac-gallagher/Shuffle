import Nimble
import Quick
@testable import Shuffle
import UIKit

class CardStackLayoutProviderSpec: QuickSpec {
  
  override func spec() {
    describe("CardStackLayoutProvider") {
      let insets = UIEdgeInsets(top: -1, left: 2, bottom: 3, right: -4)
      let cardStackWidth: CGFloat = 100
      let cardStackHeight: CGFloat = 200

      var cardStack: SwipeCardStack!
      var subject: CardStackLayoutProvider!
      
      beforeEach {
        cardStack = SwipeCardStack(animator: MockCardStackAnimator(),
                                   layoutProvider: MockCardStackLayoutProvider(),
                                   notificationCenter: NotificationCenter.default,
                                   stateManager: MockCardStackStateManager(),
                                   transformProvider: MockCardStackTransformProvider())
        cardStack.cardStackInsets = insets
        cardStack.frame = CGRect(x: 0, y: 0,
                                 width: cardStackWidth,
                                 height: cardStackHeight)

        subject = CardStackLayoutProvider()
      }
      
      // MARK: - Card Container Frame
      
      describe("When calling the createCardContainerFrame method") {
        it("should return the correct frame") {
          let expectedWidth = cardStackWidth - (insets.left + insets.right)
          let expectedHeight = cardStackHeight - (insets.top + insets.bottom)
          let expectedFrame = CGRect(x: insets.left,
                                     y: insets.top,
                                     width: expectedWidth,
                                     height: expectedHeight)
          let actualFrame = subject.createCardContainerFrame(for: cardStack)
          expect(actualFrame).to(equal(expectedFrame))
        }
      }
      
      // MARK: - Card Frame
      
      describe("When calling the the createCardFrame method") {
        it("should return the correct frame") {
          let expectedWidth = cardStackWidth - (insets.left + insets.right)
          let expectedHeight = cardStackHeight - (insets.top + insets.bottom)
          let expectedFrame = CGRect(x: 0, y: 0,
                                     width: expectedWidth,
                                     height: expectedHeight)
          let actualFrame = subject.createCardFrame(for: cardStack)
          expect(actualFrame).to(equal(expectedFrame))
        }
      }
    }
  }
}
