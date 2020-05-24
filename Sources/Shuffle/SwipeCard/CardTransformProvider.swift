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

protocol CardTransformProvidable {
  func overlayPercentage(for card: SwipeCard, direction: SwipeDirection) -> CGFloat
  func rotationAngle(for card: SwipeCard) -> CGFloat
  func rotationDirectionY(for card: SwipeCard) -> CGFloat
  func transform(for card: SwipeCard) -> CGAffineTransform
}

class CardTransformProvider: CardTransformProvidable {

  static var shared = CardTransformProvider()

  func overlayPercentage(for card: SwipeCard, direction: SwipeDirection) -> CGFloat {
    if direction != card.activeDirection() { return 0 }
    let totalPercentage = card.swipeDirections.reduce(0) { sum, direction in
      return sum + card.dragPercentage(on: direction)
    }
    let actualPercentage = 2 * card.dragPercentage(on: direction) - totalPercentage
    return max(0, min(actualPercentage, 1))
  }

  func rotationAngle(for card: SwipeCard) -> CGFloat {
    let superviewTranslation = card.panGestureRecognizer.translation(in: card.superview)
    let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
    return rotationDirectionY(for: card)
      * rotationStrength
      * abs(card.animationOptions.maximumRotationAngle)
  }

  func rotationDirectionY(for card: SwipeCard) -> CGFloat {
    if let touchPoint = card.touchLocation {
      return (touchPoint.y < card.bounds.height / 2) ? 1 : -1
    }
    return 0
  }

  func transform(for card: SwipeCard) -> CGAffineTransform {
    let dragTranslation = card.panGestureRecognizer.translation(in: card)
    let translation = CGAffineTransform(translationX: dragTranslation.x,
                                        y: dragTranslation.y)
    let rotation = CGAffineTransform(rotationAngle: rotationAngle(for: card))
    return translation.concatenating(rotation)
  }
}
