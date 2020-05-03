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
