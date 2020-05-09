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

class MockCardStackAnimator: CardStackAnimatable {

  var animateResetCalled: Bool = false
  func animateReset(_ cardStack: SwipeCardStack, topCard: SwipeCard) {
    animateResetCalled = true
  }

  var animateShiftCalled: Bool = false
  var animateShiftDistance: Int?

  func animateShift(_ cardStack: SwipeCardStack, withDistance distance: Int) {
    animateShiftCalled = true
    animateShiftDistance = distance
  }

  var animateSwipeCalled: Bool = false
  var animateSwipeForced: Bool?
  var animateSwipeDirection: SwipeDirection?
  var animateSwipeTopCard: SwipeCard?

  func animateSwipe(_ cardStack: SwipeCardStack,
                    topCard: SwipeCard,
                    direction: SwipeDirection,
                    forced: Bool) {
    animateSwipeCalled = true
    animateSwipeForced = forced
    animateSwipeDirection = direction
    animateSwipeTopCard = topCard
  }

  var animateUndoCalled: Bool = false
  func animateUndo(_ cardStack: SwipeCardStack, topCard: SwipeCard) {
    animateUndoCalled = true
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
