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

class MockCardStackAnimator: CardStackAnimatable {

  var animateResetCalled: Bool = false
  func animateReset(_ cardStack: SwipeCardStack,
                    topCard: SwipeCard) {
    animateResetCalled = true
  }

  var animateShiftCalled: Bool = false
  var animateShiftDistance: Int?
  var animateShiftAnimated: Bool?

  func animateShift(_ cardStack: SwipeCardStack,
                    withDistance distance: Int,
                    animated: Bool,
                    completion: ((Bool) -> Void)?) {
    animateShiftCalled = true
    animateShiftDistance = distance
    animateShiftAnimated = animated
    completion?(true)
  }

  var animateSwipeCalled: Bool = false
  var animateSwipeTopCard: SwipeCard?
  var animateSwipeDirection: SwipeDirection?
  var animateSwipeForced: Bool?
  var animateSwipeAnimated: Bool?

  func animateSwipe(_ cardStack: SwipeCardStack,
                    topCard: SwipeCard,
                    direction: SwipeDirection,
                    forced: Bool,
                    animated: Bool,
                    completion: ((Bool) -> Void)?) {
    animateSwipeCalled = true
    animateSwipeTopCard = topCard
    animateSwipeDirection = direction
    animateSwipeForced = forced
    animateSwipeAnimated = animated
    completion?(true)
  }

  var animateUndoCalled: Bool = false
  var animateUndoTopCard: SwipeCard?
  var animateUndoAnimated: Bool?

  func animateUndo(_ cardStack: SwipeCardStack,
                   topCard: SwipeCard,
                   animated: Bool,
                   completion: ((Bool) -> Void)?) {
    animateUndoTopCard = topCard
    animateUndoAnimated = animated
    animateUndoCalled = true
    completion?(true)
  }

  var removeBackgroundCardAnimationsCalled: Bool = false
  func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack) {
    removeBackgroundCardAnimationsCalled = true
  }

  var removeAllCardAnimationsCalled: Bool = false
  func removeAllCardAnimations(_ cardStack: SwipeCardStack) {
    removeAllCardAnimationsCalled = true
  }
}
