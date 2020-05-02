import Foundation

protocol SwipeCardDelegate: class {
  func card(didBeginSwipe card: SwipeCard)
  func card(didCancelSwipe card: SwipeCard)
  func card(didContinueSwipe card: SwipeCard)
  func card(didReverseSwipe card: SwipeCard, from direction: SwipeDirection)
  func card(didSwipe card: SwipeCard, with direction: SwipeDirection, forced: Bool)
  func card(didTap card: SwipeCard)
}
