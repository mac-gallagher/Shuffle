import Quick
import Nimble

@testable import Shuffle

class SwipeCardSpec: QuickSpec {
    
    override func spec() {
        describe("SwipeCard") {
            let mockCardLayoutProvider = MockCardLayoutProvider.self
            let mockCardAnimator = MockCardAnimator.self
            let mockCardTransformProvider = MockCardTransformProvider.self
            
            var mockSwipeCardDelegate: MockSwipeCardDelegate!
            var notificationCenter: TestableNotificationCenter!
            var subject: TestableSwipeCard!
            
            beforeEach {
                mockSwipeCardDelegate = MockSwipeCardDelegate()
                notificationCenter = TestableNotificationCenter()
                subject = TestableSwipeCard(animator: mockCardAnimator,
                                            layoutProvider: mockCardLayoutProvider,
                                            transformProvider: mockCardTransformProvider,
                                            notificationCenter: notificationCenter)
                subject.delegate = mockSwipeCardDelegate
            }
            
            describe("Initialization") {
                var card: SwipeCard!
                
                context("When initializing a SwipeCard with the default initializer") {
                    beforeEach {
                        card = SwipeCard()
                    }
                    
                    it("should have the correct default properties") {
                        testDefaultProperties()
                    }
                }
                
                context("When initializing a SwipeCard with the required initializer") {
                    beforeEach {
                        // TODO: - Find a non-deprecated way to accomplish this
                        let coder = NSKeyedUnarchiver(forReadingWith: Data())
                        card = SwipeCard(coder: coder)
                    }
                    
                    it("should have the correct default properties") {
                        testDefaultProperties()
                    }
                }
                
                func testDefaultProperties() {
                    expect(card.delegate).to(beNil())
                    expect(card.animationOptions).to(be(CardAnimationOptions.default))
                    expect(card.footerHeight).to(equal(100))
                    expect(card.content).to(beNil())
                    expect(card.footer).to(beNil())
                    
                    expect(card.leftOverlay).to(beNil())
                    expect(card.upOverlay).to(beNil())
                    expect(card.rightOverlay).to(beNil())
                    expect(card.downOverlay).to(beNil())
                    
                    expect(card.touchLocation).to(beNil())
                    
                    let overlayContainer = card.subviews.first
                    expect(overlayContainer).toNot(beNil())
                }
            }
            
            // MARK: - Variables
            
            // MARK: Footer Height
            
            describe("Footer Height") {
                context("When setting the footerHeight variable") {
                    beforeEach {
                        subject.footerHeight = 100
                    }
                    
                    it("should trigger a new layout cycle") {
                        subject.setNeedsLayoutCalled = true
                    }
                }
            }
            
            // MARK: Content
            
            describe("Content") {
                context("When setting the content variable when it has not been set") {
                    beforeEach {
                        subject.content = UIView()
                    }
                    
                    it("should trigger a new layout cycle") {
                        subject.setNeedsLayoutCalled = true
                    }
                }
                
                context("When setting the content variable when it has already been set") {
                    let oldContent = UIView()
                    let newContent = UIView()
                    
                    beforeEach {
                        oldContent.tag = 1
                        newContent.tag = 2
                        
                        subject.content = oldContent
                        subject.layoutIfNeeded()
                        
                        subject.content = newContent
                        subject.layoutIfNeeded()
                    }
                    
                    it("should remove the old content from the view hierarchy and add the new content") {
                        expect(subject.subviews.filter{ $0.tag == 1 }.count).to(equal(0))
                        expect(subject.subviews.filter{ $0.tag == 2 }.count).to(equal(1))
                    }
                }
            }
            
            // MARK: Footer
            
            describe("Footer") {
                context("When setting the footer variable when it has not been set") {
                    beforeEach {
                        subject.footer = UIView()
                    }
                    
                    it("should trigger a new layout cycle") {
                        subject.setNeedsLayoutCalled = true
                    }
                }
                
                context("When setting the footer variable when it has already been set") {
                    let oldFooter = UIView()
                    let newFooter = UIView()
                    
                    beforeEach {
                        oldFooter.tag = 1
                        newFooter.tag = 2
                        
                        subject.footer = oldFooter
                        subject.layoutIfNeeded()
                        
                        subject.footer = newFooter
                        subject.layoutIfNeeded()
                    }
                    
                    it("should remove the old footer from the view hierarchy and add the new footer") {
                        expect(subject.subviews.filter{ $0.tag == 1 }.count).to(equal(0))
                        expect(subject.subviews.filter{ $0.tag == 2 }.count).to(equal(1))
                    }
                }
            }
            
            // MARK: - Animation Completions
            
            // MARK: Swipe Completion
            
            describe("Swipe Completion") {
                context("When the swipe animation completion is called") {
                    beforeEach {
                        subject.swipeCompletion()
                    }
                    
                    it("should post the correct notification to the notification center") {
                        expect(notificationCenter.postedNotificationName)
                            .to(equal(CardDidFinishSwipeAnimationNotification))
                        expect(notificationCenter.postedNotificationObject).to(be(subject))
                    }
                }
            }
            
            // MARK: Reverse Swipe Completion
            
            describe("Reverse Swipe Completion") {
                context("When the reverse swipe animation completion is called") {
                    beforeEach {
                        subject.isUserInteractionEnabled = false
                        subject.reverseSwipeCompletion(.left)
                    }
                    
                    it("should enable user interaction on the card") {
                        expect(subject.isUserInteractionEnabled).to(beTrue())
                    }
                }
            }
            
            // MARK: - Layout
            
            describe("Layout") {
                context("When calling layoutSubviews") {
                    let overlayContainerFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
                    let contentFrame = CGRect(x: 5, y: 6, width: 7, height: 8)
                    let footerFrame = CGRect(x: 9, y: 10, width: 11, height: 12)
                    let content = UIView()
                    let footer = UIView()
                    let overlay = UIView()
                    
                    beforeEach {
                        mockCardLayoutProvider.testContentFrame = contentFrame
                        mockCardLayoutProvider.testOverlayContainerFrame = overlayContainerFrame
                        mockCardLayoutProvider.testFooterFrame = footerFrame
                        
                        subject.content = content
                        subject.footer = footer
                        subject.testOverlay[.left] = overlay
                        
                        subject.addOverlays()
                        subject.layoutSubviews()
                    }
                    
                    afterEach {
                        mockCardLayoutProvider.reset()
                    }
                    
                    it("should correctly layout the footer and the content") {
                        expect(footer.frame).to(equal(footerFrame))
                        expect(content.frame).to(equal(contentFrame))
                    }
                    
                    it("should correctly layout the overlay container and its overlays") {
                        let overlayContainer = subject.subviews.last
                        expect(overlayContainer?.frame).to(equal(overlayContainerFrame))
                        
                        let expectedOverlayFrame = CGRect(origin: .zero, size: overlayContainerFrame.size)
                        expect(overlay.frame).to(equal(expectedOverlayFrame))
                    }
                }
            }
            
            // MARK: Add Overlays
            
            describe("Add Overlays") {
                context("When calling addOverlays") {
                    var overlayContainer: UIView!
                    
                    let overlay1 = UIView()
                    let overlay2 = UIView()
                    
                    beforeEach {
                        overlayContainer = subject.subviews.last
                        subject.testOverlay[.left] = overlay1
                        subject.testOverlay[.right] = overlay2
                        subject.addOverlays()
                    }
                    
                    it("should add the new overlays to the overlay container's view hierarchy") {
                        expect(overlayContainer.subviews.count).to(equal(2))
                        expect(overlay1.superview).to(equal(overlayContainer))
                        expect(overlay2.superview).to(equal(overlayContainer))
                    }
                    
                    it("should set the new overlays' alpha value equal to zero") {
                        expect(overlay1.alpha).to(equal(0))
                        expect(overlay2.alpha).to(equal(0))
                    }
                    
                    it("should disable user interaction on the overlay container and its overlays") {
                        let overlayContainer = subject.subviews.first
                        expect(overlayContainer?.isUserInteractionEnabled).to(beFalse())
                        expect(overlay1.isUserInteractionEnabled).to(beFalse())
                        expect(overlay2.isUserInteractionEnabled).to(beFalse())
                    }
                }
            }
            
            // MARK: - Gesture Recognizer Methods
            
            // MARK: Tap Gesture
            
            describe("Tap Gesture") {
                context("When didTap is called") {
                    let touchPoint = CGPoint(x: 50, y: 50)
                    let testTapGestureRecognizer = TestableTapGestureRecognizer()
                    
                    beforeEach {
                        testTapGestureRecognizer.performTap(withLocation: touchPoint)
                        subject.didTap(testTapGestureRecognizer)
                    }
                    
                    it("should set the correct touch location") {
                        expect(subject.touchLocation).to(equal(touchPoint))
                    }
                    
                    it("should call the didTap delegate method") {
                        expect(mockSwipeCardDelegate.didTapCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: Physical Swipe Begin
            
            describe("Physical Swipe Begin") {
                context("When beginSwiping is called") {
                    let touchPoint = CGPoint(x: 50, y: 50)
                    let testPanGestureRecognizer = TestablePanGestureRecognizer()
                    
                    beforeEach {
                        testPanGestureRecognizer.performPan(withLocation: touchPoint,
                                                            translation: nil,
                                                            velocity: nil)
                        subject.beginSwiping(testPanGestureRecognizer)
                    }
                    
                    afterEach {
                        mockCardAnimator.reset()
                    }
                    
                    it("should set the correct touch location") {
                        expect(subject.touchLocation).to(equal(touchPoint))
                    }
                    
                    it("should call the didBeginSwipe delegate method") {
                        expect(mockSwipeCardDelegate.didBeginSwipeCalled).to(beTrue())
                    }
                    
                    it("should remove all animations on the card") {
                        expect(mockCardAnimator.removeAllAnimationsCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: Physical Swipe Change
            
            describe("Physical Swipe Change") {
                context("When the continueSwiping method is called") {
                    let overlay = UIView()
                    let overlayPercentage: CGFloat = 0.5
                    
                    let transform: CGAffineTransform = {
                        let rotation = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                        let translation = CGAffineTransform(translationX: 100, y: 100)
                        return rotation.concatenating(translation)
                    }()
                    
                    beforeEach {
                        subject.testOverlay[.left] = overlay
                        mockCardTransformProvider.testCardOverlayPercentage[.left] = overlayPercentage
                        subject.addOverlays()
                        
                        mockCardTransformProvider.testCardTranform = transform
                        subject.continueSwiping(UIPanGestureRecognizer())
                    }
                    
                    afterEach {
                        mockCardTransformProvider.reset()
                    }
                    
                    it("should call the didContinueSwipe delegate method") {
                        expect(mockSwipeCardDelegate.didContinueSwipeCalled).to(beTrue())
                    }
                    
                    it("should apply the proper overlay alpha values") {
                            expect(overlay.alpha).to(equal(overlayPercentage))
                    }
                    
                    it("should apply the proper transformation to the card") {
                        expect(subject.transform).to(equal(transform))
                    }
                }
            }
            
            // MARK: Physical Swipe End
            
            describe("Physical Swipe End") {
                context("When the didSwipe method is called") {
                    let direction: SwipeDirection = .left
                    
                    beforeEach {
                        subject.didSwipe(UIPanGestureRecognizer(), with: direction)
                    }
                    
                    afterEach {
                        mockCardAnimator.reset()
                    }
                    
                    it("should call the swipeAction method with the correct parameters") {
                        expect(subject.swipeActionDirection).to(equal(direction))
                        expect(subject.swipeActionForced).to(equal(false))
                        expect(subject.swipeActionAnimated).to(equal(true))
                    }
                }
            }
            
            context("When the didCancelSwipe method is called") {
                beforeEach {
                    subject.didCancelSwipe(UIPanGestureRecognizer())
                }
                
                afterEach {
                    mockCardAnimator.reset()
                }
                
                it("should call the animator's reset method") {
                    expect(mockCardAnimator.resetCalled).to(beTrue())
                }
            }
            
            // MARK: - Main Methods
            
            // MARK: Overlay Getter
            
            describe("Overlay Getter") {
                context("When calling the overlay getter function") {
                    it("should return nil") {
                        expect(subject.overlay(forDirection: .left)).to(beNil())
                    }
                }
            }
            
            // MARK: Programmatic Swipe
            
            describe("Programmatic Swipe") {
                context("When the swipe method is called") {
                    let direction: SwipeDirection = .left
                    let animated: Bool = false
                    
                    beforeEach {
                        subject.swipe(direction: direction, animated: animated)
                    }
                    
                    afterEach {
                        mockCardAnimator.reset()
                    }
                    
                    it("should call the swipeAction method with the correct parameters") {
                        expect(subject.swipeActionDirection).to(equal(direction))
                        expect(subject.swipeActionForced).to(equal(true))
                        expect(subject.swipeActionAnimated).to(equal(animated))
                    }
                }
            }
            
            // MARK: Swipe Action
            
            describe("Swipe Action") {
                context("When the swipeAction method is called") {
                    let direction: SwipeDirection = .left
                    let forced: Bool = false
                    
                    context("and animated is true") {
                        beforeEach {
                            subject.swipeAction(direction: direction,
                                                forced: forced,
                                                animated: true)
                        }
                        
                        afterEach {
                            mockCardAnimator.reset()
                        }
                        
                        it("should disable the user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should call the didSwipe delegate method with the correct parameters") {
                            expect(mockSwipeCardDelegate.didSwipeCalled).to(beTrue())
                            expect(mockSwipeCardDelegate.didSwipeDirection).to(equal(direction))
                            expect(mockSwipeCardDelegate.didSwipeForced).to(equal(forced))
                        }
                        
                        it("call the animator's swipe method with the correct parameters") {
                            expect(mockCardAnimator.swipeCalled).to(beTrue())
                            expect(mockCardAnimator.swipeDirection).to(equal(direction))
                            expect(mockCardAnimator.swipeForced).to(equal(forced))
                        }
                    }
                    
                    context("and animated is false") {
                        beforeEach {
                            subject.swipeAction(direction: direction,
                                                forced: forced,
                                                animated: false)
                        }
                        
                        it("should disable the user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should call the didSwipe delegate method with the correct parameters") {
                            expect(mockSwipeCardDelegate.didSwipeCalled).to(beTrue())
                            expect(mockSwipeCardDelegate.didSwipeDirection).to(equal(direction))
                            expect(mockSwipeCardDelegate.didSwipeForced).to(equal(forced))
                        }
                        
                        it("should call the card's swipe completion block") {
                            expect(subject.swipeCompletionCalled).to(beTrue())
                        }
                        
                        it("should not call the animator's swipe") {
                            expect(mockCardAnimator.swipeCalled).to(beFalse())
                        }
                    }
                }
            }
            
            // MARK: Reverse Swipe
            
            describe("Reverse Swipe") {
                context("When the reverse swipe method is called") {
                    let direction: SwipeDirection = .left
                    
                    context("and animated is true") {
                        beforeEach {
                            subject.reverseSwipe(from: direction, animated: true)
                        }
                        
                        afterEach {
                            mockCardAnimator.reset()
                        }
                        
                        it("should disable user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should call the reverseSwipe delegate method with the correct parameters") {
                            expect(mockSwipeCardDelegate.didReverseSwipeCalled).to(beTrue())
                            expect(mockSwipeCardDelegate.didReverseSwipeDirection).to(equal(direction))
                        }
                        
                        it("should call the animator's reverse swipe method with the correct direction") {
                            expect(mockCardAnimator.reverseSwipeCalled).to(beTrue())
                            expect(mockCardAnimator.reverseSwipeDirection).to(equal(direction))
                        }
                    }
                    
                    context("and animated is false") {
                        beforeEach {
                            subject.reverseSwipe(from: direction, animated: false)
                        }
                        
                        it("should call the reverseSwipe delegate method with the correct parameters") {
                            expect(mockSwipeCardDelegate.didReverseSwipeCalled).to(beTrue())
                            expect(mockSwipeCardDelegate.didReverseSwipeDirection).to(equal(direction))
                        }
                        
                        it("should not call the animator's reverse swipe method") {
                            expect(mockCardAnimator.reverseSwipeCalled).to(beFalse())
                        }
                        
                        it("should call the card's reverse swipe completion block") {
                            expect(subject.reverseSwipeCompletionCalled).to(beTrue())
                        }
                    }
                }
            }
            
            // MARK: Remove All Animations
            
            describe("Remove All Animations") {
                context("When the removeAllAnimations method is called") {
                    beforeEach {
                        UIView.animate(withDuration: 100, animations: {
                            subject.alpha = 0
                        })
                        subject.removeAllAnimations()
                    }
                    
                    afterEach {
                        mockCardAnimator.reset()
                    }
                    
                    it("should remove all the current animations on it's layer") {
                        expect(subject.layer.animationKeys()).to(beNil())
                    }
                    
                    it("should call the animator's removeAllAnimations method") {
                        expect(mockCardAnimator.removeAllAnimationsCalled).to(beTrue())
                    }
                }
            }
        }
    }
}
