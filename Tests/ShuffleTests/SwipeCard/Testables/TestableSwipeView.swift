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

class TestableSwipeView: SwipeView {

  // MARK: - Swipe Functions

  var minSwipeSpeed: CGFloat?
  override func minimumSwipeSpeed(on direction: SwipeDirection) -> CGFloat {
    return minSwipeSpeed ?? super.minimumSwipeSpeed(on: direction)
  }

  var minSwipeDistance: CGFloat?
  override func minimumSwipeDistance(on direction: SwipeDirection) -> CGFloat {
    return minSwipeDistance ?? super.minimumSwipeDistance(on: direction)
  }

  // MARK: - Tap/Pan Gesture Functions

  var didTapCalled: Bool = false
  override func didTap(_ recognizer: UITapGestureRecognizer) {
    super.didTap(recognizer)
    didTapCalled = true
  }

  var beginSwipingCalled: Bool = false
  override func beginSwiping(_ recognizer: UIPanGestureRecognizer) {
    super.beginSwiping(recognizer)
    beginSwipingCalled = true
  }

  var continueSwipingCalled: Bool = false
  override func continueSwiping(_ recognizer: UIPanGestureRecognizer) {
    super.continueSwiping(recognizer)
    continueSwipingCalled = true
  }

  var endSwipingCalled: Bool = false
  override func endSwiping(_ recognizer: UIPanGestureRecognizer) {
    super.endSwiping(recognizer)
    endSwipingCalled = true
  }

  var didSwipeCalled: Bool = false
  var didSwipeDirection: SwipeDirection?

  override func didSwipe(_ recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {
    super.didSwipe(recognizer, with: direction)
    didSwipeCalled = true
    didSwipeDirection = direction
  }

  var didCancelSwipeCalled: Bool = false
  override func didCancelSwipe(_ recognizer: UIPanGestureRecognizer) {
    super.didCancelSwipe(recognizer)
    didCancelSwipeCalled = true
  }
}
