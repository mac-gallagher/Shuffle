@testable import Shuffle
import UIKit

class MockCardStackLayoutProvider: CardStackLayoutProvidable {
  
  var testCardContainerFrame: CGRect = .zero
  func createCardContainerFrame(for cardStack: SwipeCardStack) -> CGRect {
    return testCardContainerFrame
  }
  
  var testCardFrame: CGRect = .zero
  func createCardFrame(for cardStack: SwipeCardStack) -> CGRect {
    return testCardFrame
  }
}
