import Quick
import Nimble

@testable import Shuffle

class CardStackStateManagerSpec: QuickSpec {
    
    override func spec() {
        describe("CardStackStateManager") {
            var subject: CardStackStateManager!
            
            beforeEach {
                subject = CardStackStateManager()
            }
            
            // MARK: - Initialization
            
            describe("Initialization") {
                context("When initializaing a CardStackStateManager object") {
                    it("should have the correct default properties") {
                        expect(subject.remainingIndices).to(beEmpty())
                        expect(subject.swipes).to(beEmpty())
                    }
                }
            }
            
            // MARK: - Swipe
            
            describe("Swipe") {
                context("When calling the swipe method") {
                    let direction: SwipeDirection = .left
                    
                    context("and there are no remaining indices") {
                        beforeEach {
                            subject.remainingIndices = []
                            subject.swipe(direction)
                        }
                        
                        it("should not add a new swipe to swipes") {
                            expect(subject.swipes).to(beEmpty())
                        }
                    }
                    
                    context("and there is at least one remaining index") {
                        let remainingIndices: [Int] = [0, 1, 2]
                        
                        beforeEach {
                            subject.remainingIndices = remainingIndices
                            subject.swipe(direction)
                        }
                        
                        it("should remove the first index of remainingIndices") {
                            expect(subject.remainingIndices).to(equal(Array(remainingIndices.dropFirst())))
                        }
                    }
                }
            }
            
            // MARK: - Undo Swipe
            
            describe("Undo Swipe") {
                context("When calling the undoSwipe method") {
                    let remainingIndices = [0, 1, 2]
                    var actualSwipe: Swipe?
                    
                    context("and there are no swipes") {
                        beforeEach {
                            subject.remainingIndices = remainingIndices
                            subject.swipes = []
                            actualSwipe = subject.undoSwipe()
                        }
                        
                        it("should return nil") {
                            expect(actualSwipe).to(beNil())
                        }
                        
                        it("should not update the remaining indices") {
                            expect(subject.remainingIndices).to(equal(remainingIndices))
                        }
                    }
                    
                    context("and there is at least one swipe") {
                        let swipe = Swipe(5, .left)
                        
                        beforeEach {
                            subject.swipes = [swipe]
                            subject.remainingIndices = remainingIndices
                            actualSwipe = subject.undoSwipe()
                        }
                        
                        it("should return the correct swipe") {
                            expect(actualSwipe?.index).to(equal(swipe.index))
                            expect(actualSwipe?.direction).to(equal(swipe.direction))
                        }
                        
                        it("should add the swiped index to remaining indices") {
                            let expectedRemainingIndices =  [swipe.index] + remainingIndices
                            expect(subject.remainingIndices).to(equal(expectedRemainingIndices))
                        }
                    }
                }
            }
            
            // MARK: - Shift
            
            describe("Shift") {
                context("When calling the shift method") {
                    let remainingIndices = [0, 1, 2, 3]
                    
                    beforeEach {
                        subject.remainingIndices = remainingIndices
                        subject.shift(withDistance: 2)
                    }
                    
                    it("it should correctly shift the remaining indices") {
                        let expectedRemainingIndices: [Int] = [2, 3, 0, 1]
                        expect(subject.remainingIndices).to(equal(expectedRemainingIndices))
                    }
                }
            }
            
            // MARK: - Reset
            
            describe("Reset") {
                context("When calling the reset method") {
                    let numberOfCards: Int = 4
                    
                    beforeEach {
                        subject.remainingIndices = [2, 3, 4]
                        subject.swipes = [Swipe(0, .left), Swipe(1, .up)]
                        subject.reset(withNumberOfCards: numberOfCards)
                    }
                    
                    it("should correctly reset the remaining indices and swipes") {
                        expect(subject.remainingIndices).to(equal(Array(0..<numberOfCards)))
                        expect(subject.swipes).to(beEmpty())
                    }
                }
            }
        }
    }
}
