import UIKit

/// A wrapper over `UIView` which detects customized swipe gestures. The swipe recognition is
/// based on both speed and translation, and can and be set for each direction.
///
/// This view is intended to be subclassed.
open class SwipeView: UIView {
    
    /// The swipe directions to be detected by the view. Subclasses can override this variable
    /// to ignore certain directions.
    open var swipeDirections: [SwipeDirection] {
        return SwipeDirection.allDirections
    }
    
    /// The pan gesture recognizer attached to the view.
    open var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer
    }
    
    private lazy var panRecognizer = UIPanGestureRecognizer(target: self,
                                                            action: #selector(handlePan))
    
    /// The tap gesture recognizer attached to the view.
    open var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self,
                                                            action: #selector(didTap))
    
    /// The member of `swipeDirections` which returns the highest `dragPercentage`.
    public var activeDirection: SwipeDirection? {
        return swipeDirections
            .reduce((percentage: CGFloat.zero, activeDirection: nil),
                    { [unowned self] lastResult, direction in
                        let dragPercentage = self.dragPercentage(direction)
                        return dragPercentage > lastResult.percentage
                            ? (dragPercentage, direction) : lastResult
            }).activeDirection
    }
    
    /// The speed of the user's drag projected onto the specified direction.
    ///
    /// Expressed in points per second.
    public var dragSpeed: (SwipeDirection) -> CGFloat {
        return { [unowned self] direction in
            let velocity = self.panGestureRecognizer.velocity(in: self.superview)
            return abs(direction.vector * CGVector(to: velocity))
        }
    }
    
    /// The percentage of `minimumSwipeDistance` the drag attains in the specified direction.
    ///
    /// The given swipe direction is not necessarily a member of `swipeDirections`.
    /// Can return a value greater than 1.
    public var dragPercentage: (SwipeDirection) -> CGFloat {
        return { [unowned self] direction in
            let translation = CGVector(to: self.panGestureRecognizer.translation(in: self.superview))
            let scaleFactor = 1 / self.minimumSwipeDistance(on: direction)
            let percentage = scaleFactor * (translation * direction.vector)
            return percentage < 0 ? 0 : percentage
        }
    }
    
    /// Initializes the `SwipeView` with the required gesture recognizers.
    ///
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    /// Initializes the `SwipeView` with the required gesture recognizers.
    ///
    /// - Parameter aDecoder: An unarchiver object.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(tapRecognizer)
    }
    
    /// The minimum required speed on the intended direction to trigger a swipe. Subclasses can override
    /// this method for custom swipe behavior.
    ///
    /// - Parameter direction: The swipe direction.
    /// - Returns: The minimum speed required to trigger a swipe in the indicated direction, measured in
    ///            points per second. Defaults to 1100 for each direction.
    open func minimumSwipeSpeed(on direction: SwipeDirection) -> CGFloat {
        return 1100
    }
    
    /// The minimum required drag distance on the intended direction to trigger a swipe, measured from the
    /// swipe's initial touch point. Subclasses can override this method for custom swipe behavior.
    ///
    /// - Parameter direction: The swipe direction.
    /// - Returns: The minimum distance required to trigger a swipe in the indicated direction, measured in
    ///            points. Defaults to 1/4 of the minimum of the screen's width/height.
    open func minimumSwipeDistance(on direction: SwipeDirection) -> CGFloat {
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 4
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .possible, .began:
            beginSwiping(recognizer)
        case .changed:
            continueSwiping(recognizer)
        case .ended, .cancelled:
            endSwiping(recognizer)
        default:
            break
        }
    }
    
    /// This function is called whenever the view is tapped. The default implementation does nothing;
    /// subclasses can override this method to perform whatever actions are necessary.
    ///
    /// - Parameter recognizer: The gesture recognizer associated with the tap.
    @objc open func didTap(_ recognizer: UITapGestureRecognizer) {}
    
    /// This function is called whenever the view recognizes the beginning of a swipe. The default
    /// implementation does nothing; subclasses can override this method to perform whatever actions
    /// are necessary.
    ///
    /// - Parameter recognizer: The gesture recognizer associated with the swipe.
    open func beginSwiping(_ recognizer: UIPanGestureRecognizer) {}
    
    /// This function is called whenever the view recognizes a change in the active swipe. The default
    /// implementation does nothing; subclasses can override this method to perform whatever actions are
    /// necessary.
    ///
    /// - Parameter recognizer: The gesture recognizer associated with the swipe.
    open func continueSwiping(_ recognizer: UIPanGestureRecognizer) {}
    
    /// This function is called whenever the view recognizes the end of a swipe, regardless if the swipe
    /// was successful or cancelled.
    ///
    /// - Parameter recognizer: The gesture recognizer associated with the swipe.
    open func endSwiping(_ recognizer: UIPanGestureRecognizer) {
        if let direction = activeDirection {
            if dragSpeed(direction) >= minimumSwipeSpeed(on: direction) || dragPercentage(direction) >= 1 {
                didSwipe(recognizer, with: direction)
                return
            }
        }
        didCancelSwipe(recognizer)
    }
    
    /// This function is called whenever the view recognizes a swipe. The default implementation does
    /// nothing; subclasses can override this method to perform whatever actions are necessary.
    ///
    /// - Parameters:
    ///   - recognizer: The gesture recognizer associated with the recognized swipe.
    ///   - direction: The direction of the swipe.
    open func didSwipe(_ recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {}
    
    /// This function is called whenever the view recognizes a cancelled swipe. The default implementation
    /// does nothing; subclasses can override this method to perform whatever actions are necessary.
    ///
    /// - Parameter recognizer: The gesture recognizer associated with the cancelled swipe.
    open func didCancelSwipe(_ recognizer: UIPanGestureRecognizer) {}
}
