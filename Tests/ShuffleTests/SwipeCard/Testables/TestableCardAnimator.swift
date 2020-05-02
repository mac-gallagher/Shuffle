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
    return testSwipeRotationAngle  ?? super.swipeRotationAngle(card, direction: direction, forced: forced)
  }
  
  var testSwipeTranslation: CGVector?
  override func swipeTranslation(_ card: SwipeCard, direction: SwipeDirection, directionVector: CGVector) -> CGVector {
    return testSwipeTranslation ?? super.swipeTranslation(card, direction: direction, directionVector: directionVector)
  }
}
