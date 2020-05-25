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

import Nimble
import Quick
@testable import Shuffle
import UIKit

// swiftlint:disable closure_body_length function_body_length implicitly_unwrapped_optional
class CardLayoutProviderSpec: QuickSpec {

  override func spec() {
    let cardWidth: CGFloat = 100
    let cardHeight: CGFloat = 200
    let footerHeight: CGFloat = 50

    var card: SwipeCard!
    var subject: CardLayoutProvider!

    beforeEach {
      subject = CardLayoutProvider()
      card = SwipeCard(animator: MockCardAnimator(),
                       layoutProvider: MockCardLayoutProvider(),
                       notificationCenter: NotificationCenter.default,
                       transformProvider: MockCardTransformProvider())
      card.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
      card.footerHeight = footerHeight
    }

    // MARK: - Create Content Frame

    describe("When calling createContentFrame") {
      context("and the card has an opaque footer") {
        let footer = UIView()

        beforeEach {
          footer.isOpaque = true
          card.footer = footer
        }

        it("should return the correct frame") {
          let actualFrame = subject.createContentFrame(for: card)
          let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
          expect(actualFrame) == expectedFrame
        }
      }

      context("and the card has a transparent footer") {
        let footer = UIView()

        beforeEach {
          footer.isOpaque = false
          card.footer = footer
        }

        it("should return the correct frame") {
          let actualFrame = subject.createContentFrame(for: card)
          let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
          expect(actualFrame) == expectedFrame
        }
      }

      context("and the card has no footer") {
        beforeEach {
          card.footer = nil
        }

        it("should return the correct frame") {
          let actualFrame = subject.createContentFrame(for: card)
          let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
          expect(actualFrame) == expectedFrame
        }
      }
    }

    // MARK: - Create Footer Frame

    describe("When calling createFooterFrame") {
      it("should return the correct frame") {
        let actualFrame = subject.createFooterFrame(for: card)
        let expectedFrame = CGRect(x: 0, y: cardHeight - footerHeight, width: cardWidth, height: footerHeight)
        expect(actualFrame) == expectedFrame
      }
    }

    // MARK: - Create Overlay Container Frame

    describe("When calling createOverlayContainerFrame") {
      context("and the card has a footer") {
        beforeEach {
          card.footer = UIView()
        }

        it("should return the correct frame") {
          let actualFrame = subject.createOverlayContainerFrame(for: card)
          let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
          expect(actualFrame) == expectedFrame
        }
      }

      context("and the card has no footer") {
        beforeEach {
          card.footer = nil
        }

        it("should return the correct frame") {
          let actualFrame = subject.createOverlayContainerFrame(for: card)
          let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
          expect(actualFrame) == expectedFrame
        }
      }
    }
  }
}
// swiftlint:enabled closure_body_length function_body_length implicitly_unwrapped_optional
