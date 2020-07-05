///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

import UIKit

protocol CardStackTransformProvidable {
  func backgroundCardDragTransform(for cardStack: SwipeCardStack,
                                   topCard: SwipeCard,
                                   currentPosition: Int) -> CGAffineTransform
  func backgroundCardTransformPercentage(for cardStack: SwipeCardStack, topCard: SwipeCard) -> CGFloat
}

class CardStackTransformProvider: CardStackTransformProvidable {

  static let shared = CardStackTransformProvider()

  func backgroundCardDragTransform(for cardStack: SwipeCardStack,
                                   topCard: SwipeCard,
                                   currentPosition: Int) -> CGAffineTransform {
    let percentage = backgroundCardTransformPercentage(for: cardStack, topCard: topCard)

    let currentScale = cardStack.scaleFactor(forCardAtPosition: currentPosition)
    let nextScale = cardStack.scaleFactor(forCardAtPosition: currentPosition - 1)

    let scaleX = (1 - percentage) * currentScale.x + percentage * nextScale.x
    let scaleY = (1 - percentage) * currentScale.y + percentage * nextScale.y

    return CGAffineTransform(scaleX: scaleX, y: scaleY)
  }

  func backgroundCardTransformPercentage(for cardStack: SwipeCardStack, topCard: SwipeCard) -> CGFloat {
    let panTranslation = topCard.panGestureRecognizer.translation(in: cardStack)
    let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
    return max(min(2 * abs(panTranslation.x) / minimumSideLength, 1),
               min(2 * abs(panTranslation.y) / minimumSideLength, 1))
  }
}
