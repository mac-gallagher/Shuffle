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

protocol CardAnimatable {
  func animateReset(on card: SwipeCard)
  func animateReverseSwipe(on card: SwipeCard,
                           from direction: SwipeDirection,
                           completion: ((Bool) -> Void)?)
  func animateSwipe(on card: SwipeCard,
                    direction: SwipeDirection,
                    forced: Bool,
                    completion: ((Bool) -> Void)?)
  func removeAllAnimations(on card: SwipeCard)
}

class CardAnimator: CardAnimatable {

  static var shared = CardAnimator()

  // MARK: - Main Methods

  /// Calling this method triggers a spring-like animation on the card, eventually settling back to
  ///  it's original position.
  /// - Parameter card: The card to animate.
  func animateReset(on card: SwipeCard) {
    removeAllAnimations(on: card)

    Animator.animateSpring(
      withDuration: card.animationOptions.totalResetDuration,
      usingSpringWithDamping: card.animationOptions.resetSpringDamping,
      options: [.curveLinear, .allowUserInteraction]) {
      if let direction = card.activeDirection(),
         let overlay = card.overlay(forDirection: direction) {
        overlay.alpha = 0
      }
      card.transform = .identity
    }
  }

  /// Calling this method triggers a reverse swipe (i.e. undo) animation on the card.
  /// - Parameters:
  ///   - card: The card to animate.
  ///   - direction: The direction from which the card will be coming off-screen.
  ///   - completion: An optional block which is called once the animation has completed.
  func animateReverseSwipe(on card: SwipeCard,
                           from direction: SwipeDirection,
                           completion: ((Bool) -> Void)?) {
    removeAllAnimations(on: card)

    // Recreate swipe
    Animator.animateKeyFrames(withDuration: 0.0) { [weak self] in
      self?.addSwipeAnimationKeyFrames(card,
                                       direction: direction,
                                       forced: true)
    }

    // Reverse swipe
    Animator.animateKeyFrames(
      withDuration: card.animationOptions.totalReverseSwipeDuration,
      options: .calculationModeLinear,
      animations: { [weak self] in
        self?.addReverseSwipeAnimationKeyFrames(card, direction: direction)
      },
      completion: completion)
  }

  /// Calling this method triggers a swipe animation on the card.
  /// - Parameters:
  ///   - card: The card to animate.
  ///   - direction: The direction to which the card will swipe off-screen.
  ///   - forced: A boolean idicating whether the card was swiped programmatically
  ///   - completion: An optional block which is called once the animation has completed.
  func animateSwipe(on card: SwipeCard,
                    direction: SwipeDirection,
                    forced: Bool,
                    completion: ((Bool) -> Void)?) {
    removeAllAnimations(on: card)

    let duration = swipeDuration(card, direction: direction, forced: forced)
    Animator.animateKeyFrames(
      withDuration: duration,
      options: .calculationModeLinear,
      animations: { [weak self] in
        self?.addSwipeAnimationKeyFrames(card,
                                         direction: direction,
                                         forced: forced)
      },
      completion: completion)
  }

  /// Calling this method will remove any active animations on the card and its layers.
  /// - Parameter card: The card on which the animations will be removed.
  func removeAllAnimations(on card: SwipeCard) {
    card.layer.removeAllAnimations()
    card.swipeDirections.forEach {
      card.overlay(forDirection: $0)?.layer.removeAllAnimations()
    }
  }

  // MARK: - Animation Keyframes

  func addReverseSwipeAnimationKeyFrames(_ card: SwipeCard, direction: SwipeDirection) {
    let overlay = card.overlay(forDirection: direction)
    let relativeOverlayDuration = overlay != nil ? card.animationOptions.relativeReverseSwipeOverlayFadeDuration : 0.0

    // Transform
    Animator.addTransformKeyFrame(to: card,
                                  relativeDuration: 1 - relativeOverlayDuration,
                                  transform: .identity)

    // Overlays
    for swipeDirection in card.swipeDirections {
      card.overlay(forDirection: direction)?.alpha = swipeDirection == direction ? 1.0 : 0.0
    }

    Animator.addFadeKeyFrame(to: overlay,
                             withRelativeStartTime: 1 - relativeOverlayDuration,
                             relativeDuration: relativeOverlayDuration,
                             alpha: 0.0)
  }

  func addSwipeAnimationKeyFrames(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) {
    let overlay = card.overlay(forDirection: direction)

    // Overlays
    for swipeDirection in card.swipeDirections.filter({ $0 != direction }) {
      card.overlay(forDirection: swipeDirection)?.alpha = 0.0
    }

    let relativeOverlayDuration = (forced && overlay != nil)
      ? card.animationOptions.relativeSwipeOverlayFadeDuration
      : 0.0
    Animator.addFadeKeyFrame(to: overlay,
                             relativeDuration: relativeOverlayDuration,
                             alpha: 1.0)

    // Transform
    let transform = swipeTransform(card, direction: direction, forced: forced)
    Animator.addTransformKeyFrame(to: card,
                                  withRelativeStartTime: relativeOverlayDuration,
                                  relativeDuration: 1 - relativeOverlayDuration,
                                  transform: transform)
  }

  // MARK: - Animation Calculations

  func swipeDuration(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> TimeInterval {
    if forced {
      return card.animationOptions.totalSwipeDuration
    }

    let velocityFactor = card.dragSpeed(on: direction) / card.minimumSwipeSpeed(on: direction)

    // Card swiped below the minimum swipe speed
    if velocityFactor < 1.0 {
      return card.animationOptions.totalSwipeDuration
    }

    // Card swiped at least the minimum swipe speed -> return relative duration
    return 1.0 / TimeInterval(velocityFactor)
  }

  func swipeRotationAngle(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> CGFloat {
    if direction == .up || direction == .down { return 0.0 }

    let rotationDirectionY: CGFloat = direction == .left ? -1.0 : 1.0

    if forced {
      return 2 * rotationDirectionY * card.animationOptions.maximumRotationAngle
    }

    guard let touchPoint = card.touchLocation else {
      return 2 * rotationDirectionY * card.animationOptions.maximumRotationAngle
    }

    if (direction == .left && touchPoint.y < card.bounds.height / 2)
        || (direction == .right && touchPoint.y >= card.bounds.height / 2) {
      return -2 * card.animationOptions.maximumRotationAngle
    }

    return 2 * card.animationOptions.maximumRotationAngle
  }

  func swipeTransform(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> CGAffineTransform {
    let dragTranslation = CGVector(to: card.panGestureRecognizer.translation(in: card.superview))
    let normalizedDragTranslation = forced ? direction.vector : dragTranslation.normalized
    let actualTranslation = CGPoint(swipeTranslation(card,
                                                     direction: direction,
                                                     directionVector: normalizedDragTranslation))
    return CGAffineTransform(rotationAngle: swipeRotationAngle(card, direction: direction, forced: forced))
      .concatenating(CGAffineTransform(translationX: actualTranslation.x, y: actualTranslation.y))
  }

  func swipeTranslation(_ card: SwipeCard, direction: SwipeDirection, directionVector: CGVector) -> CGVector {
    let cardDiagonalLength = CGVector(card.bounds.size).length
    let maxScreenLength = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    let minimumOffscreenTranslation = CGVector(dx: maxScreenLength + cardDiagonalLength,
                                               dy: maxScreenLength + cardDiagonalLength)
    return CGVector(dx: directionVector.dx * minimumOffscreenTranslation.dx,
                    dy: directionVector.dy * minimumOffscreenTranslation.dy)
  }
}
