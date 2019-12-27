import Foundation

protocol CardStackAnimatable {
    static func swipe(_ cardStack: SwipeCardStack,
                      topCard: SwipeCard,
                      direction: SwipeDirection,
                      forced: Bool)
    static func shift(_ cardStack: SwipeCardStack, withDistance distance: Int)
    static func reset(_ cardStack: SwipeCardStack, topCard: SwipeCard)
    static func undo(_ cardStack: SwipeCardStack, topCard: SwipeCard)
    static func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack)
    static func removeAllCardAnimations(_ cardStack: SwipeCardStack)
}


/// The background card animator for the card stack.
///
///All methods should be called only after the new `CardStackState` has been loaded.
class CardStackAnimator: Animator, CardStackAnimatable {
    
    // MARK: - Animation Key Frames
    
    class var swipeAnimationKeyFrames: (SwipeCardStack) -> Void {
        return { cardStack in
            for (index, card) in cardStack.visibleCards.enumerated() {
                addKeyFrame {
                    cardStack.layoutCard(card, at: index)
                }
            }
        }
    }
    
    class var shiftAnimationKeyFrames: (SwipeCardStack) -> Void {
        return { cardStack in
            for (index, card) in cardStack.visibleCards.enumerated() {
                let transform = cardStack.transform(forCardAtIndex: index)
                addTransformKeyFrame(to: card, transform: transform)
            }
        }
    }
    
    class var cancelSwipeAnimationKeyFrames: (SwipeCardStack) -> Void {
        return { cardStack in
            for (index, card) in cardStack.backgroundCards.enumerated() {
                let transform = cardStack.transform(forCardAtIndex: index + 1)
                addTransformKeyFrame(to: card, transform: transform)
            }
        }
    }
    
    class var undoAnimationKeyFrames: (SwipeCardStack) -> Void {
        return { cardStack in
            for (index, card) in cardStack.backgroundCards.enumerated() {
                addKeyFrame {
                    cardStack.layoutCard(card, at: index + 1)
                }
            }
        }
    }
    
    // MARK: - Animation Calculations
    
    class var swipeDelay: (SwipeCard, Bool) -> TimeInterval {
        return { topCard, forced in
            let duration = topCard.animationOptions.totalSwipeDuration
            let relativeOverlayDuration
                = topCard.animationOptions.relativeSwipeOverlayFadeDuration
            let delay = duration * TimeInterval(relativeOverlayDuration)
            return forced ? delay : 0
        }
    }
    
    class var swipeDuration: (SwipeCardStack, SwipeCard, SwipeDirection, Bool) -> TimeInterval {
        return { cardStack, topCard, direction, forced in
            if let swipeDuration = cardStack.animationOptions.swipeDuration {
                return swipeDuration
            }
            
            if forced {
                return topCard.animationOptions.totalSwipeDuration / 2
            }
            
            let velocityFactor = topCard.dragSpeed(direction) / topCard.minimumSwipeSpeed(on: direction)
            
            //card swiped below the minimum swipe speed
            if velocityFactor < 1.0 {
                return topCard.animationOptions.totalSwipeDuration / 2
            }
            
            //card swiped at least the minimum swipe speed -> return relative duration
            return 1.0 / (2.0 * TimeInterval(velocityFactor))
        }
    }
    
    class var undoDuration: (SwipeCardStack, SwipeCard) -> TimeInterval {
        return { cardStack, topCard in
            return cardStack.animationOptions.undoDuration
                ?? topCard.animationOptions.totalReverseSwipeDuration / 2
        }
    }
    
    class var resetDuration: (SwipeCardStack, SwipeCard) -> TimeInterval {
        return { cardStack, topCard  in
            return cardStack.animationOptions.resetDuration
                ??  topCard.animationOptions.totalResetDuration / 2
        }
    }
    
    class var shiftDuration: (SwipeCardStack) -> TimeInterval {
        return { cardStack in
            return cardStack.animationOptions.shiftDuration
        }
    }
    
    // MARK: - Main Methods
    
    class func swipe(_ cardStack: SwipeCardStack,
                     topCard: SwipeCard,
                     direction: SwipeDirection,
                     forced: Bool) {
        removeBackgroundCardAnimations(cardStack)
        
        let delay = swipeDelay(topCard, forced)
        let duration = swipeDuration(cardStack, topCard, direction, forced)
        
        //no background cards left to animate, so we instead delay calling the completion block
        if cardStack.visibleCards.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + duration) {
                cardStack.swipeCompletion()
            }
            return
        }
        
        animateKeyFrames(withDuration: duration,
                         delay: delay,
                         animations: {
                            swipeAnimationKeyFrames(cardStack)
        }) { finished in
            if finished {
                cardStack.swipeCompletion()
            }
        }
    }
    
    class func shift(_ cardStack: SwipeCardStack, withDistance distance: Int) {
        removeAllCardAnimations(cardStack)
        
        //place background cards in old positions
        for (index, card) in cardStack.visibleCards.enumerated() {
            card.transform = cardStack.transform(forCardAtIndex: index + distance)
        }
        
        //animate background cards to new positions
        animateKeyFrames(withDuration: shiftDuration(cardStack),
                         animations: {
                            shiftAnimationKeyFrames(cardStack)
        }) { finshed in
            if finshed {
                cardStack.shiftCompletion()
            }
        }
    }
    
    class func reset(_ cardStack: SwipeCardStack, topCard: SwipeCard) {
        removeBackgroundCardAnimations(cardStack)
        
        animateKeyFrames(withDuration: resetDuration(cardStack, topCard),
                         options: .allowUserInteraction,
                         animations: {
                            self.cancelSwipeAnimationKeyFrames(cardStack)
        }, completion: nil)
    }
    
    class func undo(_ cardStack: SwipeCardStack, topCard: SwipeCard) {
        removeBackgroundCardAnimations(cardStack)
        
        //place background cards in old positions
        for (index, card) in cardStack.backgroundCards.enumerated() {
            card.transform = cardStack.transform(forCardAtIndex: index)
        }
        
        //animate background cards to new positions
        animateKeyFrames(withDuration: undoDuration(cardStack, topCard),
                         animations: {
                            undoAnimationKeyFrames(cardStack)
        }) { finished in
            if finished {
                cardStack.undoCompletion()
            }
        }
    }
    
    class func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack) {
        for card in cardStack.backgroundCards {
            card.removeAllAnimations()
        }
    }
    
    class func removeAllCardAnimations(_ cardStack: SwipeCardStack) {
        for card in cardStack.visibleCards {
            card.removeAllAnimations()
        }
    }
}
