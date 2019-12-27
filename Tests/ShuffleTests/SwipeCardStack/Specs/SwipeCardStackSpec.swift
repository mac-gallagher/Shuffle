import Quick
import Nimble

@testable import Shuffle

class SwipeCardStackSpec: QuickSpec {
    
    override func spec() {
        delegateSpec()
        
        describe("SwipeCardStack") {
            let mockLayoutProvider = MockCardStackLayoutProvider.self
            let mockAnimator = MockCardStackAnimator.self
            let mockTransformProvider = MockCardStackTransformProvider.self
            
            var subject: TestableSwipeCardStack!
            var mockDelegate: MockSwipeCardStackDelegate!
            
            beforeEach {
                mockDelegate = MockSwipeCardStackDelegate()
                
                subject = TestableSwipeCardStack(animator: mockAnimator,
                                                 transformProvider: mockTransformProvider,
                                                 layoutProvider: mockLayoutProvider,
                                                 notificationCenter: TestableNotificationCenter())
                subject.delegate = mockDelegate
            }
            
            // MARK: - Initialization
            
            describe("Initialization") {
                var cardStack: SwipeCardStack!
                
                context("When initializing a SwipeCard with the default initializer") {
                    beforeEach {
                        cardStack = SwipeCardStack()
                    }
                    
                    it("should have the correct default properties") {
                        testDefaultProperties()
                    }
                }
                
                context("When initializing a SwipeCard with the required initializer") {
                    beforeEach {
                        // TODO: - Find a non-deprecated way to accomplish this
                        let coder = NSKeyedUnarchiver(forReadingWith: Data())
                        cardStack = SwipeCardStack(coder: coder)
                    }
                    
                    it("should have the correct default properties") {
                        testDefaultProperties()
                    }
                }
                
                func testDefaultProperties() {
                    expect(cardStack.numberOfVisibleCards).to(equal(2))
                    expect(cardStack.animationOptions).to(be(CardStackAnimationOptions.default))
                    
                    let expectedInsets = UIEdgeInsets(top: 10, left: 10,
                                                      bottom: 10, right: 10)
                    expect(cardStack.cardStackInsets).to(equal(expectedInsets))
                    
                    expect(cardStack.delegate).to(beNil())
                    expect(cardStack.dataSource).to(beNil())
                    expect(cardStack.topCardIndex).to(equal(0))
                    
                    expect(cardStack.topCard).to(beNil())
                    expect(cardStack.visibleCards).to(equal([]))
                    expect(cardStack.backgroundCards).to(equal([]))
                    expect(cardStack.currentState).to(equal(.emptyState))
                    
                    expect(cardStack.subviews.count).to(equal(1))
                }
            }
            
            // MARK: - Variables
            
            // MARK: Data Source
            
            describe("Data Source") {
                context("When setting the dataSource variable") {
                    beforeEach {
                        subject.dataSource = nil
                    }
                    
                    it("should call reloadData") {
                        expect(subject.reloadDataCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: Number Of Visible Cards
            
            describe("Number Of Visible Cards") {
                context("When setting the numberOfVisibleCards variable") {
                    beforeEach {
                        subject.numberOfVisibleCards = 0
                    }
                    
                    it("should call reloadData") {
                        expect(subject.reloadDataCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: Insets
            
            describe("Card Stack Insets") {
                context("When setting the cardStackInsets variable") {
                    beforeEach {
                        subject.cardStackInsets = .zero
                    }
                    
                    it("should trigger a new layout cycle") {
                        expect(subject.setNeedsLayoutCalled).to(beTrue())
                    }
                }
            }
            
            // MARK: Top Card Index
            
            describe("Top Card Index") {
                context("When accessing the topCardIndex variable") {
                    context("and the currentState has no remaining indices") {
                        beforeEach {
                            subject.currentState = CardStackState(remainingIndices: [])
                        }
                        
                        it("should return zero") {
                            expect(subject.topCardIndex).to(equal(0))
                        }
                    }
                    
                    context("and the currentState has at least one remaining index") {
                        let numberOfCards: Int = 10
                        let firstIndex: Int = 2
                        
                        beforeEach {
                            let indices = Array(firstIndex..<numberOfCards)
                            subject.currentState = CardStackState(remainingIndices: indices)
                        }
                        
                        it("should the first index of the current state") {
                            expect(subject.topCardIndex).to(equal(firstIndex))
                        }
                    }
                }
            }
            
            // MARK: Top Card
            
            describe("Top Card") {
                context("When accessing the topCard variable") {
                    context("and there are no visible cards") {
                        beforeEach {
                            subject.visibleCards = []
                        }
                        
                        it("should return nil") {
                            expect(subject.topCard).to(beNil())
                        }
                    }
                    
                    context("and there is at least one visible card") {
                        let firstCard = SwipeCard()
                        
                        beforeEach {
                            subject.visibleCards = [firstCard, SwipeCard(), SwipeCard()]
                        }
                        
                        it("should return the first visible card") {
                            expect(subject.topCard).to(equal(firstCard))
                        }
                    }
                }
            }
            
            // MARK: Background Cards
            
            describe("Background Cards") {
                context("When accessing the backgroundCards variable") {
                    let visibleCards = [SwipeCard(), SwipeCard(), SwipeCard()]
                    
                    beforeEach {
                        subject.visibleCards = visibleCards
                    }
                    
                    it("should return the visible cards expect the first card") {
                        let expectedCards = Array(visibleCards.dropFirst())
                        expect(subject.backgroundCards).to(equal(expectedCards))
                    }
                }
            }
            
            // MARK: Is Enabled
            
            describe("isEnabled") {
                for enabled in [false, true] {
                    context("When accessing the isEnabled variable") {
                        beforeEach {
                            subject.isUserInteractionEnabled = enabled
                        }
                        
                        context("and there is no top card") {
                            beforeEach {
                                subject.testTopCard = nil
                            }
                            
                            it("should return isUserInteractionEnabled") {
                                expect(subject.isEnabled).to(equal(enabled))
                            }
                        }
                        
                        context("and there is a top card") {
                            let topCard = SwipeCard()
                            
                            beforeEach {
                                subject.testTopCard = topCard
                            }
                            
                            context("and the card's user interaction is false") {
                                beforeEach {
                                    topCard.isUserInteractionEnabled = false
                                }
                                
                                it("should return false") {
                                    expect(subject.isEnabled).to(beFalse())
                                }
                            }
                            
                            context("and the card's user interaction is true") {
                                beforeEach {
                                    topCard.isUserInteractionEnabled = true
                                }
                                
                                it("should return isUserInteractionEnabled") {
                                    expect(subject.isEnabled).to(equal(enabled))
                                }
                            }
                        }
                    }
                }
            }
            
            // MARK: - Completion Blocks
            
            // MARK: Swipe Completion
            
            describe("Swipe Completion") {
                context("When the swipe completion is called") {
                    beforeEach {
                        subject.isUserInteractionEnabled = false
                        subject.swipeCompletion()
                    }
                    
                    it("should enabled user interaction on the card stack") {
                        expect(subject.isUserInteractionEnabled).to(beTrue())
                    }
                }
            }
            
            // MARK: Undo Completion
            
            describe("Undo Completion") {
                context("When the undo completion is called") {
                    beforeEach {
                        subject.isUserInteractionEnabled = false
                        subject.undoCompletion()
                    }
                    
                    it("should enabled user interaction on the card stack") {
                        expect(subject.isUserInteractionEnabled).to(beTrue())
                    }
                }
            }
            
            // MARK: Shift Completion
            
            describe("Swipe Completion") {
                context("When the shift completion is called") {
                    beforeEach {
                        subject.isUserInteractionEnabled = false
                        subject.shiftCompletion()
                    }
                    
                    it("should enabled user interaction on the card stack") {
                        expect(subject.isUserInteractionEnabled).to(beTrue())
                    }
                }
            }
            
            // MARK: - Layout
            
            // MARK: Layout Subviews
            
            describe("Layout Subviews") {
                context("When calling layoutSubviews") {
                    let cardContainerFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
                    let numberOfCards: Int = 3
                    let visibleCards: [SwipeCard] = {
                        var cards = [SwipeCard]()
                        for i in 0..<numberOfCards {
                            cards.append(SwipeCard())
                        }
                        return cards
                    }()
                    
                    beforeEach {
                        mockLayoutProvider.testCardContainerFrame = cardContainerFrame
                        subject.visibleCards = visibleCards
                        subject.layoutSubviews()
                    }
                    
                    afterEach {
                        mockLayoutProvider.reset()
                    }
                    
                    it("should correctly layout the card container") {
                        let cardContainer = subject.subviews.first
                        expect(cardContainer?.frame).to(equal(cardContainerFrame))
                    }
                    
                    it("should call layoutCard for each card") {
                        expect(subject.layoutCardCalled).to(beTrue())
                        expect(subject.layoutCardIndices).to(equal(Array(0..<numberOfCards)))
                        expect(subject.visibleCards).to(equal(visibleCards))
                    }
                }
            }
            
            // MARK - Layout Card
            
            describe("Layout Card") {
                context("When calling layoutCard") {
                    let cardFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
                    let cardTransform = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
                    let card = SwipeCard()
                    
                    let transformedFrame: CGRect = {
                        let tempView = UIView(frame: cardFrame)
                        tempView.transform = cardTransform
                        return tempView.frame
                    }()
                    
                    beforeEach {
                        mockLayoutProvider.testCardFrame = cardFrame
                    }
                    
                    context("and index is zero") {
                        let index = 0
                        
                        beforeEach {
                            subject.testTransformForCard = cardTransform
                            subject.layoutCard(card, at: index)
                        }
                        
                        testLayoutCard(index: index)
                    }
                    
                    context("and index is greater than zero") {
                        let index = 1
                        
                        beforeEach {
                            subject.testTransformForCard = cardTransform
                            subject.layoutCard(card, at: index)
                        }
                        
                        testLayoutCard(index: index)
                    }
                    
                    func testLayoutCard(index: Int) {
                        it("should correctly layout the card and disable user interaction") {
                            expect(card.frame).to(equal(transformedFrame))
                            expect(card.transform).to(equal(cardTransform))
                            expect(card.isUserInteractionEnabled).to(equal(index == 0))
                        }
                    }
                }
            }
            
            // MARK: Scale Factor For Card
            describe("Scale Factor For Card") {
                context("When calling the scaleFactor method") {
                    context("and the index is equal to zero") {
                        it("should return a 100% scale") {
                            let expectedScaleFactor = CGPoint(x: 1.0, y: 1.0)
                            let actualScaleFactor = subject.scaleFactor(forCardAtIndex: 0)
                            expect(actualScaleFactor).to(equal(expectedScaleFactor))
                        }
                    }
                    
                    context("and the index is greater than zero") {
                        it("should return a 95% scale") {
                            let actualScaleFactor = subject.scaleFactor(forCardAtIndex: 1)
                            let expectedScaleFactor = CGPoint(x: 0.95, y: 0.95)
                            expect(actualScaleFactor).to(equal(expectedScaleFactor))
                        }
                    }
                }
            }
            
            // MARK: Transform For Card
            
            describe("Transform For Card") {
                context("When calling transformForCard") {
                    let scaleFactor = CGPoint(x: 0.4, y: 0.7)
                    
                    beforeEach {
                        subject.testScaleFactor = scaleFactor
                    }
                    
                    it("should return the identity transform") {
                        let actualTransform = subject.transform(forCardAtIndex: 0)
                        let expectedTransform = CGAffineTransform(scaleX: scaleFactor.x,
                                                                  y: scaleFactor.y)
                        expect(actualTransform).to(equal(expectedTransform))
                    }
                }
            }
            
            // MARK: - Main Methods
            
            // MARK: Swipe
            
            describe("Swipe") {
                context("When calling the swipe method") {
                    let direction: SwipeDirection = .left
                    let animated: Bool = false
                    
                    var topCard: TestableSwipeCard!
                    
                    beforeEach {
                        topCard = TestableSwipeCard()
                        subject.testTopCard = topCard
                    }
                    
                    context("and isEnabled is false") {
                        beforeEach {
                            subject.testIsEnabled = false
                            subject.swipe(direction, animated: animated)
                        }
                        
                        it("should not call the top card's swipe method") {
                            expect(topCard.swipeCalled).to(beFalse())
                        }
                    }
                    
                    context("and isEnabled is true") {
                        beforeEach {
                            subject.testIsEnabled = true
                            subject.swipe(direction, animated: animated)
                        }
                        
                        it("should call the top card's swipe method with the correct parameters") {
                            expect(topCard.swipeCalled).to(beTrue())
                            expect(topCard.swipeAnimated).to(equal(animated))
                            expect(topCard.swipeDirection).to(equal(direction))
                        }
                    }
                }
            }
            
            // MARK: Undo Last Swipe
            
            describe("Undo Last Swipe") {
                context("When the undoLastSwipe method is called") {
                    var topCard: TestableSwipeCard!
                    
                    beforeEach {
                        topCard = TestableSwipeCard()
                        subject.testTopCard = topCard
                    }
                    
                    context("and isEnabled is false") {
                        beforeEach {
                            subject.testIsEnabled = false
                            subject.undoLastSwipe(animated: false)
                        }
                        
                        it("should not trigger an undo action") {
                            testNoUndoAction()
                        }
                    }
                    
                    context("and isEnabled is true") {
                        beforeEach {
                            subject.testIsEnabled = true
                        }
                        
                        context("and the current state has no previous state/swipe") {
                            beforeEach {
                                subject.undoLastSwipe(animated: false)
                            }
                            
                            it("should not trigger an undo action") {
                                testNoUndoAction()
                            }
                        }
                        
                        context("and the current state has a previous state/swipe") {
                            let previousState = CardStackState(remainingIndices: [])
                            let direction: SwipeDirection = .left
                            let animated: Bool = false
                            let index: Int = 5
                            
                            beforeEach {
                                let previousSwipe = Swipe(index, direction)
                                let currentState = CardStackState(remainingIndices: [],
                                                                  previousSwipe: previousSwipe,
                                                                  previousState: previousState)
                                subject.currentState = currentState
                                subject.undoLastSwipe(animated: animated)
                            }
                            
                            it("should call the didUndoCardAt delegate method with the correct parameters") {
                                expect(mockDelegate.didUndoCardAtCalled).to(beTrue())
                                expect(mockDelegate.didUndoCardAtIndex).to(equal(index))
                                expect(mockDelegate.didUndoCardAtDirection).to(equal(direction))
                            }
                            
                            it("should not call loadState method with the previous state") {
                                expect(subject.loadStateCalled).to(beTrue())
                                expect(subject.loadStateState).to(equal(previousState))
                            }
                            
                            it("should call the reverseSwipe method on the new topCard with the correct parameters") {
                                expect(topCard.reverseSwipeCalled).to(beTrue())
                                expect(topCard.reverseSwipeAnimated).to(equal(animated))
                                expect(topCard.reverseSwipeDirection).to(equal(direction))
                            }
                        }
                    }
                    
                    func testNoUndoAction() {
                        expect(mockDelegate.didUndoCardAtCalled).to(beFalse())
                        expect(subject.loadStateCalled).to(beFalse())
                        expect(topCard.reverseSwipeCalled).to(beFalse())
                    }
                }
            }
            
            // MARK: Shift
            
            describe("Shift") {
                context("When the shift method is called") {
                    context("and isEnabled is false") {
                        beforeEach {
                            subject.testIsEnabled = false
                            subject.shift(withDistance: 0, animated: false)
                        }
                        
                        it("should not trigger a shift action") {
                            testNoShiftAction()
                        }
                    }
                    
                    context("and isEnabled is true") {
                        beforeEach {
                            subject.testIsEnabled = true
                        }
                        
                        context("and distance is zero") {
                            beforeEach {
                                subject.shift(withDistance: 0, animated: false)
                            }
                            
                            it("should not trigger a shift action") {
                                testNoShiftAction()
                            }
                        }
                        
                        context("and the distance is greater than zero") {
                            context("and there are less than two visible cards") {
                                beforeEach {
                                    subject.visibleCards = [SwipeCard()]
                                    subject.shift(withDistance: 1, animated: false)
                                }
                                
                                it("should not trigger a shift action") {
                                    testNoShiftAction()
                                }
                            }
                        }
                        
                        context("and distance is greater than zero and there are at least two visible cards") {
                            let remainingIndices: [Int] = [0, 1, 2]
                            let previousSwipe = Swipe(0, .left)
                            let previousState: CardStackState = .emptyState
                            let distance: Int = 2
                            
                            var initialState: CardStackState!
                            
                            beforeEach {
                                initialState = CardStackState(remainingIndices: remainingIndices,
                                                              previousSwipe: previousSwipe,
                                                              previousState: previousState)
                                subject.isUserInteractionEnabled = false
                                subject.currentState = initialState
                                subject.visibleCards = [SwipeCard(), SwipeCard()]
                            }
                            
                            context("and animated is true") {
                                beforeEach {
                                    subject.shift(withDistance: distance, animated: true)
                                }
                                
                                afterEach {
                                    mockAnimator.reset()
                                }
                                
                                it("should call the loadState method with the correct state") {
                                    let expectedRemainingIndices = remainingIndices.shift(withDistance: distance)
                                    let expectedState = CardStackState(remainingIndices: expectedRemainingIndices,
                                                                       previousSwipe: previousSwipe,
                                                                       previousState: previousState)
                                    expect(subject.currentState).to(equal(expectedState))
                                }
                                
                                it("should disable user interaction and call the animator's shift method with the correct parameters") {
                                    expect(subject.isUserInteractionEnabled).to(beFalse())
                                    expect(mockAnimator.shiftCalled).to(beTrue())
                                    expect(mockAnimator.shiftDistance).to(equal(distance))
                                }
                            }
                            
                            context("and animated is false") {
                                beforeEach {
                                    subject.shift(withDistance: distance, animated: false)
                                }
                                
                                it("should call the loadState method with the correct state") {
                                    let expectedRemainingIndices = remainingIndices.shift(withDistance: distance)
                                    let expectedState = CardStackState(remainingIndices: expectedRemainingIndices,
                                                                       previousSwipe: previousSwipe,
                                                                       previousState: previousState)
                                    expect(subject.currentState).to(equal(expectedState))
                                }
                                
                                it("should not call the animator's shift method") {
                                    expect(mockAnimator.shiftCalled).to(beFalse())
                                }
                            }
                        }
                    }
                }
                
                func testNoShiftAction() {
                    expect(subject.loadStateCalled).to(beFalse())
                    expect(mockAnimator.shiftCalled).to(beFalse())
                }
            }
            
            // MARK: - Data Source
            
            // MARK: Reload Data
            
            describe("Reload Data") {
                context("When reloadData is called") {
                    context("and there is no dataSource") {
                        beforeEach {
                            subject.reloadData()
                        }
                        
                        it("should not call loadState") {
                            expect(subject.loadStateCalled).to(beFalse())
                        }
                    }
                    
                    context("and there is a dataSource") {
                        let numberOfCards: Int = 10
                        var mockDataSource: MockSwipeCardStackDataSource!
                        
                        beforeEach {
                            mockDataSource = MockSwipeCardStackDataSource()
                            mockDataSource.testNumberOfCards = numberOfCards
                            subject.dataSource = mockDataSource
                            subject.resetReloadData()
                            subject.reloadData()
                        }
                        
                        it("should retrieve the number of cards from the dataSource") {
                            expect(mockDataSource.numberOfCardsCalled).to(beTrue())
                        }
                        
                        it("should call loadState with the correct state") {
                            let initialState = CardStackState(remainingIndices: Array(0..<numberOfCards))
                            expect(subject.loadStateCalled).to(beTrue())
                            expect(subject.loadStateState).to(equal(initialState))
                        }
                    }
                }
            }
            
            // TODO: - Load State
            
            describe("Load State") {
                
            }
            
            // MARK: Insert Card
            
            describe("Insert Card") {
                context("When calling the insertCard method") {
                    let numberOfCards: Int = 5
                    let card = SwipeCard()
                    let index: Int = 3
                    
                    var cardContainer: UIView!
                    
                    beforeEach {
                        cardContainer = subject.subviews.first!
                        for _ in 0..<numberOfCards {
                            cardContainer.addSubview(SwipeCard())
                            subject.visibleCards.append(SwipeCard())
                        }
                        subject.insertCard(card, at: index)
                    }
                    
                    it("should insert the card at the correct level in the card container's view hierarchy") {
                        expect(cardContainer.subviews[numberOfCards - index]).to(equal(card))
                    }
                    
                    it("should call layoutCard with the correct parameters") {
                        expect(subject.layoutCardCalled).to(beTrue())
                        expect(subject.layoutCardIndices).to(equal([index]))
                        expect(subject.layoutCardCards).to(equal([card]))
                    }
                    
                    it("should insert the card at the correct index of the visibleCard variable") {
                        expect(subject.visibleCards[index]).to(equal(card))
                    }
                }
            }
            
            // MARK: Load Card
            
            describe("Load Card") {
                context("When calling the loadCard method") {
                    context("and there is no data source") {
                        it("should not return a card") {
                            let actualCard = subject.loadCard(at: 0)
                            expect(actualCard).to(beNil())
                        }
                    }
                    
                    context("and there is a data source") {
                        let numberOfCards: Int = 3
                        var dataSource: MockSwipeCardStackDataSource!
                        
                        beforeEach {
                            dataSource = MockSwipeCardStackDataSource()
                            dataSource.testNumberOfCards = numberOfCards
                            subject.dataSource = dataSource
                        }
                        
                        it("should return the correct card and set it's delegate") {
                            let index: Int = 0
                            
                            let actualCard = subject.loadCard(at: index)
                            expect(actualCard?.delegate).to(be(subject))
                            
                            let expectedCard = dataSource.testCards[index]
                            expect(actualCard).to(equal(expectedCard))
                        }
                    }
                }
            }
            
            // MARK: - Did Finish Swipe Animation
            
            describe("Did Finish Swipe Animation") {
                context("When calling the didFinishSwipeAnimation method") {
                    context("and the notification object is not a SwipeCard") {
                        beforeEach {
                            let notification = NSNotification(name: CardDidFinishSwipeAnimationNotification,
                                                              object: UIView())
                            subject.didFinishSwipeAnimation(notification)
                        }
                        
                        it("should do nothing!") {
                            //do nothing
                        }
                    }
                    
                    context("and the notification object is a SwipeCard") {
                        let swipeCard = SwipeCard()
                        
                        beforeEach {
                            let superview = UIView()
                            superview.addSubview(swipeCard)
                            
                            let notification = NSNotification(name: CardDidFinishSwipeAnimationNotification,
                                                              object: swipeCard)
                            subject.didFinishSwipeAnimation(notification)
                        }
                        
                        it("should remove the card from it's superview") {
                            expect(swipeCard.superview).to(beNil())
                        }
                    }
                }
            }
        }
    }
}
