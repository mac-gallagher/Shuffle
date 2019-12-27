import Quick
import Nimble

@testable import Shuffle

class CardStackAnimationOptionsSpec: QuickSpec {
    
    override func spec() {
        describe("CardStackAnimationOptions") {
            var subject: CardStackAnimationOptions!
            
            // MARK: - Initialization
            
            describe("Initialization") {
                context("When initializing a CardStackAnimationOptions object") {
                    beforeEach {
                        subject = CardStackAnimationOptions()
                    }
                    
                    it("should have the correct default properties") {
                        expect(subject.shiftDuration).to(equal(0.1))
                        expect(subject.swipeDuration).to(beNil())
                        expect(subject.undoDuration).to(beNil())
                        expect(subject.resetDuration).to(beNil())
                    }
                }
            }
            
            // MARK: - Shift Duration
            
            describe("Shift Duration") {
                context("When setting maximumRotationAngle to a value less than zero") {
                    beforeEach {
                        subject = CardStackAnimationOptions(shiftDuration: -0.5)
                    }
                    
                    it("should return zero") {
                        expect(subject.shiftDuration).to(equal(0))
                    }
                }
            }
            
            // MARK: - Swipe Duration
            
            describe("Swipe Duration") {
                context("When setting swipeDuration to a value less than zero") {
                    beforeEach {
                        subject = CardStackAnimationOptions(swipeDuration: -0.5)
                    }
                    
                    it("should return zero") {
                        expect(subject.swipeDuration).to(equal(0))
                    }
                }
            }
            
            // MARK: - Undo Duration
            
            describe("Undo Duration") {
                context("When setting undoDuration to a value less than zero") {
                    beforeEach {
                        subject = CardStackAnimationOptions(undoDuration: -0.5)
                    }
                    
                    it("should return zero") {
                        expect(subject.undoDuration).to(equal(0))
                    }
                }
            }
            
            // MARK: - Reset Duration
            
            describe("Reset Duration") {
                context("When setting resetDuration to a value less than zero") {
                    beforeEach {
                        subject = CardStackAnimationOptions(resetDuration: -0.5)
                    }
                    
                    it("should return zero") {
                        expect(subject.resetDuration).to(equal(0))
                    }
                }
            }
        }
    }
}
