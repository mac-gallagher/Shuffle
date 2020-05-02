@testable import Shuffle
import UIKit

class TestableSwipeCard: SwipeCard {

  var testTouchLocation: CGPoint?
  override var touchLocation: CGPoint? {
    return testTouchLocation ?? super.touchLocation
  }

  //MARK: - Completion Blocks

  var swipeCompletionBlockCalled: Bool = false
  override var swipeCompletionBlock: () -> Void {
    swipeCompletionBlockCalled = true
    return super.swipeCompletionBlock
  }

  var reverseSwipeCompletionBlockCalled: Bool = false
  override var reverseSwipeCompletionBlock: () -> Void {
    reverseSwipeCompletionBlockCalled = true
    return super.reverseSwipeCompletionBlock
  }

  // MARK: - Swipe Calculations

  var testActiveDirection: SwipeDirection?
  override func activeDirection() -> SwipeDirection? {
    return testActiveDirection ?? super.activeDirection()
  }

  var testDragSpeed: CGFloat?
  override func dragSpeed(on direction: SwipeDirection) -> CGFloat {
    return testDragSpeed ?? super.dragSpeed(on: direction)
  }

  var testDragPercentage = [SwipeDirection: CGFloat]()
  override func dragPercentage(on direction: SwipeDirection) -> CGFloat {
    return testDragPercentage[direction] ?? super.dragPercentage(on: direction)
  }

  var testMinimumSwipeDistance = [SwipeDirection: CGFloat]()
  override func minimumSwipeDistance(on direction: SwipeDirection) -> CGFloat {
    return testMinimumSwipeDistance[direction]
      ?? super.minimumSwipeDistance(on: direction)
  }

  var testMinimumSwipeSpeed: CGFloat?
  override func minimumSwipeSpeed(on direction: SwipeDirection) -> CGFloat {
    return testMinimumSwipeSpeed ?? super.minimumSwipeSpeed(on: direction)
  }

  // MARK: - Main Methods

  var setOverlayCalled: Bool = false
  var setOverlayOverlays = [SwipeDirection: UIView]()

  override func setOverlay(_ overlay: UIView?, forDirection direction: SwipeDirection) {
    super.setOverlay(overlay, forDirection: direction)
    setOverlayOverlays[direction] = overlay
    setOverlayCalled = true
  }

  var swipeActionDirection: SwipeDirection?
  var swipeActionForced: Bool?
  var swipeActionAnimated: Bool?

  override func swipeAction(direction: SwipeDirection, forced: Bool, animated: Bool) {
    super.swipeAction(direction: direction, forced: forced, animated: animated)
    swipeActionDirection = direction
    swipeActionForced = forced
    swipeActionAnimated = animated
  }

  var swipeCalled: Bool = false
  var swipeDirection: SwipeDirection?
  var swipeAnimated: Bool?

  override func swipe(direction: SwipeDirection, animated: Bool) {
    super.swipe(direction: direction, animated: animated)
    swipeCalled = true
    swipeDirection = direction
    swipeAnimated = animated
  }

  var reverseSwipeCalled: Bool = false
  var reverseSwipeDirection: SwipeDirection?
  var reverseSwipeAnimated: Bool?

  override func reverseSwipe(from direction: SwipeDirection, animated: Bool) {
    super.reverseSwipe(from: direction, animated: animated)
    reverseSwipeCalled = true
    reverseSwipeDirection = direction
    reverseSwipeAnimated = animated
  }

  // MARK: - Lifecycle

  var setNeedsLayoutCalled: Bool = false
  override func setNeedsLayout() {
    super.setNeedsLayout()
    setNeedsLayoutCalled = true
  }
}
