@testable import Shuffle

class MockCardTransformProvider: CardTransformProvidable {
    
    static var testCardRotationDirectionY: CGFloat = 0
    static var cardRotationDirectionY: (SwipeCard) -> CGFloat {
        return { _ in
            testCardRotationDirectionY
        }
    }
    
    
    static var testCardTranform: CGAffineTransform = .identity
    static var cardTransform: (SwipeCard) -> CGAffineTransform {
        return { _ in
            return testCardTranform
        }
    }
    
    static var testCardRotationAngle: CGFloat = 0
    static var cardRotationAngle: (SwipeCard) -> CGFloat {
        return { _ in
            return testCardRotationAngle
        }
    }
    
    static var testCardOverlayPercentage = [SwipeDirection: CGFloat]()
    static var cardOverlayPercentage: (SwipeCard, SwipeDirection) -> CGFloat {
        return { _, direction in
            testCardOverlayPercentage[direction]!
        }
    }
    
    // MARK: - Test Helpers
    
    static func reset() {
        testCardTranform = .identity
        testCardRotationAngle = 0
        testCardOverlayPercentage = [:]
    }
}
