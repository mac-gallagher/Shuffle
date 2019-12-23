import Quick
import Nimble

@testable import Shuffle

class CardAnimatorSpec: QuickSpec {
    
    override func spec() {
        describe("CardAnimator") {
            let cardWidth: CGFloat = 100
            let cardHeight: CGFloat = 200
            let subject = TestableCardAnimator.self
            
            var card: TestableSwipeCard!
            
            beforeEach {
                card = TestableSwipeCard(animator: MockCardAnimator.self,
                                         layoutProvider: MockCardLayoutProvider.self,
                                         transformProvider: MockCardTransformProvider.self,
                                         notificationCenter: TestableNotificationCenter())
                card.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
            }
            
            // MARK: - Animation Key Frames
            
            // MARK: Swipe Animation Key Frames
            
            describe("Swipe Animation Key Frames") {
                for swipeDirection in SwipeDirection.allDirections {
                    context("When animating swipeAnimationKeyFrames with the indicated direction") {
                        let swipeTransform = CGAffineTransform(a: 1, b: 2, c: 3,
                                                               d: 4, tx: 5, ty: 6)
                        let relativeOverlayDuration: TimeInterval = 0.4
                        
                        beforeEach {
                            for overlayDirection in card.swipeDirections {
                                card.testOverlay[overlayDirection] = UIView()
                            }
                            card.addOverlays()
                            
                            subject.testRelativeSwipeOverlayFadeDuration = relativeOverlayDuration
                            subject.testSwipeTransform = swipeTransform
                            
                            UIView.animateKeyframes(withDuration: 0.0, delay: 0.0, animations: {
                                subject.swipeAnimationKeyFrames(card, swipeDirection, true)
                            }, completion: nil)
                        }
                        
                        afterEach {
                            subject.reset()
                        }
                        
                        it("should set the alpha value of all other overlays to zero") {
                            for overlay in card.overlays.filter({ $0.key != swipeDirection }).values {
                                expect(overlay.alpha).to(equal(0.0))
                            }
                        }
                        
                        it("should add an overlay fade key frame with the correct parameters") {
                            let overlay = card.overlays[swipeDirection]
                            expect(subject.fadeView).to(equal(overlay))
                            expect(subject.fadeAlpha).to(equal(1))
                            expect(subject.fadeRelativeDuration).to(equal(relativeOverlayDuration))
                            expect(subject.fadeRelativeStartTime).to(equal(0))
                        }
                        
                        it("should add a card transform key frame with the correct parameters") {
                            expect(subject.transformView).to(equal(card))
                            expect(subject.transformTransform).to(equal(swipeTransform))
                            expect(subject.transformRelativeDuration).to(equal(1 - relativeOverlayDuration))
                            expect(subject.transformRelativeStartTime).to(equal(relativeOverlayDuration))
                        }
                    }
                }
            }
            
            // MARK: Reverse Swipe Animation Key Frames
            
            describe("Reverse Swipe Animation Key Frames") {
                for reverseSwipeDirection in SwipeDirection.allDirections {
                    context("When animating the reverseSwipeAnimationKeyFrames") {
                        let relativeOverlayDuration: TimeInterval = 0.4

                        beforeEach {
                            for overlayDirection in card.swipeDirections {
                                card.testOverlay[overlayDirection] = UIView()
                                card.testOverlay[overlayDirection]?.alpha = 0.5
                            }
                            card.addOverlays()

                            subject.testRelativeReverseSwipeOverlayFadeDuration = relativeOverlayDuration

                            UIView.animateKeyframes(withDuration: 0.0, delay: 0.0, animations: {
                                subject.reverseSwipeAnimationKeyFrames(card, reverseSwipeDirection)
                            }, completion: nil)
                        }
                        
                        afterEach {
                            subject.reset()
                        }

                        it("should set the overlay's alpha value in the indicated direction to one and zero otherwise") {
                            for direction in card.swipeDirections {
                                let expectedAlpha: CGFloat = direction == reverseSwipeDirection ? 1.0 : 0.0
                                expect(card.overlays[direction]?.alpha).to(equal(expectedAlpha))
                            }
                        }
                        
                        it("should add a card transform key frame with the correct parameters") {
                            expect(subject.transformView).to(equal(card))
                            expect(subject.transformTransform).to(equal(.identity))
                            expect(subject.transformRelativeDuration).to(equal(1 - relativeOverlayDuration))
                            expect(subject.transformRelativeStartTime).to(equal(0))
                        }
                        
                        it("should add an overlay fade key frame with the correct parameters") {
                            let overlay = card.overlay(forDirection: reverseSwipeDirection)
                            expect(subject.fadeView).to(equal(overlay))
                            expect(subject.fadeAlpha).to(equal(0))
                            expect(subject.fadeRelativeDuration).to(equal(relativeOverlayDuration))
                            expect(subject.fadeRelativeStartTime).to(equal(1 - relativeOverlayDuration))
                        }
                    }
                }
            }
            
            // MARK: Reset Animation Block
            
            describe("Reset Animation Block") {
                context("When animating resetAnimationBlock") {
                    let initialTransform = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
                    let overlay = UIView()
                    
                    beforeEach {
                        let direction: SwipeDirection = .left
                        
                        card.transform = initialTransform
                        card.testActiveDirection = direction
                        card.testOverlay[direction] = overlay
                        card.addOverlays()
                        overlay.alpha = 0.5
                        
                        UIView.animate(withDuration: 0.0, animations: {
                            subject.resetAnimationBlock(card)
                        })
                    }
                    
                    it("should animate the card's active overlay alpha to zero") {
                        expect(overlay.alpha).to(equal(0))
                    }
                    
                    it("should animate the card's transform to equal the identity transform") {
                        expect(card.transform).to(equal(.identity))
                    }
                }
            }
            
            // MARK: - Animation Calculations
            
            // MARK: Swipe Duration
            
            describe("Swipe Duration") {
                context("When accessing the swipeDuration variable") {
                    let direction: SwipeDirection = .left
                    let totalDuration: TimeInterval = 30
                    let minimumSwipeSpeed: CGFloat = 100
                    
                    beforeEach {
                        card.animationOptions = CardAnimationOptions(totalSwipeDuration: totalDuration)
                        card.testMinimumSwipeSpeed = minimumSwipeSpeed
                    }
                    
                    context("and forced is true") {
                        it("should return totalSwipeDuration from card.animationOptions") {
                            let actualDuration = subject.swipeDuration(card, direction, true)
                            expect(actualDuration).to(equal(totalDuration))
                        }
                    }
                    
                    context("and forced is false") {
                        context("and the card was swiped at least the minimum swipe speed") {
                            let swipeFactor: CGFloat = 2.0
                            
                            beforeEach {
                                card.testDragSpeed = swipeFactor * minimumSwipeSpeed
                            }
                            
                            it("should return the correct relative swipe duration") {
                                let actualDuration = subject.swipeDuration(card, direction, false)
                                expect(actualDuration).to(equal(1 / TimeInterval(swipeFactor)))
                            }
                        }
                        
                        context("and the card was swiped at less than the minimum swipe speed") {
                            beforeEach {
                                card.testDragSpeed = minimumSwipeSpeed / 2
                            }
                            
                            it("should return totalSwipeDuration from card.animationOptions") {
                                let actualDuration = subject.swipeDuration(card, direction, false)
                                expect(actualDuration).to(equal(totalDuration))
                            }
                        }
                    }
                }
            }
            
            // MARK: Relative Swipe Overlay Fade Duration
            
            describe("Relative Swipe Overlay Fade Duration") {
                context("When accessing the relativeSwipeOverlayFadeDuration variable") {
                    let direction: SwipeDirection = .left
                    
                    for forced in [false, true] {
                        context("and there is no overlay in the indicated direction") {
                            beforeEach {
                                card.testOverlay[direction] = nil
                                card.addOverlays()
                            }
                            
                            it("should return a duration of zero") {
                                let actualDuration
                                    = subject.relativeSwipeOverlayFadeDuration(card, direction, forced)
                                expect(actualDuration).to(equal(0.0))
                            }
                        }
                    }
                    
                    context("and there an overlay in the indicated direction") {
                        let relativeDuration: TimeInterval = 0.9
                        let totalDuration: TimeInterval = 50.0
                        
                        beforeEach {
                            card.testOverlay[direction] = UIView()
                            card.addOverlays()
                            card.animationOptions
                                = CardAnimationOptions(totalSwipeDuration: totalDuration,
                                                       relativeSwipeOverlayFadeDuration: relativeDuration)
                        }
                        
                        context("and it is forced") {
                            it("should return the correct duration") {
                                let actualDuration
                                    = subject.relativeSwipeOverlayFadeDuration(card, direction, true)
                                expect(actualDuration).to(equal(relativeDuration))
                            }
                        }
                        
                        context("and it is not forced") {
                            it("should return a duration of zero") {
                                let actualDuration
                                    = subject.relativeSwipeOverlayFadeDuration(card, direction, false)
                                expect(actualDuration).to(equal(0))
                            }
                        }
                    }
                }
            }
            
            // MARK: Relative Reverse Swipe Overlay Fade Duration
            
            describe("Relative Reverse Swipe Overlay Fade Duration") {
                context("When accessing the relativeReverseSwipeOverlayFadeDuration variable") {
                    let direction: SwipeDirection = .left
                    
                    context("and there is no overlay in the indicated direction") {
                        beforeEach {
                            card.testOverlay[direction] = nil
                            card.addOverlays()
                        }
                        
                        it("should return a duration of zero") {
                            let actualDuration
                                = subject.relativeReverseSwipeOverlayFadeDuration(card, direction)
                            expect(actualDuration).to(equal(0.0))
                        }
                    }
                    
                    context("and there is an overlay in the indicated direction") {
                        let relativeDuration: TimeInterval = 0.9
                        let totalDuration: TimeInterval = 50.0
                        
                        beforeEach {
                            card.testOverlay[direction] = UIView()
                            card.animationOptions
                                = CardAnimationOptions(totalReverseSwipeDuration: totalDuration,
                                                       relativeReverseSwipeOverlayFadeDuration: relativeDuration)
                            card.addOverlays()
                        }
                        
                        it("should return the should return the correct duration") {
                            let actualDuration
                                = subject.relativeReverseSwipeOverlayFadeDuration(card, direction)
                            expect(actualDuration).to(equal(relativeDuration))
                        }
                    }
                }
            }
            
            // MARK: Swipe Rotation
            
            describe("Swipe Rotation") {
                context("When accessing the swipeRotation variable") {
                    for direction in [SwipeDirection.up, SwipeDirection.down] {
                        context("and the direction is vertical") {
                            it("should return zero") {
                                let actualRotation = subject.swipeRotationAngle(card, direction, false)
                                expect(actualRotation).to(equal(0.0))
                            }
                        }
                    }
                    
                    for direction in [SwipeDirection.left, SwipeDirection.right] {
                        context("When the direction is horizontal") {
                            let maximumRotationAngle: CGFloat = CGFloat.pi / 4
                            
                            beforeEach {
                                card.animationOptions
                                    = CardAnimationOptions(maximumRotationAngle: maximumRotationAngle)
                            }
                            
                            context("and forced is true") {
                                it("should return the twice the maximum rotation angle") {
                                    let actualRotation = subject.swipeRotationAngle(card, direction, true)
                                    let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                                    expect(actualRotation).to(equal(expectedRotation))
                                }
                            }
                            
                            context("and forced is false") {
                                let cardCenterX: CGFloat = cardWidth / 2
                                let cardCenterY: CGFloat = cardHeight / 2
                                
                                context("and the touch point is nil") {
                                    beforeEach {
                                        card.testTouchLocation = nil
                                    }
                                    
                                    it("should return the twice the maximum rotation angle") {
                                        let actualRotation = subject.swipeRotationAngle(card, direction, false)
                                        let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                                        expect(actualRotation).to(equal(expectedRotation))
                                    }
                                }
                                
                                context("and the touch point is in the first quadrant of the card's bounds") {
                                    beforeEach {
                                        card.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
                                    }
                                    
                                    it("should return the correct rotation angle") {
                                        let actualRotation = subject.swipeRotationAngle(card, direction, false)
                                        let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                                        expect(actualRotation).to(equal(expectedRotation))
                                    }
                                }
                                
                                context("and the touch point is in the second quadrant of the card's bounds") {
                                    beforeEach {
                                        card.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
                                    }
                                    
                                    it("should return the correct rotation angle") {
                                        let actualRotation = subject.swipeRotationAngle(card, direction, false)
                                        let expectedRotation = 2 * (direction == .left ? -1 : 1) * maximumRotationAngle
                                        expect(actualRotation).to(equal(expectedRotation))
                                    }
                                }
                                
                                context("and the touch point is in the third quadrant of the card's bounds") {
                                    beforeEach {
                                        card.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
                                    }
                                    
                                    it("should return the correct rotation angle") {
                                        let actualRotation = subject.swipeRotationAngle(card, direction, false)
                                        let expectedRotation = 2 * (direction == .right ? -1 : 1) * maximumRotationAngle
                                        expect(actualRotation).to(equal(expectedRotation))
                                    }
                                }
                                
                                context("and the touch point is in the fourth quadrant of the card's bounds") {
                                    beforeEach {
                                        card.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
                                    }
                                    
                                    it("should return the correct rotation angle") {
                                        let actualRotation = subject.swipeRotationAngle(card, direction, false)
                                        let expectedRotation = 2 * (direction == .right ? -1 : 1) * maximumRotationAngle
                                        expect(actualRotation).to(equal(expectedRotation))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // MARK: Swipe Translation
            
            describe("Swipe Translation") {
                context("When accessing the swipeTranslation variable") {
                    let screenBounds: CGRect = UIScreen.main.bounds
                    let minimumSwipeSpeed: CGFloat = 100
                    
                    beforeEach {
                        card.testMinimumSwipeSpeed = minimumSwipeSpeed
                    }
                    
                    context("and the swipe is below the minimum swipe speed") {
                        beforeEach {
                            card.testDragSpeed = minimumSwipeSpeed / 2
                        }
                        
                        it("should return a translation far enough to swipe the card off screen") {
                            let direction: SwipeDirection = .left
                            let actualTranslation = subject.swipeTranslation(card, direction, direction.vector)
                            let translatedCardBounds = CGRect(x: actualTranslation.dx,
                                                              y: actualTranslation.dy,
                                                              width: cardWidth,
                                                              height: cardHeight)
                            expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
                        }
                    }
                    
                    context("and the swipe is at least the minimum swipe speed") {
                        beforeEach {
                            card.testDragSpeed = minimumSwipeSpeed
                        }
                        
                        it("should return a translation far enough to swipe the card off screen") {
                            let direction: SwipeDirection = .left
                            let actualTranslation = subject.swipeTranslation(card, direction, direction.vector)
                            let translatedCardBounds = CGRect(x: actualTranslation.dx,
                                                              y: actualTranslation.dy,
                                                              width: cardWidth,
                                                              height: cardHeight)
                            expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
                        }
                    }
                }
            }
            
            // MARK: Swipe Transform
            
            describe("Swipe Transform") {
                context("When accessing the swipeTransform variable") {
                    let testRotationAngle: CGFloat = CGFloat.pi / 4
                    let testTranslation: CGVector = CGVector(dx: 100, dy: 200)
                    
                    let testTransform: CGAffineTransform = {
                        let rotation = CGAffineTransform(rotationAngle: testRotationAngle)
                        let translation = CGAffineTransform(translationX: testTranslation.dx,
                                                            y: testTranslation.dy)
                        return rotation.concatenating(translation)
                    }()
                    
                    beforeEach {
                        subject.testSwipeRotationAngle = testRotationAngle
                        subject.testSwipeTranslation = testTranslation
                    }
                    
                    afterEach {
                        subject.reset()
                    }
                    
                    it("should return a transform with the proper rotation and translation") {
                        let actualTranslation = subject.swipeTransform(card, .left, false)
                        expect(actualTranslation).to(equal(testTransform))
                        
                    }
                }
            }
            
            //MARK: - Main Methods
            
            // MARK: Swipe
            
            describe("Swipe") {
                context("When calling the swipe method") {
                    let duration: TimeInterval = 30
                    
                    beforeEach {
                        subject.testSwipeDuration = duration
                        subject.swipe(card, direction: .left, forced: false)
                    }
                    
                    afterEach {
                        subject.reset()
                    }
                    
                    it("should apply a key frame animation with the correct parameters") {
                        let expectedOptions = UIView.KeyframeAnimationOptions.calculationModeLinear
                        expect(subject.animateKeyFramesOptions).to(equal(expectedOptions))
                        expect(subject.animateKeyFramesDuration).to(equal(duration))
                    }
                    
                    it("should call the swipe key frame animation block") {
                        expect(subject.swipeAnimationKeyFramesCalled).to(beTrue())
                    }
                    
                    it("should call the card's swipe completion block once the animation has completed") {
                        expect(card.swipeCompletionCalled).toEventually(beTrue())
                    }
                }
            }
            
            // MARK: Reverse Swipe
            
            describe("Reverse Swipe") {
                context("When calling the reverseSwipe method") {
                    let totalDuration: TimeInterval = 30.0
                    
                    beforeEach {
                        card.animationOptions
                            = CardAnimationOptions(totalReverseSwipeDuration: totalDuration)
                        subject.reverseSwipe(card, from: .left)
                    }
                    
                    afterEach {
                        subject.reset()
                    }
                    
                    it("should recreate the swipe") {
                        expect(subject.swipeAnimationKeyFramesCalled).to(beTrue())
                    }
                    
                    it("should apply a key frame animation with the correct parameters") {
                        expect(subject.animateKeyFramesDuration).to(equal(totalDuration))
                        
                        let expectedOptions = UIView.KeyframeAnimationOptions.calculationModeLinear
                        expect(subject.animateKeyFramesOptions).to(equal(expectedOptions))
                    }
                    
                    it("should call the reverse swipe key frame animation block") {
                        expect(subject.reverseSwipeAnimationKeyFramesCalled).to(beTrue())
                    }
                    
                    it("should call the card's reverse swipe completion block once the animation has completed") {
                        expect(card.reverseSwipeCompletionCalled).toEventually(beTrue())
                    }
                }
            }
            
            //MARK: Reset
            
            describe("Reset") {
                context("When calling the reset method") {
                    let totalDuration: TimeInterval = 20
                    let damping: CGFloat = 0.7
                    
                    beforeEach {
                        card.animationOptions
                            = CardAnimationOptions(totalResetDuration: totalDuration,
                                                   resetSpringDamping: damping)
                        subject.reset(card)
                    }
                    
                    afterEach {
                        subject.reset()
                    }
                    
                    it("should remove all animations on the card") {
                        expect(subject.removeAllAnimationsCalled).to(beTrue())
                    }
                    
                    it("should apply spring animation with the correct parameters") {
                        expect(subject.animateSpringOptions).to(equal([.curveLinear,
                                                                       .allowUserInteraction]))
                        expect(subject.animateSpringDamping).to(equal(damping))
                        expect(subject.animateSpringDuration).to(equal(totalDuration))
                    }
                    
                    it("should call the reset animation block") {
                        expect(subject.resetAnimationBlockCalled).to(beTrue())
                    }
                }
            }
            
            
            // MARK: Remove All Animations
            
            describe("Remove All Animations") {
                context("When calling the removeAllAnimations method") {
                    let overlay = UIView()
                    
                    beforeEach {
                        card.testOverlay[.left] = overlay
                        card.addOverlays()
                        
                        UIView.animate(withDuration: 100, animations: {
                            card.alpha = 0
                            overlay.transform = CGAffineTransform(a: 1, b: 2, c: 3,
                                                                  d: 4, tx: 5, ty: 6)
                        })
                        subject.removeAllAnimations(on: card)
                    }
                    
                    afterEach {
                        subject.reset()
                    }
                    
                    it("should remove all current animations on the card's layer") {
                        expect(card.layer.animationKeys()).to(beNil())
                    }
                    
                    it("should remove all current animations on each of the card's overlays") {
                        expect(overlay.layer.animationKeys()).to(beNil())
                    }
                }
            }
        }
    }
}
