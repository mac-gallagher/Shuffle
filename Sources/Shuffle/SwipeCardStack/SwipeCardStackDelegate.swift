import Foundation

@objc public protocol SwipeCardStackDelegate: class {
    @objc optional func didSwipeAllCards(_ cardStack: SwipeCardStack)
    @objc optional func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection)
    @objc optional func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection)
    @objc optional func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int)
}
