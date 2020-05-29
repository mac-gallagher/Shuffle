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

import Foundation

typealias Swipe = (index: Int, direction: SwipeDirection)

protocol CardStackStateManagable {
  var remainingIndices: [Int] { get }
  var swipes: [Swipe] { get }

  func swipe(_ direction: SwipeDirection)
  func undoSwipe() -> Swipe?
  func shift(withDistance distance: Int)
  func reset(withNumberOfCards numberOfCards: Int)
}

/// An internal class to manage the current state of the card stack.
class CardStackStateManager: CardStackStateManagable {

  static let shared = CardStackStateManager()

  /// The indices of the data source which have yet to be swiped.
  ///
  /// This array reflects the current order of the card stack, with the first element equal
  /// to the index of the top card in the data source. The order of this array accounts
  /// for both swiped and shifted cards in the stack.
  var remainingIndices: [Int] = []

  /// An array containing the swipe history of the card stack.
  var swipes: [Swipe] = []

  func swipe(_ direction: SwipeDirection) {
    if remainingIndices.isEmpty { return }
    let firstIndex = remainingIndices.removeFirst()
    let swipe = Swipe(direction: direction, index: firstIndex)
    swipes.append(swipe)
  }

  func undoSwipe() -> Swipe? {
    if swipes.isEmpty { return nil }
    let lastSwipe = swipes.removeLast()
    remainingIndices.insert(lastSwipe.index, at: 0)
    return lastSwipe
  }

  func shift(withDistance distance: Int) {
    remainingIndices.shift(withDistance: distance)
  }

  func reset(withNumberOfCards numberOfCards: Int) {
    self.remainingIndices = Array(0..<numberOfCards)
    self.swipes = []
  }
}
