@testable import Shuffle
import UIKit

class MockCardLayoutProvider: CardLayoutProvidable {

  var testContentFrame: CGRect = .zero
  func createContentFrame(for card: SwipeCard) -> CGRect {
    return testContentFrame
  }

  var testFooterFrame: CGRect = .zero
  func createFooterFrame(for card: SwipeCard) -> CGRect {
    return testFooterFrame
  }

  var testOverlayContainerFrame: CGRect = .zero
  func createOverlayContainerFrame(for card: SwipeCard) -> CGRect {
    return testOverlayContainerFrame
  }
}
