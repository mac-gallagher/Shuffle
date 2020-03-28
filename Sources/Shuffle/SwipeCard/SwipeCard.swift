import UIKit

let CardDidFinishSwipeAnimationNotification = NSNotification.Name(rawValue: "cardDidFinishSwipeAnimation")

open class SwipeCard: SwipeView {
    
    public var animationOptions: CardAnimatableOptions = CardAnimationOptions.default
    
    public var footerHeight: CGFloat = 100 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var content: UIView? {
        didSet {
            if let content = content {
                oldValue?.removeFromSuperview()
                addSubview(content)
            }
        }
    }
    
    public var footer: UIView? {
        didSet {
            if let footer = footer {
                oldValue?.removeFromSuperview()
                addSubview(footer)
            }
        }
    }
    
    public var leftOverlay: UIView? {
        return overlays[.left]
    }
    
    public var upOverlay: UIView? {
        return overlays[.up]
    }
    
    public var rightOverlay: UIView? {
        return overlays[.right]
    }
    
    public var downOverlay: UIView? {
        return overlays[.down]
    }
    
    weak var delegate: SwipeCardDelegate?
    
    var overlays = [SwipeDirection: UIView]()
    
    var touchLocation: CGPoint? {
        return touchPoint
    }
    
    private var touchPoint: CGPoint?
    
    // MARK: Completion Handlers
    
    var swipeCompletion: () -> Void {
        return { [unowned self] in
            self.notificationCenter.post(name: CardDidFinishSwipeAnimationNotification, object: self)
        }
    }
    
    var reverseSwipeCompletion: (SwipeDirection) -> Void {
        return { [unowned self] direction in
            self.isUserInteractionEnabled = true
        }
    }
    
    var animator: CardAnimatable.Type = CardAnimator.self
    
    private let overlayContainer = UIView()
    
    private var layoutProvider: CardLayoutProvidable.Type = CardLayoutProvider.self
    private var transformProvider: CardTransformProvidable.Type = CardTransformProvider.self
    private var notificationCenter = NotificationCenter.default
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(animator: CardAnimatable.Type,
         layoutProvider: CardLayoutProvidable.Type,
         transformProvider: CardTransformProvidable.Type,
         notificationCenter: NotificationCenter) {
        self.init(frame: .zero)
        self.animator = animator
        self.layoutProvider = layoutProvider
        self.transformProvider = transformProvider
        self.notificationCenter = notificationCenter
    }
    
    private func initialize() {
        addSubview(overlayContainer)
        addOverlays()
    }
    
    func addOverlays() {
        for direction in swipeDirections {
            if let overlay = overlay(forDirection: direction) {
                overlays[direction] = overlay
                overlayContainer.addSubview(overlay)
                overlay.alpha = 0
            }
        }
        overlayContainer.setUserInteraction(false)
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        footer?.frame = layoutProvider.footerFrame(self)
        layoutContentView()
        layoutOverlays()
    }
    
    private func layoutContentView() {
        guard let content = content else { return }
        content.frame = layoutProvider.contentFrame(self)
        sendSubviewToBack(content)
    }
    
    private func layoutOverlays() {
        overlayContainer.frame = layoutProvider.overlayContainerFrame(self)
        bringSubviewToFront(overlayContainer)
        for overlay in overlays.values {
            overlay.frame = overlayContainer.bounds
        }
    }
    
    // MARK: - Overrides
    
    override open func didTap(_ recognizer: UITapGestureRecognizer) {
        super.didTap(recognizer)
        touchPoint = recognizer.location(in: self)
        delegate?.card(didTap: self)
    }
    
    override open func beginSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.beginSwiping(recognizer)
        touchPoint = recognizer.location(in: self)
        delegate?.card(didBeginSwipe: self)
        animator.removeAllAnimations(on: self)
    }
    
    override open func continueSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.continueSwiping(recognizer)
        delegate?.card(didContinueSwipe: self)
        
        transform = transformProvider.cardTransform(self)
        
        for (direction, overlay) in overlays {
            overlay.alpha = transformProvider.cardOverlayPercentage(self, direction)
        }
    }
    
    override open func didSwipe(_ recognizer: UIPanGestureRecognizer,
                                with direction: SwipeDirection) {
        super.didSwipe(recognizer, with: direction)
        swipeAction(direction: direction, forced: false, animated: true)
    }
    
    override open func didCancelSwipe(_ recognizer: UIPanGestureRecognizer) {
        super.didCancelSwipe(recognizer)
        delegate?.card(didCancelSwipe: self)
        animator.reset(self)
    }
    
    // MARK: - Main Methods
    
    open func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return nil
    }
    
    public func swipe(direction: SwipeDirection, animated: Bool) {
        swipeAction(direction: direction, forced: true, animated: animated)
    }
    
    func swipeAction(direction: SwipeDirection, forced: Bool, animated: Bool) {
        isUserInteractionEnabled = false
        delegate?.card(didSwipe: self, with: direction, forced: forced)
        if animated {
            animator.swipe(self, direction: direction, forced: forced)
        } else {
            swipeCompletion()
        }
    }
    
    public func reverseSwipe(from direction: SwipeDirection, animated: Bool) {
        isUserInteractionEnabled = false
        delegate?.card(didReverseSwipe: self, from: direction)
        if animated {
            animator.reverseSwipe(self, from: direction)
        } else {
            reverseSwipeCompletion(direction)
        }
    }
    
    public func removeAllAnimations() {
        layer.removeAllAnimations()
        animator.removeAllAnimations(on: self)
    }
}
