@testable import Shuffle

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

  var didReverseSwipeCalled: Bool = false
  var didReverseSwipeDirection: SwipeDirection?

  func card(didReverseSwipe card: SwipeCard, from direction: SwipeDirection) {
    didReverseSwipeCalled = true
    didReverseSwipeDirection = direction
  }

  var didSwipeCalled: Bool = false
  var didSwipeDirection: SwipeDirection?
  var didSwipeForced: Bool?

  func card(didSwipe card: SwipeCard, with direction: SwipeDirection, forced: Bool) {
    didSwipeCalled = true
    didSwipeDirection = direction
    didSwipeForced = forced
  }

  var didTapCalled: Bool = false
  func card(didTap card: SwipeCard) {
    didTapCalled = true
  }
}
