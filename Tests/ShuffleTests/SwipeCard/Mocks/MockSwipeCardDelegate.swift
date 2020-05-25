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

class MockSwipeCardDelegate: SwipeCardDelegate {

  var didBeginSwipeCalled: Bool = false
  func card(didBeginSwipe card: SwipeCard) {
    didBeginSwipeCalled = true
  }

  var didCancelSwipeCalled: Bool = false
  func card(didCancelSwipe card: SwipeCard) {
    didCancelSwipeCalled = true
  }

  var didContinueSwipeCalled: Bool = false
  func card(didContinueSwipe card: SwipeCard) {
    didContinueSwipeCalled = true
  }

  var didSwipeCalled: Bool = false
  var didSwipeDirection: SwipeDirection?

  func card(didSwipe card: SwipeCard, with direction: SwipeDirection) {
    didSwipeCalled = true
    didSwipeDirection = direction
  }

  var didTapCalled: Bool = false
  func card(didTap card: SwipeCard) {
    didTapCalled = true
  }

  var testShouldRecognizeHorizontalDrag: Bool?
  func shouldRecognizeHorizontalDrag(on card: SwipeCard) -> Bool? {
    return testShouldRecognizeHorizontalDrag
  }

  var testShouldRecognizeVerticalDrag: Bool?
  func shouldRecognizeVerticalDrag(on card: SwipeCard) -> Bool? {
    return testShouldRecognizeVerticalDrag
  }
}
