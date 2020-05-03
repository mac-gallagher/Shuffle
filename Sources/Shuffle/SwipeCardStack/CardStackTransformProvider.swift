import UIKit

protocol CardStackTransformProvidable {
  func backgroundCardDragTransform(for cardStack: SwipeCardStack,
                                   topCard: SwipeCard,
                                   topCardIndex: Int) -> CGAffineTransform
  func backgroundCardTransformPercentage(for cardStack: SwipeCardStack, topCard: SwipeCard) -> CGFloat
}

class CardStackTransformProvider: CardStackTransformProvidable {

  static let shared = CardStackTransformProvider()

  func backgroundCardDragTransform(for cardStack: SwipeCardStack,
                                   topCard: SwipeCard,
                                   topCardIndex: Int) -> CGAffineTransform {
    let percentage = backgroundCardTransformPercentage(for: cardStack, topCard: topCard)

    let currentScale = cardStack.scaleFactor(forCardAtIndex: topCardIndex)
    let nextScale = cardStack.scaleFactor(forCardAtIndex: topCardIndex - 1)

    let scaleX = (1 - percentage) * currentScale.x + percentage * nextScale.x
    let scaleY = (1 - percentage) * currentScale.y + percentage * nextScale.y

    return CGAffineTransform(scaleX: scaleX, y: scaleY)
  }

  func backgroundCardTransformPercentage(for cardStack: SwipeCardStack, topCard: SwipeCard) -> CGFloat {
    let panTranslation = topCard.panGestureRecognizer.translation(in: cardStack)
    let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
    return max(min(2 * abs(panTranslation.x) / minimumSideLength, 1),
               min(2 * abs(panTranslation.y) / minimumSideLength, 1))
  }
}
