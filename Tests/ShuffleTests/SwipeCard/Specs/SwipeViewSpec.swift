import Quick
import Nimble

@testable import Shuffle

class SwipeViewSpec: QuickSpec {
    
    override func spec() {
        describe("SwipeView") {
            var subject: TestableSwipeView!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            var testTapGestureRecognizer: TestableTapGestureRecognizer!
            
            beforeEach {
                subject = TestableSwipeView()
                testPanGestureRecognizer = subject.panGestureRecognizer as? TestablePanGestureRecognizer
                testTapGestureRecognizer = subject.tapGestureRecognizer as? TestableTapGestureRecognizer
            }
            
            // MARK: - Initialization
            
            describe("Initialization") {
                var swipeView: SwipeView!
                
                context("When initializing a new swipe view with the default initializer") {
                    beforeEach {
                        swipeView = SwipeView()
                    }
                    
                    it("should have the correct default properties") {
                        testDefaultProperties()
                    }
                }
                
                context("When initializing a new swipe view with the required initializer") {
                    beforeEach {
                        // TODO: - Find a non-deprecated way to accomplish this
                        let coder = NSKeyedUnarchiver(forReadingWith: Data())
                        swipeView = SwipeView(coder: coder)
                    }
                    
                    it("should have the correct default properties") {
                        testDefaultProperties()
                    }
                }
                
                func testDefaultProperties() {
                    expect(swipeView.swipeDirections).to(equal(SwipeDirection.allDirections))
                    expect(swipeView.tapGestureRecognizer).toNot(beNil())
                    expect(swipeView.panGestureRecognizer).toNot(beNil())
                    expect(swipeView.activeDirection).to(beNil())
                }
            }
            
            // MARK: - Active Direction
            
            describe("Active Direction") {
                describe("When accessing the activeDirection variable") {
                    let minimumSwipeDistance: CGFloat = 100
                    let neighboringPairs: [(SwipeDirection, SwipeDirection)]
                        = [(.up, .right),
                           (.right, .down),
                           (.down, .left),
                           (.left, .up)]
                    
                    beforeEach {
                        subject.minSwipeDistance = minimumSwipeDistance
                    }
                    
                    context("and the drag percentage is zero in all directions") {
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: .zero,
                                                                velocity: nil)
                        }
                        
                        it("should return nil") {
                            expect(subject.activeDirection).to(beNil())
                        }
                    }
                    
                    for direction in SwipeDirection.allDirections {
                        context("and the drag percentage is nonzero in exactly one direction") {
                            beforeEach {
                                testPanGestureRecognizer.performPan(withLocation: nil,
                                                                    translation: CGPoint(direction.vector),
                                                                    velocity: nil)
                            }
                            
                            it("should return the correct direction") {
                                expect(subject.activeDirection).to(equal(direction))
                            }
                        }
                    }
                    
                    for (direction1, direction2) in neighboringPairs {
                        context("and the drag percentage is nonzero in exactly two directions") {
                            let direction1Translation = 2 * direction1.vector * minimumSwipeDistance
                            let direction2Translation = direction2.vector * minimumSwipeDistance
                            
                            beforeEach {
                                let translation = direction1Translation + direction2Translation
                                testPanGestureRecognizer.performPan(withLocation: nil,
                                                                    translation: CGPoint(translation),
                                                                    velocity: nil)
                            }
                            
                            it("should return the direction with the highest drag percentage") {
                                expect(subject.activeDirection).to(equal(direction1))
                            }
                        }
                    }
                }
            }
            
            // MARK: - Drag Speed
            
            describe("Drag Speed") {
                for direction in SwipeDirection.allDirections {
                    context("When accessing the dragSpeed variable with the specified direction") {
                        beforeEach {
                            let velocity = direction.vector
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: nil,
                                                                velocity: CGPoint(velocity))
                        }
                        
                        it("should return a positive drag speed") {
                            expect(subject.dragSpeed(direction)).to(beGreaterThan(0))
                        }
                    }
                }
            }
            
            // MARK: - Drag Percentage
            
            describe("Drag Percentage") {
                for direction in SwipeDirection.allDirections {
                    describe("When accessing the dragPercentage variable after swiping in the specified direction") {
                        let minimumSwipeDistance: CGFloat = 100
                        let swipeFactor: CGFloat = 0.5
                        
                        beforeEach {
                            subject.minSwipeDistance = minimumSwipeDistance
                            let translation = swipeFactor * minimumSwipeDistance * direction.vector
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: CGPoint(translation),
                                                                velocity: nil)
                        }
                        
                        it("should return the correct drag percentage in the swiped direction and 0% in all other directions") {
                            for swipeDirection in SwipeDirection.allDirections {
                                let actualPercentage = subject.dragPercentage(swipeDirection)
                                let expectedPercentage = swipeDirection == direction ? swipeFactor : 0.0
                                expect(actualPercentage).to(equal(expectedPercentage))
                            }
                        }
                    }
                }
            }
            
            // MARK: - Minimum Swipe Speed
            
            describe("Minimum Swipe Speed") {
                context("When calling the minimumSwipeSpeed method") {
                    it("should return 1100") {
                        expect(subject.minimumSwipeSpeed(on: .left)).to(equal(1100))
                    }
                }
            }
            
            // MARK: - Minimum Swipe Distance
            
            describe("Minimum Swipe Distance") {
                context("When calling the minimumSwipeDistance method") {
                    it("should return UIScreen.main.bounds.width / 4 for each direction") {
                        let expectedDistance = subject.minimumSwipeDistance(on: .left)
                        expect(expectedDistance).to(equal(UIScreen.main.bounds.width / 4))
                    }
                }
            }
            
            // MARK: - Tap Gesture
            
            describe("Tap Gesture") {
                context("When a tap gesture is recognized") {
                    beforeEach {
                        testTapGestureRecognizer.performTap(withLocation: .zero)
                    }
                    
                    it("should call the didTap method") {
                        expect(subject.didTapCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: - Pan Gesture
            
            describe("Pan Gesture") {
                for state in [UIPanGestureRecognizer.State.began,
                              UIPanGestureRecognizer.State.possible] {
                    context("When a .began or .possible  pan gesture state is recognized") {
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: nil,
                                                                velocity: nil,
                                                                state: state)
                        }
                        
                        it("should call the beginSwiping method") {
                            expect(subject.beginSwipingCalled).to(beTrue())
                        }
                    }
                }
                
                context("When a .change pan gesture state is recognized") {
                    beforeEach {
                        testPanGestureRecognizer.performPan(withLocation: nil,
                                                            translation: nil,
                                                            velocity: nil,
                                                            state: .changed)
                    }
                    
                    it("should call the continueSwiping method") {
                        expect(subject.continueSwipingCalled).to(beTrue())
                    }
                }
                
                for state in [UIPanGestureRecognizer.State.ended,
                              UIPanGestureRecognizer.State.cancelled] {
                    context("When an .ended or .cancelled pan gesture state is recognized") {
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: nil,
                                                                velocity: nil,
                                                                state: state)
                        }
                        
                        it("should call the endSwiping method") {
                            expect(subject.endSwipingCalled).to(beTrue())
                        }
                    }
                }
                
                context("When a .failed gesture state is recognized") {
                    beforeEach {
                        testPanGestureRecognizer.performPan(withLocation: nil,
                                                            translation: nil,
                                                            velocity: nil,
                                                            state: .failed)
                    }
                    
                    it("should call not call any of the swipe methods") {
                        expect(subject.beginSwipingCalled).to(beFalse())
                        expect(subject.continueSwipingCalled).to(beFalse())
                        expect(subject.endSwipingCalled).to(beFalse())
                    }
                }
            }
            
            // MARK: - End Swiping
            
            describe("End Swiping") {
                describe("When the endSwiping method is called") {
                    let minimumSwipeDistance: CGFloat = 100
                    let minimumSwipeSpeed: CGFloat = 500
                    
                    beforeEach {
                        subject.minSwipeDistance = minimumSwipeDistance
                        subject.minSwipeSpeed = minimumSwipeSpeed
                    }
                    
                    context("and there is no active direction") {
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: nil,
                                                                velocity: nil)
                            subject.endSwiping(testPanGestureRecognizer)
                        }
                        
                        it("should call the didCancelSwipe method and not the didSwipe method") {
                            expect(subject.didCancelSwipeCalled).to(beTrue())
                            expect(subject.didSwipeCalled).to(beFalse())
                        }
                    }
                    
                    context("and the swipe translation is less than the minimum swipe distance") {
                        let direction: SwipeDirection = .left
                        
                        beforeEach {
                            let translation: CGPoint = CGPoint((minimumSwipeDistance / 2) * direction.vector)
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: translation,
                                                                velocity: nil)
                            subject.endSwiping(testPanGestureRecognizer)
                        }
                        
                        it("should call the didCancelSwipe method and not the didSwipe method") {
                            expect(subject.didCancelSwipeCalled).to(beTrue())
                            expect(subject.didSwipeCalled).to(beFalse())
                        }
                    }
                    
                    context("and the swipe translation is at least the minimum swipe distance") {
                        let direction: SwipeDirection = .left
                        
                        beforeEach {
                            let translation: CGPoint = CGPoint(minimumSwipeDistance * direction.vector)
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: translation,
                                                                velocity: nil)
                            subject.endSwiping(testPanGestureRecognizer)
                        }
                        
                        it("should call the didSwipe method with the correct direction") {
                            expect(subject.didSwipeCalled).to(beTrue())
                            expect(subject.didSwipeDirection).to(equal(direction))
                        }
                        
                        it("should not call the didCancelSwipe method") {
                            expect(subject.didCancelSwipeCalled).to(beFalse())
                        }
                    }
                    
                    context("and the swipe speed is less than the minimum swipe speed") {
                        beforeEach {
                            let direction: SwipeDirection = .left
                            let velocity: CGPoint = CGPoint(x: direction.vector.dx * (minimumSwipeSpeed - 1),
                                                            y: direction.vector.dy * (minimumSwipeSpeed - 1))
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: CGPoint(direction.vector),
                                                                velocity: velocity)
                            subject.endSwiping(testPanGestureRecognizer)
                        }
                        
                        it("should call the didCancelSwipe method and not the didSwipe method") {
                            expect(subject.didCancelSwipeCalled).to(beTrue())
                            expect(subject.didSwipeCalled).to(beFalse())
                        }
                    }
                    
                    context("and the swipe speed is at least the minimum swipe speed") {
                        let direction: SwipeDirection = .left
                        
                        beforeEach {
                            let velocity: CGPoint = CGPoint(x: direction.vector.dx * minimumSwipeSpeed,
                                                            y: direction.vector.dy * minimumSwipeSpeed)
                            testPanGestureRecognizer.performPan(withLocation: nil,
                                                                translation: CGPoint(direction.vector),
                                                                velocity: velocity)
                            subject.endSwiping(testPanGestureRecognizer)
                        }
                        
                        it("should call the didSwipe method with the correct direction") {
                            expect(subject.didSwipeCalled).to(beTrue())
                            expect(subject.didSwipeDirection).to(equal(direction))
                        }
                        
                        it("should not call the didCancelSwipe delegate method") {
                            expect(subject.didCancelSwipeCalled).to(beFalse())
                        }
                    }
                }
            }
        }
    }
}
