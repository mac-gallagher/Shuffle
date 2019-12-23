@testable import Shuffle

struct MockCardStackAnimator: CardStackAnimatable {
    
    static var swipeCalled: Bool = false
    static var swipeForced: Bool?
    static var swipeDirection: SwipeDirection?
    static var swipeTopCard: SwipeCard?
    
    static func swipe(_ cardStack: SwipeCardStack,
                      topCard: SwipeCard,
                      direction: SwipeDirection,
                      forced: Bool) {
        swipeCalled = true
        swipeForced = forced
        swipeDirection = direction
        swipeTopCard = topCard
    }
    
    static var shiftCalled: Bool = false
    static var shiftDistance: Int?
    
    static func shift(_ cardStack: SwipeCardStack, withDistance distance: Int) {
        shiftCalled = true
        shiftDistance = distance
    }
    
    static var resetCalled: Bool = false
    static func reset(_ cardStack: SwipeCardStack, topCard: SwipeCard) {
        resetCalled = true
    }

    static var undoCalled: Bool = false
    static func undo(_ cardStack: SwipeCardStack, topCard: SwipeCard) {
        undoCalled = true
    }
    
    static var removeBackgroundCardAnimationsCalled: Bool = false
    static  func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack) {
        removeBackgroundCardAnimationsCalled = true
    }
    
    static var removeAllCardAnimationsCalled: Bool = false
    static func removeAllCardAnimations(_ cardStack: SwipeCardStack) {
        removeAllCardAnimationsCalled = true
    }
    
    // MARK: - Test Helpers
    
    static func reset() {
        swipeCalled = false
        swipeForced = nil
        
        shiftCalled = false
        shiftDistance = nil
        
        resetCalled = false
        undoCalled = false
        removeBackgroundCardAnimationsCalled = false
        removeAllCardAnimationsCalled = false
    }
}
