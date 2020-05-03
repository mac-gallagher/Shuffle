@testable import Shuffle
import UIKit

class MockCardTransformProvider: CardTransformProvidable {

  var testOverlayPercentage = [SwipeDirection: CGFloat]()
  func overlayPercentage(for card: SwipeCard, direction: SwipeDirection) -> CGFloat {
    return testOverlayPercentage[direction] ?? 0
  }

  var testRotationAngle: CGFloat = 0
  func rotationAngle(for card: SwipeCard) -> CGFloat {
    return testRotationAngle
  }

  var testRotationDirectionY: CGFloat = 0
  func rotationDirectionY(for card: SwipeCard) -> CGFloat {
    return testRotationDirectionY
  }

  var testTranform: CGAffineTransform = .identity
  func transform(for card: SwipeCard) -> CGAffineTransform {
    return testTranform
  }
}
