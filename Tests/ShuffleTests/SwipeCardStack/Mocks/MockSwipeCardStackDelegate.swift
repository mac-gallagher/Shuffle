import Shuffle

class MockSwipeCardStackDelegate: SwipeCardStackDelegate {
    
    var didSelectCardAtCalled: Bool = false
    var didSelectCardAtIndex: Int?
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        didSelectCardAtCalled = true
        didSelectCardAtIndex = index
    }
    
    var didSwipeCardAtCalled: Bool = false
    var didSwipeCardAtIndex: Int?
    var didSwipeCardAtDirection: SwipeDirection?
    
    func cardStack(_ cardStack: SwipeCardStack,
                   didSwipeCardAt index: Int,
                   with direction: SwipeDirection) {
        didSwipeCardAtCalled = true
        didSwipeCardAtIndex = index
        didSwipeCardAtDirection = direction
    }
    
    var didUndoCardAtCalled: Bool = false
    var didUndoCardAtIndex: Int?
    var didUndoCardAtDirection: SwipeDirection?
    
    func cardStack(_ cardStack: SwipeCardStack,
                   didUndoCardAt index: Int,
                   from direction: SwipeDirection) {
        didUndoCardAtCalled = true
        didUndoCardAtIndex = index
        didUndoCardAtDirection = direction
    }
    
    var didSwipeAllCardsCalled: Bool = false
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        didSwipeAllCardsCalled = true
    }
}
