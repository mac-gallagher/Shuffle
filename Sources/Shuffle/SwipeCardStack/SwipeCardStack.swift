import UIKit

open class SwipeCardStack: UIView, SwipeCardDelegate {

  public var animationOptions: CardStackAnimatableOptions = CardStackAnimationOptions.default

  public weak var delegate: SwipeCardStackDelegate?

  public weak var dataSource: SwipeCardStackDataSource? {
    didSet {
      reloadData()
    }
  }

  public var numberOfVisibleCards: Int = 2 {
    didSet {
      reloadData()
    }
  }

  public var cardStackInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) {
    didSet {
      setNeedsLayout()
    }
  }

  // MARK: - Card Variables

  public var topCardIndex: Int? {
    return stateManager.remainingIndices.first
  }

  var visibleCards: [SwipeCard] = []

  var topCard: SwipeCard? {
    return visibleCards.first
  }

  var backgroundCards: [SwipeCard] {
    return Array(visibleCards.dropFirst())
  }

  var isEnabled: Bool {
    return isUserInteractionEnabled && (topCard?.isUserInteractionEnabled ?? true)
  }

  // MARK: - Completion Handlers

  var swipeCompletionBlock: () -> Void {
    return { [weak self] in
      self?.isUserInteractionEnabled = true
    }
  }

  var undoCompletionBlock: () -> Void {
    return { [weak self] in
      self?.isUserInteractionEnabled = true
    }
  }

  var shiftCompletionBlock: () -> Void {
    return { [weak self] in
      self?.isUserInteractionEnabled = true
    }
  }
  
  private var animator: CardStackAnimatable = CardStackAnimator.shared
  private var layoutProvider: CardStackLayoutProvidable = CardStackLayoutProvider.shared
  private var notificationCenter = NotificationCenter.default
  private var stateManager: CardStackStateManagable = CardStackStateManager.shared
  private var transformProvider: CardStackTransformProvidable = CardStackTransformProvider.shared

  private let cardContainer = UIView()

  // MARK: - Initialization

  public override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required public init?(coder aDecoder: NSCoder) {
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

  open override func layoutSubviews() {
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

  // MARK: - Main Methods

  public func swipe(_ direction: SwipeDirection, animated: Bool) {
    if !isEnabled { return }
    topCard?.swipe(direction: direction, animated: animated)
  }

  public func undoLastSwipe(animated: Bool) {
    if !isEnabled { return }
    guard let previousSwipe = stateManager.undoSwipe() else { return }

    reloadVisibleCards()
    delegate?.cardStack?(self, didUndoCardAt: previousSwipe.index, from: previousSwipe.direction)
    topCard?.reverseSwipe(from: previousSwipe.direction, animated: animated)
  }

  public func shift(withDistance distance: Int = 1, animated: Bool) {
    if !isEnabled || distance == 0 || visibleCards.count <= 1 { return }

    stateManager.shift(withDistance: distance)
    reloadVisibleCards()

    if animated {
      isUserInteractionEnabled = false
      animator.animateShift(self, withDistance: distance)
    }
  }

  // MARK: - Data Source

  public func reloadData() {
    guard let dataSource = dataSource else { return }
    let numberOfCards = dataSource.numberOfCards(in: self)
    stateManager.reset(withNumberOfCards: numberOfCards)
    reloadVisibleCards()
    isUserInteractionEnabled = true
  }

  func reloadVisibleCards() {
    visibleCards.forEach { card in
      card.removeFromSuperview()
    }
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
    return card
  }

  // MARK: - Notifications

  @objc func didFinishSwipeAnimation(_ notification: NSNotification) {
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
    guard let topCard = topCard else { return }
    for (index, card) in backgroundCards.enumerated() {
      card.transform = transformProvider.backgroundCardDragTransform(for: self, topCard: topCard, topCardIndex: index + 1)
    }
  }

  func card(didCancelSwipe card: SwipeCard) {
    animator.animateReset(self, topCard: card)
  }

  func card(didSwipe card: SwipeCard, with direction: SwipeDirection, forced: Bool) {
    if let topCardIndex = topCardIndex {
      delegate?.cardStack?(self, didSwipeCardAt: topCardIndex, with: direction)
    }

    stateManager.swipe(direction)
    visibleCards.remove(at: 0)

    // insert new card if needed
    if stateManager.remainingIndices.count - visibleCards.count > 0 {
      let bottomCardIndex = stateManager.remainingIndices[visibleCards.count]
      if let card = loadCard(at: bottomCardIndex) {
        insertCard(card, at: visibleCards.count)
      }
    } else if stateManager.remainingIndices.count == 0 {
      delegate?.didSwipeAllCards?(self)
    }

    isUserInteractionEnabled = false
    animator.animateSwipe(self, topCard: card, direction: direction, forced: forced)
  }

  func card(didReverseSwipe card: SwipeCard, from direction: SwipeDirection) {
    isUserInteractionEnabled = false
    animator.animateUndo(self, topCard: card)
  }
}
