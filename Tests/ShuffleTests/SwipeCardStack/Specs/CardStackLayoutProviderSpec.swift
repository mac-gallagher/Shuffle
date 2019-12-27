import Quick
import Nimble

@testable import Shuffle

class CardStackLayoutProviderSpec: QuickSpec {
    
    override func spec() {
        describe("CardStackLayoutProvider") {
            let insets = UIEdgeInsets(top: -1, left: 2, bottom: 3, right: -4)
            let cardStackWidth: CGFloat = 100
            let cardStackHeight: CGFloat = 200
            let subject = CardStackLayoutProvider.self
            
            var cardStack: SwipeCardStack!
            
            beforeEach {
                cardStack = SwipeCardStack(animator: MockCardStackAnimator.self,
                                           transformProvider: MockCardStackTransformProvider.self,
                                           layoutProvider: MockCardStackLayoutProvider.self,
                                           notificationCenter: TestableNotificationCenter())
                cardStack.cardStackInsets = insets
                cardStack.frame = CGRect(x: 0, y: 0,
                                         width: cardStackWidth,
                                         height: cardStackHeight)
            }
            
            // MARK: - Card Container Frame
            
            describe("When accessing the cardContainerFrame variable") {
                it("should return the correct frame") {
                    let expectedWidth = cardStackWidth - (insets.left + insets.right)
                    let expectedHeight = cardStackHeight - (insets.top + insets.bottom)
                    let expectedFrame = CGRect(x: insets.left,
                                               y: insets.top,
                                               width: expectedWidth,
                                               height: expectedHeight)
                    let actualFrame = subject.cardContainerFrame(cardStack)
                    expect(actualFrame).to(equal(expectedFrame))
                }
            }
            
            // MARK: - Card Frame
            
            describe("When accessing the cardFrame variable") {
                it("should return the correct frame") {
                    let expectedWidth = cardStackWidth - (insets.left + insets.right)
                    let expectedHeight = cardStackHeight - (insets.top + insets.bottom)
                    let expectedFrame = CGRect(x: 0, y: 0,
                                               width: expectedWidth,
                                               height: expectedHeight)
                    let actualFrame = subject.cardFrame(cardStack)
                    expect(actualFrame).to(equal(expectedFrame))
                }
            }
        }
    }
}
