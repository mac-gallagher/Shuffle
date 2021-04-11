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

protocol CardStackAnimatable {
  func animateReset(_ cardStack: SwipeCardStack,
                    topCard: SwipeCard)
  func animateShift(_ cardStack: SwipeCardStack,
                    withDistance distance: Int,
                    animated: Bool,
                    completion: ((Bool) -> Void)?)
  func animateSwipe(_ cardStack: SwipeCardStack,
                    topCard: SwipeCard,
                    direction: SwipeDirection,
                    forced: Bool,
                    animated: Bool,
                    completion: ((Bool) -> Void)?)
  func animateUndo(_ cardStack: SwipeCardStack,
                   topCard: SwipeCard,
                   animated: Bool,
                   completion: ((Bool) -> Void)?)
  func removeAllCardAnimations(_ cardStack: SwipeCardStack)
  func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack)
}

/// The background card animator for the card stack.
///
/// All methods should be called only after the `CardStackManager` has been updated.
class CardStackAnimator: CardStackAnimatable {

  static let shared = CardStackAnimator()

  // MARK: - Main Methods

  func animateReset(_ cardStack: SwipeCardStack,
                    topCard: SwipeCard) {
    removeBackgroundCardAnimations(cardStack)

    let duration = cardStack.animationOptions.resetDuration ?? topCard.animationOptions.totalResetDuration / 2
    Animator.animateKeyFrames(
      withDuration: duration,
      options: .allowUserInteraction,
      animations: {
        for (position, card) in cardStack.backgroundCards.enumerated() {
          let transform = cardStack.transform(forCardAtPosition: position + 1)
          Animator.addTransformKeyFrame(to: card, transform: transform)
        }
      },
      completion: nil)
  }

  func animateShift(_ cardStack: SwipeCardStack,
                    withDistance distance: Int,
                    animated: Bool,
                    completion: ((Bool) -> Void)?) {
    removeAllCardAnimations(cardStack)

    if !animated {
      for (position, value) in cardStack.visibleCards.enumerated() {
        value.card.transform = cardStack.transform(forCardAtPosition: position)
      }
      completion?(true)
      return
    }

    // Place background cards in old positions
    for (position, value) in cardStack.visibleCards.enumerated() {
      value.card.transform = cardStack.transform(forCardAtPosition: position + distance)
    }

    // Animate background cards to new positions
    Animator.animateKeyFrames(
      withDuration: cardStack.animationOptions.shiftDuration,
      animations: {
        for (position, value) in cardStack.visibleCards.enumerated() {
          let transform = cardStack.transform(forCardAtPosition: position)
          Animator.addTransformKeyFrame(to: value.card, transform: transform)
        }
      },
      completion: completion)
  }

  func animateSwipe(_ cardStack: SwipeCardStack,
                    topCard: SwipeCard,
                    direction: SwipeDirection,
                    forced: Bool,
                    animated: Bool,
                    completion: ((Bool) -> Void)?) {
    removeBackgroundCardAnimations(cardStack)

    if !animated {
      for (position, value) in cardStack.visibleCards.enumerated() {
        cardStack.layoutCard(value.card, at: position)
      }
      completion?(true)
      return
    }

    let delay = swipeDelay(for: topCard, forced: forced)
    let duration = swipeDuration(cardStack,
                                 topCard: topCard,
                                 direction: direction,
                                 forced: forced)

    // No background cards left to animate, so we instead just delay calling the completion block
    if cardStack.visibleCards.isEmpty {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay + duration) {
        completion?(true)
      }
      return
    }

    Animator.animateKeyFrames(
      withDuration: duration,
      delay: delay,
      animations: {
        for (position, value) in cardStack.visibleCards.enumerated() {
          Animator.addKeyFrame {
            cardStack.layoutCard(value.card, at: position)
          }
        }
      },
      completion: completion)
  }

  func animateUndo(_ cardStack: SwipeCardStack,
                   topCard: SwipeCard,
                   animated: Bool,
                   completion: ((Bool) -> Void)?) {
    removeBackgroundCardAnimations(cardStack)

    if !animated {
      for (position, card) in cardStack.backgroundCards.enumerated() {
        cardStack.layoutCard(card, at: position + 1)
      }
      completion?(true)
      return
    }

    // Place background cards in old positions
    for (position, card) in cardStack.backgroundCards.enumerated() {
      card.transform = cardStack.transform(forCardAtPosition: position)
    }

    // Animate background cards to new positions
    let duration = cardStack.animationOptions.undoDuration ?? topCard.animationOptions.totalReverseSwipeDuration / 2
    Animator.animateKeyFrames(
      withDuration: duration,
      animations: {
        for (position, card) in cardStack.backgroundCards.enumerated() {
          Animator.addKeyFrame {
            cardStack.layoutCard(card, at: position + 1)
          }
        }
      },
      completion: completion)
  }

  func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack) {
    cardStack.backgroundCards.forEach { $0.removeAllAnimations() }
  }

  func removeAllCardAnimations(_ cardStack: SwipeCardStack) {
    cardStack.visibleCards.forEach { $0.card.removeAllAnimations() }
  }

  // MARK: - Animation Calculations

  func swipeDelay(for topCard: SwipeCard, forced: Bool) -> TimeInterval {
    let duration = topCard.animationOptions.totalSwipeDuration
    let relativeOverlayDuration = topCard.animationOptions.relativeSwipeOverlayFadeDuration
    let delay = duration * TimeInterval(relativeOverlayDuration)
    return forced ? delay : 0
  }

  func swipeDuration(_ cardStack: SwipeCardStack,
                     topCard: SwipeCard,
                     direction: SwipeDirection,
                     forced: Bool) -> TimeInterval {
    if let swipeDuration = cardStack.animationOptions.swipeDuration {
      return swipeDuration
    }

    if forced {
      return topCard.animationOptions.totalSwipeDuration / 2
    }

    let velocityFactor = topCard.dragSpeed(on: direction) / topCard.minimumSwipeSpeed(on: direction)

    // Card swiped below the minimum swipe speed
    if velocityFactor < 1.0 {
      return topCard.animationOptions.totalSwipeDuration / 2
    }

    // Card swiped at least the minimum swipe speed so return relative duration instead
    return 1.0 / (2.0 * TimeInterval(velocityFactor))
  }
}
