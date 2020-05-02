import UIKit

protocol CardLayoutProvidable {
  func createContentFrame(for card: SwipeCard) -> CGRect
  func createFooterFrame(for card: SwipeCard) -> CGRect
  func createOverlayContainerFrame(for card: SwipeCard) -> CGRect
}

class CardLayoutProvider: CardLayoutProvidable {

  static var shared = CardLayoutProvider()

  func createContentFrame(for card: SwipeCard) -> CGRect {
    if let footer = card.footer, footer.isOpaque {
      return CGRect(x: 0, y: 0,
                    width: card.bounds.width,
                    height: card.bounds.height - card.footerHeight)
    }
    return card.bounds
  }

  func createFooterFrame(for card: SwipeCard) -> CGRect {
    return CGRect(x: 0, y: card.bounds.height - card.footerHeight,
                  width: card.bounds.width,
                  height: card.footerHeight)
  }

  func createOverlayContainerFrame(for card: SwipeCard) -> CGRect {
    if card.footer != nil {
      return CGRect(x: 0, y: 0,
                    width: card.bounds.width,
                    height: card.bounds.height - card.footerHeight)
    }
    return card.bounds
  }
}
