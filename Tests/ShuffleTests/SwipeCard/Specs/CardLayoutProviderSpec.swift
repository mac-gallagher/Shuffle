import Quick
import Nimble

@testable import Shuffle

class CardLayoutProviderSpec: QuickSpec {
    
    override func spec() {
        describe("CardLayoutProvider") {
            let cardWidth: CGFloat = 100
            let cardHeight: CGFloat = 200
            let footerHeight: CGFloat = 50
            let subject = CardLayoutProvider.self
            
            var card: SwipeCard!
            
            beforeEach {
                card = SwipeCard(animator: MockCardAnimator.self,
                                 layoutProvider: MockCardLayoutProvider.self,
                                 transformProvider: MockCardTransformProvider.self,
                                 notificationCenter: TestableNotificationCenter())
                card.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
                card.footerHeight = footerHeight
            }
            
            // MARK: - Overlay Container Frame
            
            describe("When accessing the overlayContainerFrame variable") {
                context("and the card has a footer") {
                    beforeEach {
                        card.footer = UIView()
                    }
                    
                    it("should return the correct frame") {
                        let actualFrame = subject.overlayContainerFrame(card)
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
                        let actualFrame = subject.overlayContainerFrame(card)
                        let expectedFrame = CGRect(x: 0, y: 0,
                                                   width: cardWidth,
                                                   height: cardHeight)
                        expect(actualFrame).to(equal(expectedFrame))
                    }
                }
            }
            
            // MARK: - Content Frame
            
            describe("When acessing the contentFrame variable") {
                context("and the card has an opaque footer") {
                    let footer = UIView()
                    
                    beforeEach {
                        footer.isOpaque = true
                        card.footer = footer
                    }
                    
                    it("should return the correct frame") {
                        let actualFrame = subject.contentFrame(card)
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
                        let actualFrame = subject.contentFrame(card)
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
                        let actualFrame = subject.contentFrame(card)
                        let expectedFrame = CGRect(x: 0, y: 0,
                                                   width: cardWidth,
                                                   height: cardHeight)
                        expect(actualFrame).to(equal(expectedFrame))
                    }
                }
            }
            
            // MARK: - Footer Frame
            
            describe("When accessing the footerFrame variable") {
                it("should return the correct frame") {
                    let actualFrame = subject.footerFrame(card)
                    let expectedFrame = CGRect(x: 0, y: cardHeight - footerHeight,
                                               width: cardWidth,
                                               height: footerHeight)
                    expect(actualFrame).to(equal(expectedFrame))
                }
            }
        }
    }
}
