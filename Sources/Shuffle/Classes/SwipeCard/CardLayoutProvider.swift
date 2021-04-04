///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

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
      return CGRect(x: 0,
                    y: 0,
                    width: card.bounds.width,
                    height: card.bounds.height - card.footerHeight)
    }
    return card.bounds
  }

  func createFooterFrame(for card: SwipeCard) -> CGRect {
    return CGRect(x: 0,
                  y: card.bounds.height - card.footerHeight,
                  width: card.bounds.width,
                  height: card.footerHeight)
  }

  func createOverlayContainerFrame(for card: SwipeCard) -> CGRect {
    if card.footer != nil {
      return CGRect(x: 0,
                    y: 0,
                    width: card.bounds.width,
                    height: card.bounds.height - card.footerHeight)
    }
    return card.bounds
  }
}
