import UIKit

protocol CardAnimatable {
    static func swipe(_ card: SwipeCard, direction: SwipeDirection, forced: Bool)
    static func reverseSwipe(_ card: SwipeCard, from direction: SwipeDirection)
    static func reset(_ card: SwipeCard)
    static func removeAllAnimations(on card: SwipeCard)
}

class CardAnimator: Animator, CardAnimatable {
    
    // MARK: - Animation Key Frames
    
    typealias SwipeAnimationKeyFrames = (SwipeCard, SwipeDirection, Bool) -> Void
    
    typealias ReverseSwipeAnimationKeyFrames = (SwipeCard, SwipeDirection) -> Void
    
    typealias ResetAnimationBlock = (SwipeCard) -> Void
    
    class var swipeAnimationKeyFrames: SwipeAnimationKeyFrames {
        return { card, swipeDirection, forced in
            let relativeOverlayDuration
                = relativeSwipeOverlayFadeDuration(card, swipeDirection, forced)
            
            //overlays
            for direction in card.swipeDirections.filter({$0 != swipeDirection}) {
                card.overlays[direction]?.alpha = 0.0
            }
            
            let overlay = card.overlays[swipeDirection]
            addFadeKeyFrame(to: overlay,
                            relativeDuration: relativeOverlayDuration,
                            alpha: 1.0)
            
            //transform
            let transform = swipeTransform(card, swipeDirection, forced)
            addTransformKeyFrame(to: card,
                                 withRelativeStartTime: relativeOverlayDuration,
                                 relativeDuration: 1 - relativeOverlayDuration,
                                 transform: transform)
        }
    }
    
    class var reverseSwipeAnimationKeyFrames: ReverseSwipeAnimationKeyFrames {
        return { card, reverseSwipeDirection in
            let relativeOverlayDuration
                = relativeReverseSwipeOverlayFadeDuration(card, reverseSwipeDirection)
            
            for direction in card.swipeDirections {
                card.overlays[direction]?.alpha =
                    direction == reverseSwipeDirection ? 1.0 : 0.0
            }
            
            //transform
            addTransformKeyFrame(to: card,
                                 relativeDuration: 1 - relativeOverlayDuration,
                                 transform: .identity)
            
            //overlays
            let overlay = card.overlays[reverseSwipeDirection]
            addFadeKeyFrame(to: overlay,
                            withRelativeStartTime: 1 - relativeOverlayDuration,
                            relativeDuration: relativeOverlayDuration,
                            alpha: 0.0)
        }
    }
    
    class var resetAnimationBlock: ResetAnimationBlock {
        return { card in
            if let direction = card.activeDirection,
                let overlay = card.overlays[direction] {
                overlay.alpha = 0
            }
            card.transform = .identity
        }
    }
    
    // MARK: - Animation Calculations
    
    class var swipeDuration: (SwipeCard, SwipeDirection, Bool) -> TimeInterval {
        return { card, direction, forced in
            if forced {
                return card.animationOptions.totalSwipeDuration
            }
            
            let velocityFactor = card.dragSpeed(direction) / card.minimumSwipeSpeed(on: direction)
            
            //card swiped below the minimum swipe speed
            if velocityFactor < 1.0 {
                return card.animationOptions.totalSwipeDuration
            }
            
            //card swiped at least the minimum swipe speed -> return relative duration
            return 1.0 / TimeInterval(velocityFactor)
        }
    }
    
    class var relativeSwipeOverlayFadeDuration: (SwipeCard, SwipeDirection, Bool) -> Double {
        return { card, direction, forced in
            let overlay = card.overlay(forDirection: direction)
            if forced && overlay != nil {
                return card.animationOptions.relativeSwipeOverlayFadeDuration
            }
            return 0.0
        }
    }
    
    class var relativeReverseSwipeOverlayFadeDuration: (SwipeCard, SwipeDirection) -> Double {
        return { card, direction in
            let overlay = card.overlays[direction]
            if overlay != nil {
                return card.animationOptions.relativeReverseSwipeOverlayFadeDuration
            }
            return 0.0
        }
    }
    
    class var swipeTransform: (SwipeCard, SwipeDirection, Bool) -> CGAffineTransform {
        return { card, direction, forced in
            let dragTranslation = CGVector(to: card.panGestureRecognizer.translation(in: card.superview))
            let normalizedDragTranslation = forced ? direction.vector : dragTranslation.normalized
            let actualTranslation = CGPoint(swipeTranslation(card, direction, normalizedDragTranslation))
            return CGAffineTransform(rotationAngle: swipeRotationAngle(card, direction, forced))
                .concatenating(CGAffineTransform(translationX: actualTranslation.x, y: actualTranslation.y))
        }
    }
    
    class var swipeTranslation: (SwipeCard, SwipeDirection, CGVector) -> CGVector {
        return { card, direction, directionVector in
            let cardDiagonalLength = CGVector(card.bounds.size).length
            let maxScreenLength = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            let minimumOffscreenTranslation = CGVector(dx: maxScreenLength + cardDiagonalLength,
                                                       dy: maxScreenLength + cardDiagonalLength)
            return CGVector(dx: directionVector.dx * minimumOffscreenTranslation.dx,
                            dy: directionVector.dy * minimumOffscreenTranslation.dy)
        }
    }
    
    class var swipeRotationAngle: (SwipeCard, SwipeDirection, Bool) -> CGFloat {
        return { card, direction, forced in
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
    }
    
    // MARK: - Main Methods
    
    class func swipe(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) {
        removeAllAnimations(on: card)
        
        let duration = swipeDuration(card, direction, forced)
        animateKeyFrames(withDuration: duration,
                         options: .calculationModeLinear, animations: {
                            swipeAnimationKeyFrames(card, direction, forced)
        }) { finished in
            if finished {
                card.swipeCompletion()
            }
        }
    }
    
    class func reverseSwipe(_ card: SwipeCard, from direction: SwipeDirection) {
        removeAllAnimations(on: card)
        
        //recreate swipe
        animateKeyFrames(withDuration: 0.0,
                         animations: {
                            swipeAnimationKeyFrames(card, direction, true)
        }, completion: nil)
        
        //reverse swipe
        animateKeyFrames(withDuration: card.animationOptions.totalReverseSwipeDuration,
                         options: .calculationModeLinear,
                         animations: {
                            reverseSwipeAnimationKeyFrames(card, direction)
        }) { finished in
            if finished {
                card.reverseSwipeCompletion(direction)
            }
        }
    }
    
    class func reset(_ card: SwipeCard) {
        removeAllAnimations(on: card)
        
        animateSpring(withDuration: card.animationOptions.totalResetDuration,
                      usingSpringWithDamping: card.animationOptions.resetSpringDamping,
                      options: [.curveLinear, .allowUserInteraction],
                      animations: {
                        resetAnimationBlock(card)
        }, completion: nil)
    }
    
    class func removeAllAnimations(on card: SwipeCard) {
        card.layer.removeAllAnimations()
        for direction in card.swipeDirections {
            card.overlays[direction]?.layer.removeAllAnimations()
        }
    }
}
