@testable import Shuffle
import UIKit

class MockCardStackTransformProvider: CardStackTransformProvidable {

  var testBackgroundCardDragTransform: CGAffineTransform = .identity
  var backgroundCardDragTransformCard: SwipeCard?
  var backgroundCardDragTransformIndex: Int?

  func backgroundCardDragTransform(for cardStack: SwipeCardStack, topCard: SwipeCard, topCardIndex: Int) -> CGAffineTransform {
    backgroundCardDragTransformCard = topCard
    backgroundCardDragTransformIndex = topCardIndex
    return testBackgroundCardDragTransform
  }

  var testBackgroundCardTransformPercentage: CGFloat = 0.0
  var backgroundCardTransformPercentageCard: SwipeCard?
  
  func backgroundCardTransformPercentage(for cardStack: SwipeCardStack, topCard: SwipeCard) -> CGFloat {
    backgroundCardTransformPercentageCard = topCard
    return testBackgroundCardTransformPercentage
  }
}
