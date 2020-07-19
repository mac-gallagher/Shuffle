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

class MockCardStackStateManager: CardStackStateManagable {

  var remainingIndices: [Int] = []
  var swipes: [Swipe] = []
  var totalIndexCount: Int = 0

  var insertCalled: Bool = false
  var insertIndices: [Int] = []
  var insertPositions: [Int] = []

  func insert(_ index: Int, at position: Int) {
    insertCalled = true
    insertIndices.append(index)
    insertPositions.append(position)
  }

  func delete(_ index: Int) {}

  var deleteIndicesCalled: Bool = false
  var deleteIndicesIndices: [Int] = []

  func delete(_ indices: [Int]) {
    deleteIndicesCalled = true
    deleteIndicesIndices = indices
  }

  func delete(indexAtPosition position: Int) {}

  var deleteIndicesAtPositionCalled: Bool = false
  var deleteIndicesAtPositionPositions: [Int] = []

  func delete(indicesAtPositions positions: [Int]) {
    deleteIndicesAtPositionCalled = true
    deleteIndicesAtPositionPositions = positions
  }

  var swipeCalled = false
  var swipeDirection: SwipeDirection?

  func swipe(_ direction: SwipeDirection) {
    swipeCalled = true
    swipeDirection = direction
  }

  var undoSwipeCalled = false
  var undoSwipeSwipe: Swipe?

  func undoSwipe() -> Swipe? {
    undoSwipeCalled = true
    return undoSwipeSwipe
  }

  var shiftCalled = false
  var shiftDistance: Int?

  func shift(withDistance distance: Int) {
    shiftCalled = true
    shiftDistance = distance
  }

  var resetCalled: Bool = false
  var resetNumberOfCards: Int?

  func reset(withNumberOfCards numberOfCards: Int) {
    resetCalled = true
    resetNumberOfCards = numberOfCards
  }
}
