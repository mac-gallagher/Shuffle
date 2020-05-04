import Nimble
import Quick
@testable import Shuffle
import UIKit

class CardLayoutProviderSpec: QuickSpec {

  override func spec() {
    describe("CardLayoutProvider") {
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

      describe("When acessing the createContentFrame method") {
        context("and the card has an opaque footer") {
          let footer = UIView()

          beforeEach {
            footer.isOpaque = true
            card.footer = footer
          }

          it("should return the correct frame") {
            let actualFrame = subject.createContentFrame(for: card)
            let expectedFrame = CGRect(x: 0, y: 0,
                                       width: cardWidth,
                                       height: cardHeight - footerHeight)
            expect(actualFrame).to(equal(expectedFrame))
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
            let expectedFrame = CGRect(x: 0, y: 0,
                                       width: cardWidth,
                                       height: cardHeight)
            expect(actualFrame).to(equal(expectedFrame))
          }
        }

        context("and the card has no footer") {
          beforeEach {
            card.footer = nil
          }

          it("should return the correct frame") {
            let actualFrame = subject.createContentFrame(for: card)
            let expectedFrame = CGRect(x: 0, y: 0,
                                       width: cardWidth,
                                       height: cardHeight)
            expect(actualFrame).to(equal(expectedFrame))
          }
        }
      }

      // MARK: - Create Footer Frame

      describe("When calling the createFooterFrame variable") {
        it("should return the correct frame") {
          let actualFrame = subject.createFooterFrame(for: card)
          let expectedFrame = CGRect(x: 0, y: cardHeight - footerHeight,
                                     width: cardWidth,
                                     height: footerHeight)
          expect(actualFrame).to(equal(expectedFrame))
        }
      }

      // MARK: - Create Overlay Container Frame

      describe("When calling the createOverlayContainerFrame method") {
        context("and the card has a footer") {
          beforeEach {
            card.footer = UIView()
          }

          it("should return the correct frame") {
            let actualFrame = subject.createOverlayContainerFrame(for: card)
            let expectedFrame = CGRect(x: 0, y: 0,
                                       width: cardWidth,
                                       height: cardHeight - footerHeight)
            expect(actualFrame).to(equal(expectedFrame))
          }
        }

        context("and the card has no footer") {
          beforeEach {
            card.footer = nil
          }

          it("should return the correct frame") {
            let actualFrame = subject.createOverlayContainerFrame(for: card)
            let expectedFrame = CGRect(x: 0, y: 0,
                                       width: cardWidth,
                                       height: cardHeight)
            expect(actualFrame).to(equal(expectedFrame))
          }
        }
      }
    }
  }
}
