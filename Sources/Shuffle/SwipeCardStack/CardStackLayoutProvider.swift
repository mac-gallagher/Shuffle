import UIKit

protocol CardStackLayoutProvidable {
    static var cardContainerFrame: (SwipeCardStack) -> CGRect { get }
    static var cardFrame: (SwipeCardStack) -> CGRect { get }
}

struct CardStackLayoutProvider: CardStackLayoutProvidable {
    
    static var cardContainerFrame: (SwipeCardStack) -> CGRect {
        return { cardStack in
            let insets = cardStack.cardStackInsets
            let width = cardStack.bounds.width - (insets.left + insets.right)
            let height = cardStack.bounds.height - (insets.top + insets.bottom)
            return CGRect(x: insets.left, y: insets.top, width: width, height: height)
        }
    }
    
    static var cardFrame: (SwipeCardStack) -> CGRect {
        return { cardStack in
            let containerSize = cardContainerFrame(cardStack).size
            return CGRect(origin: .zero, size: containerSize)
        }
    }
}
