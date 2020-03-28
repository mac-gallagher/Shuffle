import UIKit

protocol CardLayoutProvidable {
    static var overlayContainerFrame: (SwipeCard) -> CGRect { get }
    static var contentFrame: (SwipeCard) -> CGRect { get }
    static var footerFrame: (SwipeCard) -> CGRect { get }
}

class CardLayoutProvider: CardLayoutProvidable {
    
    static var overlayContainerFrame: (SwipeCard) -> CGRect {
        return { card in
            if let _ = card.footer {
                return CGRect(x: 0, y: 0,
                              width: card.bounds.width,
                              height: card.bounds.height - card.footerHeight)
            }
            return card.bounds
        }
    }
    
    static var contentFrame: (SwipeCard) -> CGRect {
        return { card in
            if let footer = card.footer, footer.isOpaque {
                return CGRect(x: 0, y: 0,
                              width: card.bounds.width,
                              height: card.bounds.height - card.footerHeight)
            }
            return card.bounds
        }
    }
    
    static var footerFrame: (SwipeCard) -> CGRect {
        return { card in
            return CGRect(x: 0, y: card.bounds.height - card.footerHeight,
                          width: card.bounds.width,
                          height: card.footerHeight)
        }
    }
}
