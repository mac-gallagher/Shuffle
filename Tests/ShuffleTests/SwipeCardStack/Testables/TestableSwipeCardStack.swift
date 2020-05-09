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
  override var swipeCompletionBlock: () -> Void {
    swipeCompletionCalled = true
    return super.swipeCompletionBlock
  }

  var undoCompletionCalled: Bool = false
  override var undoCompletionBlock: () -> Void {
    undoCompletionCalled = true
    return super.undoCompletionBlock
  }

  var shiftCompletionCalled: Bool = false
  override var shiftCompletionBlock: () -> Void {
    shiftCompletionCalled = true
    return super.shiftCompletionBlock
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
