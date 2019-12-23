import Quick
import Nimble

@testable import Shuffle

class CardTransformProviderSpec: QuickSpec {
    
    override func spec() {
        describe("CardTransformProvider") {
            let subject = TestableCardTransformProvider.self
            let cardWidth: CGFloat = 100
            let cardHeight: CGFloat = 200
            let cardCenterX = cardWidth / 2
            let cardCenterY = cardHeight / 2
            
            var card: TestableSwipeCard!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            
            beforeEach {
                card = TestableSwipeCard(animator: MockCardAnimator.self,
                                         layoutProvider: MockCardLayoutProvider.self,
                                         transformProvider: MockCardTransformProvider.self,
                                         notificationCenter: TestableNotificationCenter())
                card.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
                
                testPanGestureRecognizer = card.panGestureRecognizer as? TestablePanGestureRecognizer
            }
            
            // MARK: - Rotation Direction
            
            describe("Rotation Direction") {
                context("When the touch point is nil") {
                    it("should have rotation direction equal to 0") {
                        expect(subject.cardRotationDirectionY(card)).to(equal(0))
                    }
                }
                
                context("When the touch point is in the first quadrant of the card's bounds") {
                    beforeEach {
                        let location = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
                        card.testTouchLocation = location
                    }
                    
                    it("should have rotation direction equal to 1") {
                        expect(subject.cardRotationDirectionY(card)).to(equal(1))
                    }
                }
                
                context("When the touch point is in the second quadrant of the card's bounds") {
                    beforeEach {
                        let location = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
                        card.testTouchLocation = location
                    }
                    
                    it("should have rotation direction equal to 1") {
                        expect(subject.cardRotationDirectionY(card)).to(equal(1))
                    }
                }
                
                context("When the touch point is in the third quadrant of the card's bounds") {
                    beforeEach {
                        let location = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
                        card.testTouchLocation = location
                    }
                    
                    it("should have rotation direction equal to -1") {
                        expect(subject.cardRotationDirectionY(card)).to(equal(-1))
                    }
                }
                
                context("When the touch point is in the fourth quadrant of the card's bounds") {
                    beforeEach {
                        let location = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
                        card.testTouchLocation = location
                    }
                    
                    it("should have rotation direction equal to -1") {
                        expect(subject.cardRotationDirectionY(card)).to(equal(-1))
                    }
                }
            }
            
            // MARK: - Overlay Percentage
            
            describe("Overlay Percentage") {
                for direction in SwipeDirection.allDirections {
                    context("When there is no active direction") {
                        beforeEach {
                            card.testActiveDirection = nil
                        }
                        
                        it("should return an overlay percentage of zero for each direction") {
                            expect(subject.cardOverlayPercentage(card, direction)).to(equal(0))
                        }
                    }
                    
                    context("When the drag percentage is nonzero in exactly one direction") {
                        let dragPercentage: CGFloat = 0.1
                        
                        beforeEach {
                            card.testDragPercentage[direction] = dragPercentage
                        }
                        
                        it("should return the drag percentage in the dragged direction and 0% for all other directions") {
                            for swipeDirection in SwipeDirection.allDirections {
                                let actualPercentage = subject.cardOverlayPercentage(card, swipeDirection)
                                let expectedPercentage = swipeDirection == direction ? dragPercentage : 0.0
                                expect(actualPercentage).to(equal(expectedPercentage))
                            }
                        }
                    }
                    
                    context("When the card is dragged in the indicated direction below its minimum swipe distance") {
                        let dragPercentage: CGFloat = 0.99
                        
                        beforeEach {
                            card.testDragPercentage[direction] = dragPercentage
                        }
                        
                        it("should have an overlay percentage less than 1 in the indicated direction") {
                            let expectedPercentage: CGFloat = subject.cardOverlayPercentage(card, direction)
                            expect(expectedPercentage).to(equal(dragPercentage))
                        }
                    }
                    
                    context("When the card is dragged in the indicated direction at least its minimum swipe distance") {
                        beforeEach {
                            card.testDragPercentage[direction] = 1.5
                        }
                        
                        it("should have an overlay percentage equal to 1 in the indicated direction") {
                            let expectedPercentage: CGFloat = subject.cardOverlayPercentage(card, direction)
                            expect(expectedPercentage).to(equal(1))
                        }
                    }
                }
                
                context("When the drag percentage is nonzero in more than one direction") {
                    let neighboringPairs: [(SwipeDirection, SwipeDirection)]
                        = [(.up, .right),
                           (.right, .down),
                           (.down, .left),
                           (.left, .up)]
                    
                    for (direction1, direction2) in neighboringPairs {
                        context("and the drag percentage in the two directions are equal") {
                            beforeEach {
                                card.testDragPercentage[direction1] = 0.1
                                card.testDragPercentage[direction2] = 0.1
                            }
                            
                            it("should return an overlay percentage of 0% for both directions") {
                                expect(subject.cardOverlayPercentage(card, direction1)).to(equal(0))
                                expect(subject.cardOverlayPercentage(card, direction2)).to(equal(0))
                            }
                        }
                        
                        context("and the drag percentage in the two directions are not equal") {
                            let largerPercentage: CGFloat = 0.4
                            let smallerPercentage: CGFloat = 0.1
                            
                            beforeEach {
                                card.testDragPercentage[direction1] = largerPercentage
                                card.testDragPercentage[direction2] = smallerPercentage
                            }
                            
                            it("should return the difference of percentages for the larger direction and zero for the other") {
                                let direction1Percentage = subject.cardOverlayPercentage(card, direction1)
                                let direction2Percentage = subject.cardOverlayPercentage(card, direction2)
                                
                                expect(direction1Percentage).to(beCloseTo(largerPercentage - smallerPercentage))
                                expect(direction2Percentage).to(equal(0))
                            }
                        }
                    }
                }
            }
            
            // MARK: - Drag Rotation Angle
            
            describe("Drag Rotation Angle") {
                for direction in [SwipeDirection.up, SwipeDirection.down] {
                    context("When the card is dragged vertically") {
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: CGPoint(direction.vector),
                                                                velocity: nil)
                        }
                        
                        it("should have rotation angle equal to zero") {
                            let actualRotationAngle = subject.cardRotationAngle(card)
                            expect(actualRotationAngle).to(equal(0))
                        }
                    }
                }
                
                for direction in [SwipeDirection.left, SwipeDirection.right] {
                    for rotationDirection in [CGFloat(-1), CGFloat(1)] {
                        context("When the card is dragged horizontally") {
                            let maximumRotationAngle: CGFloat = CGFloat.pi / 4
                            
                            beforeEach {
                                subject.testCardRotationDirectionY = rotationDirection
                                card.animationOptions
                                    = CardAnimationOptions(maximumRotationAngle: maximumRotationAngle)
                            }
                            
                            afterEach {
                                subject.reset()
                            }
                            
                            context("and less than the screen's width") {
                                let translation = CGPoint(x: direction.vector.dx * (UIScreen.main.bounds.width - 1), y: 0)
                                
                                beforeEach {
                                    testPanGestureRecognizer.performPan(withLocation: nil,
                                                                        translation: translation,
                                                                        velocity: nil)
                                }
                                
                                it("should return a rotation angle less than the maximum rotation angle") {
                                    let actualRotationAngle = subject.cardRotationAngle(card)
                                    expect(abs(actualRotationAngle)).to(beLessThan(maximumRotationAngle))
                                }
                            }
                            
                            context("and at least the length of the screen's width") {
                                let translation = CGPoint(x: direction.vector.dx * UIScreen.main.bounds.width, y: 0)
                                
                                beforeEach {
                                    testPanGestureRecognizer.performPan(withLocation: nil,
                                                                        translation: translation,
                                                                        velocity: nil)
                                }

                                it("should return a rotation angle equal to the maximum rotation angle") {
                                    let actualRotationAngle = subject.cardRotationAngle(card)
                                    expect(abs(actualRotationAngle)).to(equal(maximumRotationAngle))
                                }
                            }
                        }
                    }
                }
            }
            
            // MARK: - Drag Transform
            
            describe("Drag Transform") {
                context("When the card is dragged") {
                    let rotationAngle: CGFloat = CGFloat.pi / 4
                    let translation: CGPoint = CGPoint(x: 100, y: 100)
                    
                    beforeEach {
                        subject.testCardRotationAngle = rotationAngle
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil)
                    }
                    
                    afterEach {
                        subject.reset()
                    }
                    
                    it("should return the transform with the proper rotation and translation") {
                        let expectedTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
                            .concatenating(CGAffineTransform(rotationAngle: rotationAngle))
                        expect(subject.cardTransform(card)).to(equal(expectedTransform))
                    }
                }
            }
        }
    }
}
