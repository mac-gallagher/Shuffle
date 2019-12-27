import Quick
import Nimble

@testable import Shuffle

extension SwipeCardStackSpec {
    
    func delegateSpec() {
        describe("SwipeCardStack + SwipeCardDelegate") {
            let mockLayoutProvider = MockCardStackLayoutProvider.self
            let mockTransformProvider = MockCardStackTransformProvider.self
            let mockAnimator = MockCardStackAnimator.self
            
            var subject: TestableSwipeCardStack!
            var mockDelegate: MockSwipeCardStackDelegate!
            var testNotificationCenter = TestableNotificationCenter()
            
            beforeEach {
                mockDelegate = MockSwipeCardStackDelegate()
                
                subject = TestableSwipeCardStack(animator: mockAnimator,
                                                 transformProvider: mockTransformProvider,
                                                 layoutProvider: mockLayoutProvider,
                                                 notificationCenter: testNotificationCenter)
                subject.delegate = mockDelegate
            }
            
            // MARK: - Did Tap
            
            describe("Did Tap") {
                context("when the didTap method is called") {
                    let topIndex: Int = 4
                    
                    beforeEach {
                        subject.currentState = CardStackState(remainingIndices: [topIndex])
                        subject.card(didTap: SwipeCard())
                    }
                    
                    it("should call the cardStack's didSelectCard delegate method with the correct index") {
                        expect(mockDelegate.didSelectCardAtCalled).to(beTrue())
                        expect(mockDelegate.didSelectCardAtIndex).to(equal(topIndex))
                    }
                }
            }
            
            // MARK: - Begin Swipe
            
            describe("Begin Swipe") {
                context("When the beginSwipe method is called") {
                    beforeEach {
                        subject.card(didBeginSwipe: SwipeCard())
                    }
                    
                    afterEach {
                        mockAnimator.reset()
                    }
                    
                    it("should call the animator's removeBackgroundCardAnimation method") {
                        expect(mockAnimator.removeBackgroundCardAnimationsCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: - Continue Swipe

            describe("Continue Swipe") {
                context("When the didContinueSwipe method is called") {
                    var backgroundCards: [SwipeCard]!
                    let cardTransform = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
                    
                    beforeEach {
                        backgroundCards = [SwipeCard(), SwipeCard(), SwipeCard()]
                        subject.testBackgroundCards = backgroundCards
                    }

                    context("and there is no topCard") {
                        beforeEach {
                            subject.testTopCard = nil
                            mockTransformProvider.testBackgroundCardDragTransform = cardTransform
                            subject.card(didContinueSwipe: SwipeCard())
                        }
                        
                        afterEach {
                            mockTransformProvider.reset()
                        }
                        
                        it("should not set the transforms on any of the background cards") {
                            for card in backgroundCards {
                                expect(card.transform).toNot(equal(cardTransform))
                            }
                        }
                    }
                    
                    context("and there is a top card") {
                        beforeEach {
                            subject.testTopCard = SwipeCard()
                            mockTransformProvider.testBackgroundCardDragTransform = cardTransform
                            subject.card(didContinueSwipe: SwipeCard())
                        }
                        
                        afterEach {
                            mockTransformProvider.reset()
                        }
                        
                        it("should set the transforms on any of the background cards") {
                            for card in backgroundCards {
                                expect(card.transform).to(equal(cardTransform))
                            }
                        }
                    }
                }
            }
            
            // MARK: - Cancel Swipe
            
            describe("Cancel Swipe") {
                context("When the didCancelSwipe method is called") {
                    beforeEach {
                        subject.card(didCancelSwipe: SwipeCard())
                    }
                    
                    it("should call the animator's reset method") {
                        expect(mockAnimator.resetCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: - Swipe
            
            describe("Swipe") {
                context("When the didSwipe method is called") {
                    let direction: SwipeDirection = .left
                    let forced: Bool = false
                    let topCard = SwipeCard()
                    
                    context("and there is at least one more card to load") {
                        let testLoadCard = SwipeCard()
                        
                        beforeEach {
                            let currentState = CardStackState(remainingIndices: [0, 1])
                            subject.currentState = currentState
                            subject.visibleCards = [topCard]
                            subject.testLoadCard = testLoadCard
                            subject.card(didSwipe: topCard, with: direction, forced: forced)
                        }
                        
                        testSwipe()
                        
                        it("should not call the didSwipeAllCards delegate method") {
                            expect(mockDelegate.didSwipeAllCardsCalled).to(beFalse())
                        }
                        
                        it("should load the card from the correct data source index") {
                            expect(subject.loadCardCalled).to(beTrue())
                            expect(subject.loadCardCalledIndex).to(equal(1))
                        }
                        
                        it("should insert the loaded card at the correct index in the card stack") {
                            expect(subject.insertCardCalled).to(beTrue())
                            expect(subject.insertCardCard).to(equal(testLoadCard))
                            expect(subject.insertCardIndex).to(equal(0))
                        }
                    }
                    
                    context("and there are no more cards to load") {
                        beforeEach {
                            let currentState = CardStackState(remainingIndices: [0, 1])
                            subject.currentState = currentState
                            subject.visibleCards = [topCard, SwipeCard()]
                            subject.card(didSwipe: topCard, with: direction, forced: forced)
                        }

                        testSwipe()

                        it("should not call the didSwipeAllCards delegate method") {
                            expect(mockDelegate.didSwipeAllCardsCalled).to(beFalse())
                        }

                        it("not load a new card") {
                            expect(subject.loadCardCalled).to(beFalse())
                        }
                    }
                    
                    context("and there are no more cards to swipe") {
                        beforeEach {
                            let currentState = CardStackState(remainingIndices: [])
                            subject.currentState = currentState
                            subject.visibleCards = [topCard]
                            subject.card(didSwipe: topCard, with: direction, forced: forced)
                        }

                        testSwipe()
                        
                        it("should call the didSwipeAllCards delegate method") {
                            expect(mockDelegate.didSwipeAllCardsCalled).to(beTrue())
                        }
                    }

                    func testSwipe() {
                        it("should call the didSwipeCardAt delegate method with the correct parameters") {
                            expect(mockDelegate.didSwipeCardAtCalled).to(beTrue())
                            expect(mockDelegate.didSwipeCardAtIndex).to(equal(0))
                            expect(mockDelegate.didSwipeCardAtDirection).to(equal(direction))
                        }

                        it("should call the updateSwipeState method with the correct direction") {
                            expect(subject.updateSwipeStateCalled).to(beTrue())
                            expect(subject.updateSwipeStateDirection).to(equal(direction))
                        }

                        it("should disable user interaction") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }

                        it("should call the animator's swipe method with the correct parameters") {
                            expect(mockAnimator.swipeCalled).to(beTrue())
                            expect(mockAnimator.swipeForced).to(equal(forced))
                            expect(mockAnimator.swipeTopCard).to(equal(topCard))
                            expect(mockAnimator.swipeDirection).to(equal(direction))
                        }
                    }
                }
            }
            
            // MARK: Update Swipe State
            
            describe("Update Swipe State") {
                context("When calling updateSwipeState") {
                    let direction: SwipeDirection = .left
                    let remainingIndices: [Int] = [100, 2, 10]
                    let currentState = CardStackState(remainingIndices: remainingIndices)
                    let visibleCards = [SwipeCard(), SwipeCard()]

                    beforeEach {
                        subject.currentState = currentState
                        subject.visibleCards = visibleCards
                        subject.updateSwipeState(direction: direction)
                    }

                    it("should remove the first visibleCard") {
                        let expectedVisibleCards = Array(visibleCards.dropFirst())
                        expect(subject.visibleCards).to(equal(expectedVisibleCards))
                    }

                    it("should correctly set the new current state") {
                        let expectedRemainingIndices = Array(remainingIndices.dropFirst())
                        let expectedCurrentState = CardStackState(remainingIndices: expectedRemainingIndices,
                                                                  previousSwipe: Swipe(remainingIndices[0], direction),
                                                                  previousState: currentState)
                        expect(subject.currentState).to(equal(expectedCurrentState))
                    }
                }
            }
            
            // MARK: - Reverse Swipe
            
            describe("Reverse Swipe") {
                context("When the didReverseSwipe method is called") {
                    beforeEach {
                        subject.card(didReverseSwipe: SwipeCard(), from: .left)
                    }
                    
                    it("should disable user interaction on the card") {
                        expect(subject.isUserInteractionEnabled).to(beFalse())
                    }
                    
                    it("should call the animator's undo method") {
                        expect(mockAnimator.undoCalled).to(beTrue())
                    }
                }
            }
        }
    }
}
