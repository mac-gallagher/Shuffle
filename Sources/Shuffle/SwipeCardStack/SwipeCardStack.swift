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

open class SwipeCardStack: UIView, SwipeCardDelegate, UIGestureRecognizerDelegate {

  open var animationOptions: CardStackAnimatableOptions = CardStackAnimationOptions.default

  /// Return `false` if you wish to ignore all horizontal gestures on the card stack.
  ///
  /// You may wish to modify this property if your card stack is embedded in a `UIScrollView`.
  open var shouldRecognizeHorizontalDrag: Bool = true

  /// Return `false` if you wish to ignore all vertical gestures on the card stack.
  ///
  /// You may wish to modify this property if your card stack is embedded in a `UIScrollView`.
  open var shouldRecognizeVerticalDrag: Bool = true

  public weak var delegate: SwipeCardStackDelegate?

  public weak var dataSource: SwipeCardStackDataSource? {
    didSet {
      reloadData()
    }
  }

  public var cardStackInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) {
    didSet {
      setNeedsLayout()
    }
  }

  public var topCardIndex: Int? {
    return stateManager.remainingIndices.first
  }

  var numberOfVisibleCards: Int = 2
  var visibleCards: [SwipeCard] = []

  var topCard: SwipeCard? {
    return visibleCards.first
  }

  var backgroundCards: [SwipeCard] {
    return Array(visibleCards.dropFirst())
  }

  var isEnabled: Bool {
    return !isAnimating && (topCard?.isUserInteractionEnabled ?? true)
  }

  var isAnimating: Bool = false

  private var animator: CardStackAnimatable = CardStackAnimator.shared
  private var layoutProvider: CardStackLayoutProvidable = CardStackLayoutProvider.shared
  private var notificationCenter = NotificationCenter.default
  private var stateManager: CardStackStateManagable = CardStackStateManager.shared
  private var transformProvider: CardStackTransformProvidable = CardStackTransformProvider.shared

  private let cardContainer = UIView()

  // MARK: - Initialization

  override public init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  convenience init(animator: CardStackAnimatable,
                   layoutProvider: CardStackLayoutProvidable,
                   notificationCenter: NotificationCenter,
                   stateManager: CardStackStateManagable,
                   transformProvider: CardStackTransformProvidable) {
    self.init(frame: .zero)
    self.animator = animator
    self.layoutProvider = layoutProvider
    self.notificationCenter = notificationCenter
    self.stateManager = stateManager
    self.transformProvider = transformProvider
  }

  private func initialize() {
    addSubview(cardContainer)
    notificationCenter.addObserver(self,
                                   selector: #selector(didFinishSwipeAnimation),
                                   name: CardDidFinishSwipeAnimationNotification,
                                   object: nil)
  }

  // MARK: - Layout

  override open func layoutSubviews() {
    super.layoutSubviews()
    cardContainer.frame = layoutProvider.createCardContainerFrame(for: self)
    for (index, card) in visibleCards.enumerated() {
      layoutCard(card, at: index)
    }
  }

  func layoutCard(_ card: SwipeCard, at index: Int) {
    card.transform = .identity
    card.frame = layoutProvider.createCardFrame(for: self)
    card.transform = transform(forCardAtIndex: index)
    card.isUserInteractionEnabled = index == 0
  }

  func scaleFactor(forCardAtIndex index: Int) -> CGPoint {
    return index == 0 ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.95, y: 0.95)
  }

  func transform(forCardAtIndex index: Int) -> CGAffineTransform {
    let cardScaleFactor = scaleFactor(forCardAtIndex: index)
    return CGAffineTransform(scaleX: cardScaleFactor.x, y: cardScaleFactor.y)
  }

  override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let topCard = topCard, topCard.panGestureRecognizer == gestureRecognizer else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    let velocity = topCard.panGestureRecognizer.velocity(in: self)

    if abs(velocity.x) > abs(velocity.y) {
      return shouldRecognizeHorizontalDrag
    }

    if abs(velocity.x) < abs(velocity.y) {
      return shouldRecognizeVerticalDrag
    }

    return topCard.gestureRecognizerShouldBegin(gestureRecognizer)
  }

  // MARK: - Main Methods

  /// Calling this method triggers a swipe on the card stack.
  /// - Parameters:
  ///   - direction: The direction to swipe the top card.
  ///   - animated: A boolean indicating whether the reverse swipe should be animated. Setting this
  ///    to `false` will immediately
  ///   position the card at end state of the animation when the method is called.
  public func swipe(_ direction: SwipeDirection, animated: Bool) {
    if !isEnabled { return }

    if animated {
      topCard?.swipe(direction: direction)
    } else {
      topCard?.removeFromSuperview()
    }

    if let topCard = topCard {
      swipeAction(topCard: topCard,
                  direction: direction,
                  forced: true,
                  animated: animated)
    }
  }

  func swipeAction(topCard: SwipeCard,
                   direction: SwipeDirection,
                   forced: Bool,
                   animated: Bool) {
    guard let swipedIndex = topCardIndex else { return }
    stateManager.swipe(direction)
    visibleCards.remove(at: 0)

    // insert new card if needed
    if (stateManager.remainingIndices.count - visibleCards.count) > 0 {
      let bottomCardIndex = stateManager.remainingIndices[visibleCards.count]
      if let card = loadCard(at: bottomCardIndex) {
        insertCard(card, at: visibleCards.count)
      }
    }

    delegate?.cardStack?(self, didSwipeCardAt: swipedIndex, with: direction)

    if stateManager.remainingIndices.isEmpty {
      delegate?.didSwipeAllCards?(self)
      return
    }

    isAnimating = true
    animator.animateSwipe(self,
                          topCard: topCard,
                          direction: direction,
                          forced: forced,
                          animated: animated) { [weak self] finished in
                            if finished {
                              self?.isAnimating = false
                            }
    }
  }

  public func undoLastSwipe(animated: Bool) {
    if !isEnabled { return }
    guard let previousSwipe = stateManager.undoSwipe() else { return }

    reloadVisibleCards()
    delegate?.cardStack?(self, didUndoCardAt: previousSwipe.index, from: previousSwipe.direction)

    if animated {
      topCard?.reverseSwipe(from: previousSwipe.direction)
    }

    isAnimating = true
    if let topCard = topCard {
      animator.animateUndo(self,
                           topCard: topCard,
                           animated: animated) { [weak self] finished in
                            if finished {
                              self?.isAnimating = false
                            }
      }
    }
  }

  public func shift(withDistance distance: Int = 1, animated: Bool) {
    if !isEnabled || distance == 0 || visibleCards.count <= 1 { return }

    stateManager.shift(withDistance: distance)
    reloadVisibleCards()

    isAnimating = true
    animator.animateShift(self,
                          withDistance: distance,
                          animated: animated) { [weak self] finished in
                            if finished {
                              self?.isAnimating = false
                            }
    }
  }

  // MARK: - Data Source

  public func reloadData() {
    guard let dataSource = dataSource else { return }
    let numberOfCards = dataSource.numberOfCards(in: self)
    stateManager.reset(withNumberOfCards: numberOfCards)
    reloadVisibleCards()
    isAnimating = false
  }

  func reloadVisibleCards() {
    visibleCards.forEach { $0.removeFromSuperview() }
    visibleCards.removeAll()

    let numberOfCards = min(stateManager.remainingIndices.count, numberOfVisibleCards)
    for index in 0..<numberOfCards {
      if let card = loadCard(at: stateManager.remainingIndices[index]) {
        insertCard(card, at: index)
      }
    }
  }

  func insertCard(_ card: SwipeCard, at index: Int) {
    cardContainer.insertSubview(card, at: visibleCards.count - index)
    layoutCard(card, at: index)
    visibleCards.insert(card, at: index)
  }

  func loadCard(at index: Int) -> SwipeCard? {
    let card = dataSource?.cardStack(self, cardForIndexAt: index)
    card?.delegate = self
    card?.panGestureRecognizer.delegate = self
    return card
  }

  // MARK: - Notifications

  @objc
  func didFinishSwipeAnimation(_ notification: NSNotification) {
    guard let card = notification.object as? SwipeCard else { return }
    card.removeFromSuperview()
  }

  // MARK: - SwipeCardDelegate

  func card(didTap card: SwipeCard) {
    guard let topCardIndex = topCardIndex else { return }
    delegate?.cardStack?(self, didSelectCardAt: topCardIndex)
  }

  func card(didBeginSwipe card: SwipeCard) {
    animator.removeBackgroundCardAnimations(self)
  }

  func card(didContinueSwipe card: SwipeCard) {
    for (index, backgroundCard) in backgroundCards.enumerated() {
      backgroundCard.transform = transformProvider.backgroundCardDragTransform(for: self,
                                                                               topCard: card,
                                                                               topCardIndex: index + 1)
    }
  }

  func card(didCancelSwipe card: SwipeCard) {
    animator.animateReset(self, topCard: card)
  }

  func card(didSwipe card: SwipeCard,
            with direction: SwipeDirection) {
    swipeAction(topCard: card, direction: direction, forced: false, animated: true)
  }
}
