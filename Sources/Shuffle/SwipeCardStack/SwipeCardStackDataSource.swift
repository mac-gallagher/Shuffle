import Foundation

public protocol SwipeCardStackDataSource: class {
    func numberOfCards(in cardStack: SwipeCardStack) -> Int
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard
}
