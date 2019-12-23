@testable import Shuffle

class MockCardStackTransformProvider: CardStackTransformProvidable {
    
    static var testBackgroundCardDragTransform: CGAffineTransform = .identity
    static var backgroundCardDragTransformIndex: Int?
    static var backgroundCardDragTransformCard: SwipeCard?
    
    static var backgroundCardDragTransform: (SwipeCardStack, SwipeCard, Int) -> CGAffineTransform {
        return { _, card, index in
            backgroundCardDragTransformIndex = index
            backgroundCardDragTransformCard = card
            return testBackgroundCardDragTransform
        }
    }
    
    static var testBackgroundCardTransformPercentage: CGFloat = 0.0
    static var backgroundCardTransformPercentageCard: SwipeCard?
    
    static var backgroundCardTransformPercentage: (SwipeCardStack, SwipeCard) -> CGFloat {
        return { _, card in
            backgroundCardTransformPercentageCard = card
            return testBackgroundCardTransformPercentage
        }
    }
    
    // MARK: - Test Helpers
    
    static func reset() {
        testBackgroundCardDragTransform = .identity
        backgroundCardDragTransformIndex = nil
        backgroundCardDragTransformCard = nil

        testBackgroundCardTransformPercentage = 0.0
        backgroundCardTransformPercentageCard = nil
    }
}
