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

class TestableCardAnimator: CardAnimator {

  var addReverseSwipeAnimationKeyFramesCalled: Bool = false
  override func addReverseSwipeAnimationKeyFrames(_ card: SwipeCard, direction: SwipeDirection) {
    addReverseSwipeAnimationKeyFramesCalled = true
    return super.addReverseSwipeAnimationKeyFrames(card, direction: direction)
  }

  var addSwipeAnimationKeyFramesCalled: Bool = false
  override func addSwipeAnimationKeyFrames(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) {
    addSwipeAnimationKeyFramesCalled = true
    return super.addSwipeAnimationKeyFrames(card, direction: direction, forced: forced)
  }

  var removeAllAnimationsCalled: Bool = false
  override func removeAllAnimations(on card: SwipeCard) {
    removeAllAnimationsCalled = true
    super.removeAllAnimations(on: card)
  }

  var testSwipeRotationAngle: CGFloat?
  override func swipeRotationAngle(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> CGFloat {
    return testSwipeRotationAngle ?? super.swipeRotationAngle(card, direction: direction, forced: forced)
  }

  var testSwipeTranslation: CGVector?
  override func swipeTranslation(_ card: SwipeCard, direction: SwipeDirection, directionVector: CGVector) -> CGVector {
    return testSwipeTranslation ?? super.swipeTranslation(card, direction: direction, directionVector: directionVector)
  }
}
