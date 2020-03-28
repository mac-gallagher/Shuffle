import UIKit

protocol CardTransformProvidable {
    static var cardTransform: (SwipeCard) -> CGAffineTransform { get }
    static var cardRotationDirectionY: (SwipeCard) -> CGFloat { get }
    static var cardRotationAngle: (SwipeCard) -> CGFloat { get }
    static var cardOverlayPercentage: (SwipeCard, SwipeDirection) -> CGFloat { get }
}

class CardTransformProvider: CardTransformProvidable {
    
    class var cardTransform: (SwipeCard) -> CGAffineTransform {
        return { card in
            let dragTranslation = card.panGestureRecognizer.translation(in: card)
            let translation = CGAffineTransform(translationX: dragTranslation.x,
                                                y: dragTranslation.y)
            let rotation = CGAffineTransform(rotationAngle: cardRotationAngle(card))
            return translation.concatenating(rotation)
        }
    }
    
    class var cardRotationDirectionY: (SwipeCard) -> CGFloat {
        return { card in
            if let touchPoint = card.touchLocation {
                return (touchPoint.y < card.bounds.height / 2) ? 1 : -1
            }
            return 0
        }
    }
    
    class var cardRotationAngle: (SwipeCard) -> CGFloat {
        return { card in
            let superviewTranslation = card.panGestureRecognizer.translation(in: card.superview)
            let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
            return cardRotationDirectionY(card)
                * rotationStrength
                * abs(card.animationOptions.maximumRotationAngle)
        }
    }
    
    class var cardOverlayPercentage: (SwipeCard, SwipeDirection) -> CGFloat {
        return { card, direction in
            if direction != card.activeDirection { return 0 }
            let totalPercentage = card.swipeDirections.reduce(0) { (sum, direction) in
                return sum + card.dragPercentage(direction)
            }
            let actualPercentage = 2 * card.dragPercentage(direction) - totalPercentage
            return max(0, min(actualPercentage, 1))
        }
    }
}
