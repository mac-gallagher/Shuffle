@testable import Shuffle
import UIKit

class TestableSwipeCardStack: SwipeCardStack {

  var testTopCardIndex: Int?
  override var topCardIndex: Int? {
    return testTopCardIndex ?? super.topCardIndex
  }

  var testTopCard: SwipeCard?
  override var topCard: SwipeCard? {
    return testTopCard ?? super.topCard
  }

  var testBackgroundCards: [SwipeCard]?
  override var backgroundCards: [SwipeCard] {
    return testBackgroundCards ?? super.backgroundCards
  }

  var testIsEnabled: Bool?
  override var isEnabled: Bool {
    return testIsEnabled ?? super.isEnabled
  }

  // MARK: - Completion Blocks

  var swipeCompletionCalled: Bool = false
  override var swipeCompletion: () -> Void {
    swipeCompletionCalled = true
    return super.swipeCompletion
  }

  var undoCompletionCalled: Bool = false
  override var undoCompletion: () -> Void {
    undoCompletionCalled = true
    return super.undoCompletion
  }

  var shiftCompletionCalled: Bool = false
  override var shiftCompletion: () -> Void {
    shiftCompletionCalled = true
    return super.shiftCompletion
  }

  // MARK: - Lifecycle

  var setNeedsLayoutCalled: Bool = false
  override func setNeedsLayout() {
    setNeedsLayoutCalled = true
    super.setNeedsLayout()
  }

  var layoutCardCalled: Bool = false
  var layoutCardCards: [SwipeCard] = []
  var layoutCardIndices: [Int] = []

  override func layoutCard(_ card: SwipeCard, at index: Int) {
    super.layoutCard(card, at: index)
    layoutCardCalled = true
    layoutCardCards.append(card)
    layoutCardIndices.append(index)
  }

  var testLoadCard: SwipeCard?
  var loadCardCalled: Bool = false
  var loadCardCalledIndex: Int?

  override func loadCard(at index: Int) -> SwipeCard? {
    loadCardCalled = true
    loadCardCalledIndex = index
    return testLoadCard ?? super.loadCard(at: index)
  }

  var insertCardCalled: Bool = false
  var insertCardCard: SwipeCard?
  var insertCardIndex: Int?

  override func insertCard(_ card: SwipeCard, at index: Int) {
    super.insertCard(card, at: index)
    insertCardCalled = true
    insertCardCard = card
    insertCardIndex = index
  }

  var reloadDataCalled: Bool = false
  override func reloadData() {
    reloadDataCalled = true
    super.reloadData()
  }

  var testScaleFactor: CGPoint?
  override func scaleFactor(forCardAtIndex index: Int) -> CGPoint {
    return testScaleFactor ?? super.scaleFactor(forCardAtIndex: index)
  }

  var testTransformForCard: CGAffineTransform?
  override func transform(forCardAtIndex index: Int) -> CGAffineTransform {
    return testTransformForCard ?? super.transform(forCardAtIndex: index)
  }

  var reloadVisibleCardsCalled: Bool = false
  override func reloadVisibleCards() {
    super.reloadVisibleCards()
    reloadVisibleCardsCalled = true
  }

  // MARK: - Test Helpers

  func resetReloadData() {
    reloadDataCalled = false
    reloadVisibleCardsCalled = false

    layoutCardCalled = false
    layoutCardCards = []
    layoutCardIndices = []
  }
}
