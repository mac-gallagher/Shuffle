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

class MockCardAnimator: CardAnimatable {

  var animateResetCalled: Bool = false
  func animateReset(on card: SwipeCard) {
    animateResetCalled = true
  }

  var animateReverseSwipeCalled: Bool = false
  var animateReverseSwipeDirection: SwipeDirection?

  func animateReverseSwipe(on card: SwipeCard, from direction: SwipeDirection, completion: ((Bool) -> Void)?) {
    animateReverseSwipeCalled = true
    animateReverseSwipeDirection = direction
    completion?(true)
  }

  var animateSwipeCalled: Bool = false
  var animateSwipeDirection: SwipeDirection?
  var animateSwipeForced: Bool?

  func animateSwipe(on card: SwipeCard, direction: SwipeDirection, forced: Bool, completion: ((Bool) -> Void)?) {
    animateSwipeCalled = true
    animateSwipeDirection = direction
    animateSwipeForced = forced
    completion?(true)
  }

  var removeAllAnimationsCalled: Bool = false
  func removeAllAnimations(on card: SwipeCard) {
    removeAllAnimationsCalled = true
  }
}
