@testable import Shuffle

class TestableSwipeCard: SwipeCard {
    
    // MARK: - Gesture Recognizers
    
    override var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer
    }
    
    private lazy var panRecognizer
        = TestablePanGestureRecognizer(target: self, action: #selector(handlePan))
    
    override var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    private lazy var tapRecognizer
        = TestableTapGestureRecognizer(target: self, action: #selector(didTap))
    
    // MARK: - Other Variables
    
    var testActiveDirection: SwipeDirection?
    override var activeDirection: SwipeDirection? {
        return testActiveDirection ?? super.activeDirection
    }
    
    var testTouchLocation: CGPoint?
    override var touchLocation: CGPoint? {
        return testTouchLocation ?? super.touchLocation
    }
    
    //MARK: - Completion Blocks
    
    var swipeCompletionCalled: Bool = false
    override var swipeCompletion: () -> Void {
        swipeCompletionCalled = true
        return super.swipeCompletion
    }
    
    var reverseSwipeCompletionCalled: Bool = false
    override var reverseSwipeCompletion: (SwipeDirection) -> Void {
        reverseSwipeCompletionCalled = true
        return super.reverseSwipeCompletion
    }
    
    // MARK: - Swipe Recognition
    
    var testDragSpeed: CGFloat?
    override var dragSpeed: (SwipeDirection) -> CGFloat {
        return { direction in
            return self.testDragSpeed ?? super.dragSpeed(direction)
        }
    }
    
    var testDragPercentage = [SwipeDirection: CGFloat]()
    override var dragPercentage: (SwipeDirection) -> CGFloat {
        return { direction in
            return self.testDragPercentage[direction] ?? super.dragPercentage(direction)
        }
    }
    
    var testMinimumSwipeDistance = [SwipeDirection: CGFloat]()
    override func minimumSwipeDistance(on direction: SwipeDirection) -> CGFloat {
        return testMinimumSwipeDistance[direction]
            ?? super.minimumSwipeDistance(on: direction)
    }
    
    var testMinimumSwipeSpeed: CGFloat?
    override func minimumSwipeSpeed(on direction: SwipeDirection) -> CGFloat {
        return testMinimumSwipeSpeed ?? super.minimumSwipeSpeed(on: direction)
    }
    
    // MARK: - Main Methods
    
    var testOverlay = [SwipeDirection: UIView]()
    override func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return testOverlay[direction] ?? super.overlay(forDirection: direction)
    }
    
    var swipeActionDirection: SwipeDirection?
    var swipeActionForced: Bool?
    var swipeActionAnimated: Bool?
    
    override func swipeAction(direction: SwipeDirection, forced: Bool, animated: Bool) {
        super.swipeAction(direction: direction, forced: forced, animated: animated)
        swipeActionDirection = direction
        swipeActionForced = forced
        swipeActionAnimated = animated
    }
    
    var swipeCalled: Bool = false
    var swipeDirection: SwipeDirection?
    var swipeAnimated: Bool?
    
    override func swipe(direction: SwipeDirection, animated: Bool) {
        super.swipe(direction: direction, animated: animated)
        swipeCalled = true
        swipeDirection = direction
        swipeAnimated = animated
    }
    
    var reverseSwipeCalled: Bool = false
    var reverseSwipeDirection: SwipeDirection?
    var reverseSwipeAnimated: Bool?
    
    override func reverseSwipe(from direction: SwipeDirection, animated: Bool) {
        super.reverseSwipe(from: direction, animated: animated)
        reverseSwipeCalled = true
        reverseSwipeDirection = direction
        reverseSwipeAnimated = animated
    }
    
    // MARK: - Lifecycle
    
    var setNeedsLayoutCalled: Bool = false
    override func setNeedsLayout() {
        super.setNeedsLayout()
        setNeedsLayoutCalled = true
    }
}
