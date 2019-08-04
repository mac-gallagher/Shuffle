//
//  MockSwipeCardStackDataSource.swift
//  ShuffleTests
//
//  Created by Mac Gallagher on 6/9/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Shuffle

class MockSwipeCardStackDataSource: SwipeCardStackDataSource {
    
    var numberOfCardsCalled: Bool = false
    var testNumberOfCards: Int = 0 {
        didSet {
            testCards.removeAll()
            for _ in 0..<testNumberOfCards {
                testCards.append(TestableSwipeCard())
            }
        }
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        numberOfCardsCalled = true
        return testNumberOfCards
    }
    
    var testCards: [TestableSwipeCard] = []
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        return testCards[index]
    }
    
    // MARK: - Test Helpers
    
    func resetDataSource() {
        numberOfCardsCalled = false
    }
}
