import Quick
import Nimble

import Shuffle

class CardAnimationOptionsSpec: QuickSpec {
    
    override func spec() {
        describe("CardAnimationOptions") {
            var subject: CardAnimationOptions!
            
            // MARK: - Initialization
            
            describe("Initialization") {
                context("When initializing a CardAnimationOptions object") {
                    beforeEach {
                        subject = CardAnimationOptions()
                    }
                    
                    it("should have the correct default properties") {
                        expect(subject.maximumRotationAngle).to(equal(CGFloat.pi / 10))
                        expect(subject.totalSwipeDuration).to(equal(0.7))
                        expect(subject.relativeSwipeOverlayFadeDuration).to(equal(0.15))
                        expect(subject.relativeReverseSwipeOverlayFadeDuration).to(equal(0.15))
                        expect(subject.totalReverseSwipeDuration).to(equal(0.25))
                        expect(subject.resetSpringDamping).to(equal(0.5))
                        expect(subject.totalResetDuration).to(equal(0.6))
                    }
                }
            }
            
            // MARK: - Maximum Rotation Angle
            
            describe("Maximum Rotation Angle") {
                context("When setting maximumRotationAngle to a value less than -.pi/2") {
                    beforeEach {
                        subject = CardAnimationOptions(maximumRotationAngle: -.pi)
                    }
                    
                    it("should return -.pi/2") {
                        expect(subject.maximumRotationAngle).to(equal(-.pi / 2))
                    }
                }
                
                context("When setting maximumRotationAngle to a value greater than .pi/2") {
                    beforeEach {
                        subject = CardAnimationOptions(maximumRotationAngle: .pi)
                    }
                    
                    it("should return CGFloat.pi/2") {
                        expect(subject.maximumRotationAngle).to(equal(.pi / 2))
                    }
                }
            }
            
            // MARK: - Total Swipe Duration
            
            describe("Total Swipe Duration") {
                context("When setting totalSwipeDuration to a value less than or equal to zero") {
                    beforeEach {
                        subject = CardAnimationOptions(totalSwipeDuration: 0)
                    }
                    
                    it("should return zero") {
                        expect(subject.totalSwipeDuration).to(equal(0))
                    }
                }
            }
            
            // MARK: - Total Reverse Swipe Duration
            
            describe("Total Reverse Swipe Duration") {
                context("When setting totalReverseSwipeDuration to a value less than or equal to zero") {
                    beforeEach {
                        subject = CardAnimationOptions(totalReverseSwipeDuration: 0)
                    }
                    
                    it("should return zero") {
                        expect(subject.totalReverseSwipeDuration).to(equal(0))
                    }
                }
            }
            
            // MARK: - Total Reset Duration
            
            describe("Total Reset Duration") {
                context("When setting totalResetDuration to a value less than or equal to zero") {
                    beforeEach {
                        subject = CardAnimationOptions(totalResetDuration: 0)
                    }
                    
                    it("should return zero") {
                        expect(subject.totalResetDuration).to(equal(0))
                    }
                }
            }
            
            // MARK: - Relative Swipe Overlay Fade Duration
            
            describe("Relative Swipe Overlay Fade Duration") {
                context("When setting relativeSwipeOverlayFadeDuration to a value less than zero") {
                    beforeEach {
                        subject = CardAnimationOptions(relativeSwipeOverlayFadeDuration: -0.5)
                    }
                    
                    it("should return zero") {
                        expect(subject.relativeSwipeOverlayFadeDuration).to(equal(0))
                    }
                }
                
                context("When setting relativeSwipeOverlayFadeDuration to a value greater than 1") {
                    beforeEach {
                        subject = CardAnimationOptions(relativeSwipeOverlayFadeDuration: 1.5)
                    }
                    
                    it("should return 1") {
                        expect(subject.relativeSwipeOverlayFadeDuration).to(equal(1))
                    }
                }
            }
            
            // MARK: - Relative Reverse Swipe Overlay Fade Duration
            
            describe("Relative Reverse Swipe Overlay Fade Duration") {
                context("When setting relativeReverseSwipeOverlayFadeDuration to a value less than zero") {
                    beforeEach {
                        subject = CardAnimationOptions(relativeReverseSwipeOverlayFadeDuration: -0.5)
                    }
                    
                    it("should return zero") {
                        expect(subject.relativeReverseSwipeOverlayFadeDuration).to(equal(0))
                    }
                }
                
                context("When setting relativeReverseSwipeOverlayFadeDuration to a value greater than 1") {
                    beforeEach {
                        subject = CardAnimationOptions(relativeReverseSwipeOverlayFadeDuration: 1.5)
                    }
                    
                    it("should return 1") {
                        expect(subject.relativeReverseSwipeOverlayFadeDuration).to(equal(1))
                    }
                }
            }
            
            // MARK: - Reset Spring Damping
            
            describe("Reset Spring Damping") {
                context("When setting resetSpringDamping to a value less than zero") {
                    beforeEach {
                        subject = CardAnimationOptions(resetSpringDamping: -0.5)
                    }
                    
                    it("should return zero") {
                        expect(subject.resetSpringDamping).to(equal(0))
                    }
                }
                
                context("When setting resetSpringDamping to a value greater than 1") {
                    beforeEach {
                        subject = CardAnimationOptions(resetSpringDamping: 1.5)
                    }
                    
                    it("should return 1") {
                        expect(subject.resetSpringDamping).to(equal(1))
                    }
                }
            }
        }
    }
}
