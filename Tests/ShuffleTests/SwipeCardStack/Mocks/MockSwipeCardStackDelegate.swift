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

import Shuffle
import UIKit

class MockSwipeCardStackDelegate: SwipeCardStackDelegate {

  var didSelectCardAtCalled: Bool = false
  var didSelectCardAtIndex: Int?

  func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
    didSelectCardAtCalled = true
    didSelectCardAtIndex = index
  }

  var didSwipeCardAtCalled: Bool = false
  var didSwipeCardAtIndex: Int?
  var didSwipeCardAtDirection: SwipeDirection?

  func cardStack(_ cardStack: SwipeCardStack,
                 didSwipeCardAt index: Int,
                 with direction: SwipeDirection) {
    didSwipeCardAtCalled = true
    didSwipeCardAtIndex = index
    didSwipeCardAtDirection = direction
  }

  var didUndoCardAtCalled: Bool = false
  var didUndoCardAtIndex: Int?
  var didUndoCardAtDirection: SwipeDirection?

  func cardStack(_ cardStack: SwipeCardStack,
                 didUndoCardAt index: Int,
                 from direction: SwipeDirection) {
    didUndoCardAtCalled = true
    didUndoCardAtIndex = index
    didUndoCardAtDirection = direction
  }

  var didSwipeAllCardsCalled: Bool = false
  func didSwipeAllCards(_ cardStack: SwipeCardStack) {
    didSwipeAllCardsCalled = true
  }
}
