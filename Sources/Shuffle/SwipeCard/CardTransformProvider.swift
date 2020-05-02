import UIKit

protocol CardTransformProvidable {
  func overlayPercentage(for card: SwipeCard, direction: SwipeDirection) -> CGFloat
  func rotationAngle(for card: SwipeCard) -> CGFloat
  func rotationDirectionY(for card: SwipeCard) -> CGFloat
  func transform(for card: SwipeCard) -> CGAffineTransform
}

class CardTransformProvider: CardTransformProvidable {

  static var shared = CardTransformProvider()
  
  func overlayPercentage(for card: SwipeCard, direction: SwipeDirection) -> CGFloat {
    if direction != card.activeDirection() { return 0 }
    let totalPercentage = card.swipeDirections.reduce(0) { (sum, direction) in
      return sum + card.dragPercentage(on: direction)
    }
    let actualPercentage = 2 * card.dragPercentage(on: direction) - totalPercentage
    return max(0, min(actualPercentage, 1))
  }

  func rotationAngle(for card: SwipeCard) -> CGFloat {
    let superviewTranslation = card.panGestureRecognizer.translation(in: card.superview)
    let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
    return rotationDirectionY(for: card)
      * rotationStrength
      * abs(card.animationOptions.maximumRotationAngle)
  }

  func rotationDirectionY(for card: SwipeCard) -> CGFloat {
    if let touchPoint = card.touchLocation {
      return (touchPoint.y < card.bounds.height / 2) ? 1 : -1
    }
    return 0
  }

  func transform(for card: SwipeCard) -> CGAffineTransform {
    let dragTranslation = card.panGestureRecognizer.translation(in: card)
    let translation = CGAffineTransform(translationX: dragTranslation.x,
                                        y: dragTranslation.y)
    let rotation = CGAffineTransform(rotationAngle: rotationAngle(for: card))
    return translation.concatenating(rotation)
  }
}
