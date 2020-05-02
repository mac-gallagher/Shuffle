@testable import Shuffle

class MockCardAnimator: CardAnimatable {

  var animateResetCalled: Bool = false
  func animateReset(on card: SwipeCard) {
    animateResetCalled = true
  }

  var animateReverseSwipeCalled: Bool = false
  var animateReverseSwipeDirection: SwipeDirection?

  func animateReverseSwipe(on card: SwipeCard, from direction: SwipeDirection) {
    animateReverseSwipeCalled = true
    animateReverseSwipeDirection = direction
  }

  var animateSwipeCalled: Bool = false
  var animateSwipeDirection: SwipeDirection?
  var animateSwipeForced: Bool?

  func animateSwipe(on card: SwipeCard, direction: SwipeDirection, forced: Bool) {
    animateSwipeCalled = true
    animateSwipeDirection = direction
    animateSwipeForced = forced
  }

  var removeAllAnimationsCalled: Bool = false
  func removeAllAnimations(on card: SwipeCard) {
    removeAllAnimationsCalled = true
  }
}
