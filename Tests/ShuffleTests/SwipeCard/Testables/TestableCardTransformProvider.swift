@testable import Shuffle
import UIKit

class TestableCardTransformProvider: CardTransformProvider {
  
  var testRotationDirectionY: CGFloat?
  override func rotationDirectionY(for card: SwipeCard) -> CGFloat {
    return testRotationDirectionY ?? super.rotationDirectionY(for: card)
  }
  
  var testRotationAngle: CGFloat?
  override func rotationAngle(for card: SwipeCard) -> CGFloat {
    return testRotationAngle ?? super.rotationAngle(for: card)
  }
}
