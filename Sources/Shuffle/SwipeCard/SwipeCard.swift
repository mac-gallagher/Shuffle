///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

import UIKit

// swiftlint:disable:next identifier_name
let CardDidFinishSwipeAnimationNotification = NSNotification.Name(rawValue: "cardDidFinishSwipeAnimation")

open class SwipeCard: SwipeView {

  open var animationOptions: CardAnimatableOptions = CardAnimationOptions.default

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
  private var notificationCenter = NotificationCenter.default
  private var transformProvider: CardTransformProvidable = CardTransformProvider.shared

  // MARK: - Initialization

  override public init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  convenience init(animator: CardAnimatable,
                   layoutProvider: CardLayoutProvidable,
                   notificationCenter: NotificationCenter,
                   transformProvider: CardTransformProvidable) {
    self.init(frame: .zero)
    self.animator = animator
    self.layoutProvider = layoutProvider
    self.notificationCenter = notificationCenter
    self.transformProvider = transformProvider
  }

  private func initialize() {
    addSubview(overlayContainer)
    overlayContainer.setUserInteraction(false)
  }

  // MARK: - Layout

  override open func layoutSubviews() {
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
    overlays.values.forEach { $0.frame = overlayContainer.bounds }
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
    delegate?.card(didSwipe: self, with: direction)
    swipeAction(direction: direction, forced: false)
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

  /// Calling this method triggers a swipe animation.
  /// - Parameter direction: The direction to which the card will swipe off-screen.
  public func swipe(direction: SwipeDirection) {
    swipeAction(direction: direction, forced: true)
  }

  func swipeAction(direction: SwipeDirection, forced: Bool) {
    isUserInteractionEnabled = false
    animator.animateSwipe(on: self,
                          direction: direction,
                          forced: forced) { [weak self] finished in
                            if finished {
                              self?.swipeCompletionBlock()
                            }
    }
  }

  /// Calling this method triggers a reverse swipe (undo) animation.
  /// - Parameter direction: The direction from which the card will be coming off-screen.
  public func reverseSwipe(from direction: SwipeDirection) {
    isUserInteractionEnabled = false
    animator.animateReverseSwipe(on: self, from: direction) { [weak self] finished in
      if finished {
        self?.reverseSwipeCompletionBlock()
      }
    }
  }

  public func removeAllAnimations() {
    layer.removeAllAnimations()
    animator.removeAllAnimations(on: self)
  }
}
