@testable import Shuffle

class TestableSwipeView: SwipeView {
    
    // MARK: - Gesture Recognizers
    
    override var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer
    }
    
    private lazy var panRecognizer = TestablePanGestureRecognizer(target: self, action: #selector(handlePan))
    
    override var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    private lazy var tapRecognizer = TestableTapGestureRecognizer(target: self, action: #selector(didTap))
    
    // MARK: - Swipe Functions
    
    var minSwipeSpeed: CGFloat?
    override func minimumSwipeSpeed(on direction: SwipeDirection) -> CGFloat {
        return minSwipeSpeed ?? super.minimumSwipeSpeed(on: direction)
    }
    
    var minSwipeDistance: CGFloat?
    override func minimumSwipeDistance(on direction: SwipeDirection) -> CGFloat {
        return minSwipeDistance ?? super.minimumSwipeDistance(on: direction)
    }
    
    // MARK: - Tap/Pan Gesture Functions
    
    var didTapCalled: Bool = false
    override func didTap(_ recognizer: UITapGestureRecognizer) {
        super.didTap(recognizer)
        didTapCalled = true
    }
    
    var beginSwipingCalled: Bool = false
    override func beginSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.beginSwiping(recognizer)
        beginSwipingCalled = true
    }
    
    var continueSwipingCalled: Bool = false
    override func continueSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.continueSwiping(recognizer)
        continueSwipingCalled = true
    }
    
    var endSwipingCalled: Bool = false
    override func endSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.endSwiping(recognizer)
        endSwipingCalled = true
    }
    
    var didSwipeCalled: Bool = false
    var didSwipeDirection: SwipeDirection?
    
    override func didSwipe(_ recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {
        super.didSwipe(recognizer, with: direction)
        didSwipeCalled = true
        didSwipeDirection = direction
    }
    
    var didCancelSwipeCalled: Bool = false
    override func didCancelSwipe(_ recognizer: UIPanGestureRecognizer) {
        super.didCancelSwipe(recognizer)
        didCancelSwipeCalled = true
    }
}
