import Foundation

public protocol CardStackAnimatableOptions {
    var shiftDuration: TimeInterval { get }
    var swipeDuration: TimeInterval? { get }
    var undoDuration: TimeInterval? { get }
    var resetDuration: TimeInterval? { get }
}

/// The animation options provided to the internal card stack animator.
public final class CardStackAnimationOptions: CardStackAnimatableOptions {
    
    /// The static default instance of `CardStackAnimationOptions`.
    static let `default` = CardStackAnimationOptions()
    
    /// The duration of the card stack shift animation.
    ///
    /// This value must be greater than zero. Defaults to `0.1`.
    public let shiftDuration: TimeInterval
    
    /// The duration of the animation applied to the background cards after a swipe
    /// has been recognized on the top card.
    ///
    /// If this value is `nil`, the animation will last exactly half the duration of
    /// `animationOptions.totalSwipeDuration` on the top card. This value must be greater than zero.
    /// Defaults to `nil`.
    public let swipeDuration: TimeInterval?
    
    /// The duration of the animation applied to the background cards after an `undo`
    /// has been triggered.
    ///
    /// If this value is `nil`, the animation will last exactly half the duration of
    /// `animationOptions.totalReverseSwipeDuration` on the top card. This value must be greater than zero.
    /// Defaults to `nil`.
    public let undoDuration: TimeInterval?
    
    /// The duration of the animation applied to the background cards after a canceled
    /// swipe has been recognized on the top card.
    ///
    /// If this value is `nil`, the animation will last exactly half the duration of
    /// `animationOptions.resetDuration` on the top card. This value must be greater than zero.
    /// Defaults to `nil`.
    public let resetDuration: TimeInterval?
    
    public init(shiftDuration: TimeInterval = 0.1,
                swipeDuration: TimeInterval? = nil,
                undoDuration: TimeInterval? = nil,
                resetDuration: TimeInterval? = nil) {
        self.shiftDuration = max(0, shiftDuration)
        if let swipeDuration = swipeDuration {
            self.swipeDuration = max(0, swipeDuration)
        } else {
            self.swipeDuration = nil
        }
        
        if let undoDuration = undoDuration {
            self.undoDuration = max(0, undoDuration)
        } else {
            self.undoDuration = nil
        }
        
        if let resetDuration = resetDuration {
            self.resetDuration = max(0, resetDuration)
        } else {
            self.resetDuration = nil
        }
    }
}
