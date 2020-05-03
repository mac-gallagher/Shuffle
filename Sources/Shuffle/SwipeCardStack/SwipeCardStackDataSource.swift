import Foundation

public protocol SwipeCardStackDataSource: class {
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard
  func numberOfCards(in cardStack: SwipeCardStack) -> Int
}
