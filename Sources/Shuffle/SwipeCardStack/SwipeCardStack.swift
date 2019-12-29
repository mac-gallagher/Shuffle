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
    
    public var cardStackInsets
        = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Card Variables
    
    public var topCardIndex: Int {
        return currentState.remainingIndices.first ?? 0
    }
    
    var visibleCards: [SwipeCard] = []
    
    var topCard: SwipeCard? {
        return visibleCards.first
    }
    
    var backgroundCards: [SwipeCard] {
        return Array(visibleCards.dropFirst())
    }
    
    var currentState: CardStackState = .emptyState
    
    var isEnabled: Bool {
        return isUserInteractionEnabled && (topCard?.isUserInteractionEnabled ?? true)
    }
    
    // MARK: - Completion Handlers
    
    var swipeCompletion: () -> Void {
        return { [unowned self] in
            self.isUserInteractionEnabled = true
        }
    }
    
    var undoCompletion: () -> Void {
        return { [unowned self] in
            self.isUserInteractionEnabled = true
        }
    }
    
    var shiftCompletion: () -> Void {
        return { [unowned self] in
            self.isUserInteractionEnabled = true
        }
    }
    
    private var animator: CardStackAnimatable.Type
        = CardStackAnimator.self
    private var layoutProvider: CardStackLayoutProvidable.Type
        = CardStackLayoutProvider.self
    private var transformProvider: CardStackTransformProvidable.Type
        = CardStackTransformProvider.self
    private var notificationCenter = NotificationCenter.default
    
    private let cardContainer = UIView()
    
    //MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(animator: CardStackAnimatable.Type,
                     transformProvider: CardStackTransformProvidable.Type,
                     layoutProvider: CardStackLayoutProvidable.Type,
                     notificationCenter: NotificationCenter) {
        self.init(frame: .zero)
        self.animator = animator
        self.transformProvider = transformProvider
        self.layoutProvider = layoutProvider
        self.notificationCenter = notificationCenter
    }
    
    private func initialize() {
        addSubview(cardContainer)
        notificationCenter.addObserver(self,
                                       selector: #selector(didFinishSwipeAnimation),
                                       name: CardDidFinishSwipeAnimationNotification,
                                       object: nil)
    }
    
    //MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        cardContainer.frame = layoutProvider.cardContainerFrame(self)
        for (index, card) in visibleCards.enumerated() {
            layoutCard(card, at: index)
        }
    }
    
    func layoutCard(_ card: SwipeCard, at index: Int) {
        card.transform = .identity
        card.frame = layoutProvider.cardFrame(self)
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
    
    //MARK: - Main Methods
    
    public func swipe(_ direction: SwipeDirection, animated: Bool) {
        if !isEnabled { return }
        topCard?.swipe(direction: direction, animated: animated)
    }
    
    public func undoLastSwipe(animated: Bool) {
        if !isEnabled { return }
        
        guard let previousState = currentState.previousState,
            let previousSwipe = currentState.previousSwipe else { return }
        
        delegate?.cardStack?(self,
                            didUndoCardAt: previousSwipe.index,
                            from: previousSwipe.direction)
        
        loadState(previousState)
        
        topCard?.reverseSwipe(from: previousSwipe.direction, animated: animated)
    }
    
    public func shift(withDistance distance: Int = 1, animated: Bool) {
        if !isEnabled || distance == 0 || visibleCards.count <= 1 { return }
        
        let remainingIndices =
            currentState.remainingIndices.shift(withDistance: distance)
        let newState = CardStackState(remainingIndices: remainingIndices,
                                      previousSwipe: currentState.previousSwipe,
                                      previousState: currentState.previousState)
        loadState(newState)
        
        if animated {
            isUserInteractionEnabled = false
            animator.shift(self, withDistance: distance)
        }
    }
    
    //MARK: - Data Source
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        let numberOfCards = dataSource.numberOfCards(in: self)
        let initialState = CardStackState(remainingIndices: Array(0..<numberOfCards))
        loadState(initialState)
        isUserInteractionEnabled = true
    }
    
    func loadState(_ state: CardStackState) {
        visibleCards.forEach { card in
            card.removeFromSuperview()
        }
        visibleCards.removeAll()
        
        currentState = state
        
        let numberOfCards = min(currentState.remainingIndices.count,
                                numberOfVisibleCards)
        for index in 0..<numberOfCards {
            if let card = loadCard(at: currentState.remainingIndices[index]) {
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
        delegate?.cardStack?(self, didSelectCardAt: topCardIndex)
    }
    
    func card(didBeginSwipe card: SwipeCard) {
        animator.removeBackgroundCardAnimations(self)
    }
    
    func card(didContinueSwipe card: SwipeCard) {
        guard let topCard = topCard else { return }
        for (index, card) in backgroundCards.enumerated() {
            card.transform
                = transformProvider.backgroundCardDragTransform(self, topCard, index + 1)
        }
    }
    
    func card(didCancelSwipe card: SwipeCard) {
        animator.reset(self, topCard: card)
    }
    
    func card(didSwipe card: SwipeCard, with direction: SwipeDirection, forced: Bool) {
        delegate?.cardStack?(self, didSwipeCardAt: topCardIndex, with: direction)
        
        updateSwipeState(direction: direction)
        
        //insert new card if needed
        if currentState.remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = currentState.remainingIndices[visibleCards.count]
            if let card = loadCard(at: bottomCardIndex) {
                insertCard(card, at: visibleCards.count)
            }
        }
        
        //no cards left
        if currentState.remainingIndices.count == 0 {
            delegate?.didSwipeAllCards?(self)
        }
        
        isUserInteractionEnabled = false
        animator.swipe(self, topCard: card, direction: direction, forced: forced)
    }
    
    func updateSwipeState(direction: SwipeDirection) {
        visibleCards.remove(at: 0)
        let remainingIndices = Array(currentState.remainingIndices.dropFirst())
        let swipe = Swipe(index: topCardIndex, direction: direction)
        let newCurrentState = CardStackState(remainingIndices: remainingIndices,
                                             previousSwipe: swipe,
                                             previousState: currentState)
        currentState = newCurrentState
    }
    
    func card(didReverseSwipe card: SwipeCard, from direction: SwipeDirection) {
        isUserInteractionEnabled = false
        animator.undo(self, topCard: card)
    }
}
