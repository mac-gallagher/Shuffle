import Quick
import Nimble

@testable import Shuffle

struct MockCardAnimator: CardAnimatable {
    
    static var resetCalled: Bool = false
    static func reset(_ card: SwipeCard) {
        resetCalled = true
    }
    
    static var swipeCalled: Bool = false
    static var swipeDirection: SwipeDirection?
    static var swipeForced: Bool?
    
    static func swipe(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) {
        swipeCalled = true
        swipeDirection = direction
        swipeForced = forced
    }
    
    static var reverseSwipeCalled: Bool = false
    static var reverseSwipeDirection: SwipeDirection?
    
    static func reverseSwipe(_ card: SwipeCard, from direction: SwipeDirection) {
        reverseSwipeCalled = true
        reverseSwipeDirection = direction
    }
    
    static var removeAllAnimationsCalled: Bool = false
    static func removeAllAnimations(on card: SwipeCard) {
        removeAllAnimationsCalled = true
    }
    
    // MARK: - Test Helpers
    
    static func reset() {
        resetCalled = false
        
        swipeCalled = false
        swipeDirection = nil
        swipeForced = nil
        
        reverseSwipeCalled = false
        reverseSwipeDirection = nil
        
        removeAllAnimationsCalled = false
    }
}
