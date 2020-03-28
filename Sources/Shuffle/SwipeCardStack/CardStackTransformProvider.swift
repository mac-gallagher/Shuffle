import UIKit

protocol CardStackTransformProvidable {
    static var backgroundCardDragTransform: (SwipeCardStack, SwipeCard, Int) -> CGAffineTransform { get }
    static var backgroundCardTransformPercentage: (SwipeCardStack, SwipeCard) -> CGFloat { get }
}

class CardStackTransformProvider: CardStackTransformProvidable {
    
    static var backgroundCardDragTransform: (SwipeCardStack, SwipeCard, Int) -> CGAffineTransform {
        return { cardStack, topCard, topCardIndex in
            let percentage = backgroundCardTransformPercentage(cardStack, topCard)
            
            let currentScale = cardStack.scaleFactor(forCardAtIndex: topCardIndex)
            let nextScale = cardStack.scaleFactor(forCardAtIndex: topCardIndex - 1)
            
            let scaleX = (1 - percentage) * currentScale.x + percentage * nextScale.x
            let scaleY = (1 - percentage) * currentScale.y + percentage * nextScale.y
            
            return CGAffineTransform(scaleX: scaleX, y: scaleY)
        }
    }
    
    static var backgroundCardTransformPercentage: (SwipeCardStack, SwipeCard) -> CGFloat {
        return { cardStack, topCard in
            let panTranslation = topCard.panGestureRecognizer.translation(in: cardStack)
            let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
            return max(min(2 * abs(panTranslation.x) / minimumSideLength, 1),
                       min(2 * abs(panTranslation.y) / minimumSideLength, 1))
        }
    }
}
