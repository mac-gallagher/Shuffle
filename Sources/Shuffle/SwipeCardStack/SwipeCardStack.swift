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

  /// A internal structure for a `SwipeCard` and it's corresponding index in the card stack's `dataSource`.
  struct Card {
    var index: Int
    var card: SwipeCard
  }

  open var animationOptions: CardStackAnimatableOptions = CardStackAnimationOptions.default

  /// Return `false` if you wish to ignore all horizontal gestures on the card stack.
  ///
  /// You may wish to modify this property if your card stack is embedded in a `UIScrollView`, for example.
  open var shouldRecognizeHorizontalDrag: Bool = true

  /// Return `false` if you wish to ignore all vertical gestures on the card stack.
  ///
  /// You may wish to modify this property if your card stack is embedded in a `UIScrollView`, for example.
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

  /// The data source index corresponding to the topmost card in the stack.
  public var topCardIndex: Int? {
    return visibleCards.first?.index
  }

  var numberOfVisibleCards: Int = 2

  /// An ordered array containing all pairs of currently visible cards.
  ///
  /// The `Card` at the first position is the topmost `SwipeCard` in the view hierarchy.
  var visibleCards: [Card] = []

  var topCard: SwipeCard? {
    return visibleCards.first?.card
  }

  var backgroundCards: [SwipeCard] {
    return Array(visibleCards.dropFirst()).map { $0.card }
  }

  var isEnabled: Bool {
    return !isAnimating && (topCard?.isUserInteractionEnabled ?? true)
  }

  var isAnimating: Bool = false

  private var animator: CardStackAnimatable = CardStackAnimator.shared
  private var layoutProvider: CardStackLayoutProvidable = CardStackLayoutProvider.shared
  private var notificationCenter = NotificationCenter()
  private var stateManager: CardStackStateManagable = CardStackStateManager()
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
    for (position, value) in visibleCards.enumerated() {
      layoutCard(value.card, at: position)
    }
  }

  func layoutCard(_ card: SwipeCard, at position: Int) {
    card.transform = .identity
    card.frame = layoutProvider.createCardFrame(for: self)
    card.transform = transform(forCardAtPosition: position)
    card.isUserInteractionEnabled = position == 0
  }

  func scaleFactor(forCardAtPosition position: Int) -> CGPoint {
    return position == 0 ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.95, y: 0.95)
  }

  func transform(forCardAtPosition position: Int) -> CGAffineTransform {
    let cardScaleFactor = scaleFactor(forCardAtPosition: position)
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

  /// Triggers a swipe on the card stack in the specified direction.
  /// - Parameters:
  ///   - direction: The direction to swipe the top card.
  ///   - animated: A boolean indicating whether the swipe action should be animated.
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

    // Insert new card if needed
    if (stateManager.remainingIndices.count - visibleCards.count) > 0 {
      let bottomCardIndex = stateManager.remainingIndices[visibleCards.count]
      if let card = loadCard(at: bottomCardIndex) {
        insertCard(Card(index: bottomCardIndex, card: card), at: visibleCards.count)
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

  /// Returns the most recently swiped card to the top of the card stack.
  /// - Parameter animated: A boolean indicating whether the undo action should be animated.
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

  /// Shifts the remaining cards in the card stack by the specified distance. Any swiped cards are ignored.
  /// - Parameters:
  ///   - distance: The distance to shift the remaining cards by.
  ///   - animated: A boolean indicating whether the undo action should be animated.
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

  /// Returns the `SwipeCard` at the specified index.
  /// - Parameter index: The index of the card in the data source.
  /// - Returns: The `SwipeCard` at the specified index, or `nil` if the card is not visible or the index is
  /// out of range.
  public func card(forIndexAt index: Int) -> SwipeCard? {
    for value in visibleCards where value.index == index {
      return value.card
    }
    return nil
  }

  func reloadVisibleCards() {
    visibleCards.forEach { $0.card.removeFromSuperview() }
    visibleCards.removeAll()

    let numberOfCards = min(stateManager.remainingIndices.count, numberOfVisibleCards)
    for position in 0..<numberOfCards {
      let index = stateManager.remainingIndices[position]
      if let card = loadCard(at: index) {
        insertCard(Card(index: index, card: card), at: position)
      }
    }
  }

  func insertCard(_ value: Card, at position: Int) {
    cardContainer.insertSubview(value.card, at: visibleCards.count - position)
    layoutCard(value.card, at: position)
    visibleCards.insert(value, at: position)
  }

  func loadCard(at index: Int) -> SwipeCard? {
    let card = dataSource?.cardStack(self, cardForIndexAt: index)
    card?.delegate = self
    card?.panGestureRecognizer.delegate = self
    return card
  }

  // MARK: - State Management

  /// Returns the current position of the card at the specified index.
  ///
  /// A returned value of `0` indicates that the card is the topmost card in the stack.
  /// - Parameter index: The index of the card in the data source.
  /// - Returns: The current position of the card at the specified index, or `nil` if the index if out of range or the
  /// card has been swiped.
  public func positionforCard(at index: Int) -> Int? {
    return stateManager.remainingIndices.firstIndex(of: index)
  }

  /// Returns the remaining number of cards in the card stack.
  /// - Returns: The number of cards in the card stack which have not yet been swiped.
  public func numberOfRemainingCards() -> Int {
    return stateManager.remainingIndices.count
  }

  /// Returns the indices of the swiped cards in the order they were swiped.
  /// - Returns: The indices of the swiped cards in the data source.
  public func swipedCards() -> [Int] {
    return stateManager.swipes.map { $0.index }
  }

  /// Inserts a new card with the given index at the specified position.
  ///
  /// Calling this method will not clear the swipe history nor trigger a reload of the data source.
  /// - Parameters:
  ///   - index: The index of the card in the data source.
  ///   - position: The position of the new card in the card stack.
  public func insertCard(atIndex index: Int, position: Int) {
    guard let dataSource = dataSource else { return }

    let oldNumberOfCards = stateManager.totalIndexCount
    let newNumberOfCards = dataSource.numberOfCards(in: self)

    stateManager.insert(index, at: position)

    if newNumberOfCards != oldNumberOfCards + 1 {
      let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                   oldCount: oldNumberOfCards,
                                                                   insertedCount: 1)
      fatalError(errorString)
    }

    reloadVisibleCards()
  }

  /// Appends a collection of new cards with the specifed indices to the bottom of the card stack.
  ///
  /// Calling this method will not clear the swipe history nor trigger a reload of the data source.
  /// - Parameter indices: The indices of the cards in the data source.
  public func appendCards(atIndices indices: [Int]) {
    guard let dataSource = dataSource else { return }

    let oldNumberOfCards = stateManager.totalIndexCount
    let newNumberOfCards = dataSource.numberOfCards(in: self)

    for index in indices {
      stateManager.insert(index, at: numberOfRemainingCards())
    }

    if newNumberOfCards != oldNumberOfCards + indices.count {
      let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                   oldCount: oldNumberOfCards,
                                                                   insertedCount: indices.count)
      fatalError(errorString)
    }

    reloadVisibleCards()
  }

  /// Deletes the cards at the specified indices. If an index corresponds to a card that has been swiped,
  /// it is removed from the swipe history.
  ///
  /// Calling this method will not clear the swipe history nor trigger a reload of the data source.
  /// - Parameter indices: The indices of the cards in the data source to delete.
  public func deleteCards(atIndices indices: [Int]) {
    guard let dataSource = dataSource else { return }

    let oldNumberOfCards = stateManager.totalIndexCount
    let newNumberOfCards = dataSource.numberOfCards(in: self)

    if newNumberOfCards != oldNumberOfCards - indices.count {
      let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                   oldCount: oldNumberOfCards,
                                                                   deletedCount: indices.count)
      fatalError(errorString)
    }

    stateManager.delete(indices)
    reloadVisibleCards()
  }

  /// Deletes the cards at the specified positions in the card stack.
  ///
  /// Calling this method will not clear the swipe history nor trigger a reload of the data source.
  /// - Parameter positions: The positions of the cards to delete in the card stack.
  public func deleteCards(atPositions positions: [Int]) {
    guard let dataSource = dataSource else { return }

    let oldNumberOfCards = stateManager.totalIndexCount
    let newNumberOfCards = dataSource.numberOfCards(in: self)

    if newNumberOfCards != oldNumberOfCards - positions.count {
      let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                   oldCount: oldNumberOfCards,
                                                                   deletedCount: positions.count)
      fatalError(errorString)
    }

    stateManager.delete(indicesAtPositions: positions)
    reloadVisibleCards()
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
    for (position, backgroundCard) in backgroundCards.enumerated() {
      backgroundCard.transform = transformProvider.backgroundCardDragTransform(for: self,
                                                                               topCard: card,
                                                                               currentPosition: position + 1)
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
