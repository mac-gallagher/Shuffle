@testable import Shuffle

class TestableCardAnimator: CardAnimator {
    
    // MARK: - Animation Blocks
    
    static var resetAnimationBlockCalled: Bool = false
    override class var resetAnimationBlock: ResetAnimationBlock {
        resetAnimationBlockCalled = true
        return super.resetAnimationBlock
    }
    
    static var swipeAnimationKeyFramesCalled: Bool = false
    override class var swipeAnimationKeyFrames: SwipeAnimationKeyFrames {
        swipeAnimationKeyFramesCalled = true
        return super.swipeAnimationKeyFrames
    }
    
    static var reverseSwipeAnimationKeyFramesCalled: Bool = false
    override class var reverseSwipeAnimationKeyFrames: ReverseSwipeAnimationKeyFrames {
        reverseSwipeAnimationKeyFramesCalled = true
        return super.reverseSwipeAnimationKeyFrames
    }
    
    // MARK: - Animation Calculations
    
    static var testSwipeDuration: TimeInterval?
    override class var swipeDuration: (SwipeCard, SwipeDirection, Bool) -> TimeInterval {
        return { card, direction, forced in
            testSwipeDuration ?? super.swipeDuration(card, direction, forced)
        }
    }
    
    static var testSwipeTransform: CGAffineTransform?
    override class var swipeTransform: (SwipeCard, SwipeDirection, Bool) -> CGAffineTransform {
        return { card, direction, forced in
            return testSwipeTransform ?? super.swipeTransform(card, direction, forced)
        }
    }
    
    static var testSwipeTranslation: CGVector?
    override class var swipeTranslation: (SwipeCard, SwipeDirection, CGVector) -> CGVector {
        return { card, direction, directionVector in
            return testSwipeTranslation
                ?? super.swipeTranslation(card, direction, directionVector)
        }
    }
    
    static var testSwipeRotationAngle: CGFloat?
    override class var swipeRotationAngle: (SwipeCard, SwipeDirection, Bool) -> CGFloat {
        return { card, direction, forced in
            return testSwipeRotationAngle  ?? super.swipeRotationAngle(card, direction, forced)
        }
    }
    
    static var testRelativeSwipeOverlayFadeDuration: TimeInterval?
    override class var relativeSwipeOverlayFadeDuration: (SwipeCard, SwipeDirection, Bool) -> TimeInterval {
        return { card, direction, forced in
            return testRelativeSwipeOverlayFadeDuration
                ?? super.relativeSwipeOverlayFadeDuration(card, direction, forced)
        }
    }
    
    static var testRelativeReverseSwipeOverlayFadeDuration: TimeInterval?
    override class var relativeReverseSwipeOverlayFadeDuration: (SwipeCard, SwipeDirection) -> TimeInterval {
        return { card, direction in
            return testRelativeReverseSwipeOverlayFadeDuration
                ?? super.relativeReverseSwipeOverlayFadeDuration(card, direction)
        }
    }
    
    // MARK: - Main Methods
    
    static var removeAllAnimationsCalled: Bool = false
    override class func removeAllAnimations(on card: SwipeCard) {
        removeAllAnimationsCalled = true
        super.removeAllAnimations(on: card)
    }
    
    // MARK: - Animation Helpers
    
    // MARK: Add Fade Key Frame
    
    static var fadeView: UIView?
    static var fadeRelativeStartTime: TimeInterval?
    static var fadeRelativeDuration: TimeInterval?
    static var fadeAlpha: CGFloat?
    
    override class func addFadeKeyFrame(to view: UIView?,
                                        withRelativeStartTime relativeStartTime: TimeInterval = 0.0,
                                        relativeDuration: TimeInterval = 1.0,
                                        alpha: CGFloat) {
        fadeView = view
        fadeRelativeStartTime = relativeStartTime
        fadeRelativeDuration = relativeDuration
        fadeAlpha = alpha
    }
    
    // MARK: Add Transform Key Frame
    
    static var transformView: UIView?
    static var transformRelativeStartTime: TimeInterval?
    static var transformRelativeDuration: TimeInterval?
    static var transformTransform: CGAffineTransform?
    
    override class func addTransformKeyFrame(to view: UIView?,
                                             withRelativeStartTime relativeStartTime: TimeInterval,
                                             relativeDuration: TimeInterval,
                                             transform: CGAffineTransform) {
        transformView = view
        transformRelativeStartTime = relativeStartTime
        transformRelativeDuration = relativeDuration
        transformTransform = transform
    }
    
    // MARK: Animate Spring
    
    static var animateSpringDuration: TimeInterval?
    static var animateSpringOptions: UIView.AnimationOptions?
    static var animateSpringDamping: CGFloat?
    
    open override class func animateSpring(withDuration duration: TimeInterval,
                                           delay: TimeInterval = 0.0,
                                           usingSpringWithDamping damping: CGFloat,
                                           initialSpringVelocity: CGFloat = 0.0,
                                           options: UIView.AnimationOptions,
                                           animations: @escaping () -> Void,
                                           completion: ((Bool) -> Void)?) {
        animateSpringDuration = duration
        animateSpringOptions = options
        animateSpringDamping = damping
        super.animateSpring(withDuration: duration,
                            usingSpringWithDamping: damping,
                            options: options,
                            animations: animations) { _ in
                                completion?(true)
        }
    }
    
    // MARK: Animate Key Frames
    
    static var animateKeyFramesDuration: TimeInterval?
    static var animateKeyFramesOptions: UIView.KeyframeAnimationOptions?
    
    override class func animateKeyFrames(withDuration duration: TimeInterval,
                                         delay: TimeInterval = 0.0,
                                         options: UIView.KeyframeAnimationOptions,
                                         animations: @escaping (() -> Void),
                                         completion: ((Bool) -> Void)?) {
        animateKeyFramesDuration = duration
        animateKeyFramesOptions = options
        super.animateKeyFrames(withDuration: duration,
                               options: options,
                               animations: animations) { _ in
                                completion?(true)
        }
    }
    
    // MARK: - Test Helpers
    
    static func reset() {
        resetAnimationBlocks()
        resetAnimationCalculations()
        resetAnimationHelpers()
    }
    
    private static func resetAnimationBlocks() {
        resetAnimationBlockCalled = false
        swipeAnimationKeyFramesCalled = false
        reverseSwipeAnimationKeyFramesCalled = false
    }
    
    private static func resetAnimationCalculations() {
        testSwipeTransform = nil
        testSwipeTranslation = nil
        testSwipeRotationAngle = nil
        
        testSwipeDuration = nil
        testRelativeSwipeOverlayFadeDuration = nil
        testRelativeReverseSwipeOverlayFadeDuration = nil
    }
    
    private static func resetAnimationHelpers() {
        fadeView = nil
        fadeRelativeStartTime = nil
        fadeRelativeDuration = nil
        fadeAlpha = nil
        
        transformView = nil
        transformRelativeStartTime = nil
        transformRelativeDuration = nil
        transformTransform = nil
        
        animateSpringDuration = nil
        animateSpringOptions = nil
        animateSpringDamping = nil
        
        animateKeyFramesDuration = nil
        animateKeyFramesOptions = nil
    }
}
