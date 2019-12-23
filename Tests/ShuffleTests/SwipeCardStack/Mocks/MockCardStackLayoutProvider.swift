@testable import Shuffle

struct MockCardStackLayoutProvider: CardStackLayoutProvidable {
    
    static var testCardContainerFrame: CGRect = .zero
    static var cardContainerFrame: (SwipeCardStack) -> CGRect {
        return { _ in
            return testCardContainerFrame
        }
    }
    
    static var testCardFrame: CGRect = .zero
    static var cardFrame: (SwipeCardStack) -> CGRect {
        return { _ in
            return testCardFrame
        }
    }
    
    // MARK: - Test Helpers
    
    static func reset() {
        testCardContainerFrame = .zero
        testCardFrame = .zero
    }
}
