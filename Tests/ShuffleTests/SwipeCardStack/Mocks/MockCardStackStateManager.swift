@testable import Shuffle

class MockCardStackStateManager: CardStackStateManagable {
    
    var remainingIndices: [Int] = []
    
    var swipes: [Swipe] = []
    
    var swipeCalled = false
    var swipeDirection: SwipeDirection?
    
    func swipe(_ direction: SwipeDirection) {
        swipeCalled = true
        swipeDirection = direction
    }
    
    var undoSwipeCalled = false
    var undoSwipeSwipe: Swipe?
    
    func undoSwipe() -> Swipe? {
        undoSwipeCalled = true
        return undoSwipeSwipe
    }
    
    var shiftCalled = false
    var shiftDistance: Int? = nil
    
    func shift(withDistance distance: Int) {
        shiftCalled = true
        shiftDistance = distance
    }
    
    var resetCalled: Bool = false
    var resetNumberOfCards: Int?
    
    func reset(withNumberOfCards numberOfCards: Int) {
        resetCalled = true
        resetNumberOfCards = numberOfCards
    }
}
