import UIKit

let CardDidFinishSwipeAnimationNotification = NSNotification.Name(rawValue: "cardDidFinishSwipeAnimation")

open class SwipeCard: SwipeView {

  public var animationOptions: CardAnimatableOptions = CardAnimationOptions.default

  /// The the main content view.
  public var content: UIView? {
    didSet {
      if let content = content {
        oldValue?.removeFromSuperview()
        addSubview(content)
      }
    }
  }

  /// The the footer view.
  public var footer: UIView? {
    didSet {
      if let footer = footer {
        oldValue?.removeFromSuperview()
        addSubview(footer)
      }
    }
  }

  /// The height of the footer view.
  public var footerHeight: CGFloat = 100 {
    didSet {
      setNeedsLayout()
    }
  }

  weak var delegate: SwipeCardDelegate?

  var touchLocation: CGPoint? {
    return internalTouchLocation
  }

  private var internalTouchLocation: CGPoint?

  var swipeCompletionBlock: () -> Void {
    return { [weak self] in
      self?.notificationCenter.post(name: CardDidFinishSwipeAnimationNotification, object: self)
    }
  }

  var reverseSwipeCompletionBlock: () -> Void {
    return { [weak self] in
      self?.isUserInteractionEnabled = true
    }
  }

  private let overlayContainer = UIView()
  private var overlays = [SwipeDirection: UIView]()

  private var animator: CardAnimatable = CardAnimator.shared
  private var layoutProvider: CardLayoutProvidable = CardLayoutProvider.shared
  private var transformProvider: CardTransformProvidable = CardTransformProvider.shared
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

  convenience init(animator: CardAnimatable,
                   layoutProvider: CardLayoutProvidable,
                   transformProvider: CardTransformProvidable,
                   notificationCenter:NotificationCenter) {
    self.init(frame: .zero)
    self.animator = animator
    self.layoutProvider = layoutProvider
    self.transformProvider = transformProvider
    self.notificationCenter = notificationCenter
  }

  private func initialize() {
    addSubview(overlayContainer)
    overlayContainer.setUserInteraction(false)
  }

  // MARK: - Layout

  open override func layoutSubviews() {
    super.layoutSubviews()
    footer?.frame = layoutProvider.createFooterFrame(for: self)
    layoutContentView()
    layoutOverlays()
  }

  private func layoutContentView() {
    guard let content = content else { return }
    content.frame = layoutProvider.createContentFrame(for: self)
    sendSubviewToBack(content)
  }

  private func layoutOverlays() {
    overlayContainer.frame = layoutProvider.createOverlayContainerFrame(for: self)
    bringSubviewToFront(overlayContainer)
    for overlay in overlays.values {
      overlay.frame = overlayContainer.bounds
    }
  }

  // MARK: - Overrides

  override open func didTap(_ recognizer: UITapGestureRecognizer) {
    super.didTap(recognizer)
    internalTouchLocation = recognizer.location(in: self)
    delegate?.card(didTap: self)
  }

  override open func beginSwiping(_ recognizer: UIPanGestureRecognizer) {
    super.beginSwiping(recognizer)
    internalTouchLocation = recognizer.location(in: self)
    delegate?.card(didBeginSwipe: self)
    animator.removeAllAnimations(on: self)
  }

  override open func continueSwiping(_ recognizer: UIPanGestureRecognizer) {
    super.continueSwiping(recognizer)
    delegate?.card(didContinueSwipe: self)

    transform = transformProvider.transform(for: self)

    for (direction, overlay) in overlays {
      overlay.alpha = transformProvider.overlayPercentage(for: self, direction: direction)
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
    animator.animateReset(on: self)
  }

  // MARK: - Main Methods

  public func setOverlay(_ overlay: UIView?, forDirection direction: SwipeDirection) {
    overlays[direction]?.removeFromSuperview()
    overlays[direction] = overlay

    if let overlay = overlay {
      overlayContainer.addSubview(overlay)
      overlay.alpha = 0
      overlay.setUserInteraction(false)
    }
  }

  public func setOverlays(_ overlays: [SwipeDirection: UIView]) {
    for (direction, overlay) in overlays {
      setOverlay(overlay, forDirection: direction)
    }
  }

  public func overlay(forDirection direction: SwipeDirection) -> UIView? {
    return overlays[direction]
  }

  public func swipe(direction: SwipeDirection, animated: Bool) {
    swipeAction(direction: direction, forced: true, animated: animated)
  }

  func swipeAction(direction: SwipeDirection, forced: Bool, animated: Bool) {
    isUserInteractionEnabled = false
    delegate?.card(didSwipe: self, with: direction, forced: forced)
    if animated {
      animator.animateSwipe(on: self, direction: direction, forced: forced)
    } else {
      swipeCompletionBlock()
    }
  }

  public func reverseSwipe(from direction: SwipeDirection, animated: Bool) {
    isUserInteractionEnabled = false
    delegate?.card(didReverseSwipe: self, from: direction)
    if animated {
      animator.animateReverseSwipe(on: self, from: direction)
    } else {
      reverseSwipeCompletionBlock()
    }
  }

  public func removeAllAnimations() {
    layer.removeAllAnimations()
    animator.removeAllAnimations(on: self)
  }
}
