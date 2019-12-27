import Foundation

protocol SwipeCardDelegate: class {
    func card(didTap card: SwipeCard)
    func card(didBeginSwipe card: SwipeCard)
    func card(didContinueSwipe card: SwipeCard)
    func card(didCancelSwipe card: SwipeCard)
    func card(didSwipe card: SwipeCard, with direction: SwipeDirection, forced: Bool)
    func card(didReverseSwipe card: SwipeCard, from direction: SwipeDirection)
}
