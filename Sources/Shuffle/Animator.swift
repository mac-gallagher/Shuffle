import UIKit

/// A base animator class with testable helper methods.
open class Animator {
    public class func addKeyFrame(withRelativeStartTime relativeStartTime: Double = 0.0,
                                  relativeDuration: Double = 1.0,
                                  animations: @escaping () -> Void) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                           relativeDuration: relativeDuration,
                           animations: animations)
    }
    
    public class func addFadeKeyFrame(to view: UIView?,
                                      withRelativeStartTime relativeStartTime: Double = 0.0,
                                      relativeDuration: Double = 1.0,
                                      alpha: CGFloat) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                           relativeDuration: relativeDuration) {
                            view?.alpha = alpha
        }
    }
    
    public class func addTransformKeyFrame(to view: UIView?,
                                           withRelativeStartTime relativeStartTime: Double = 0.0,
                                           relativeDuration: Double = 1.0,
                                           transform: CGAffineTransform) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                           relativeDuration: relativeDuration) {
                            view?.transform = transform
        }
    }
    
    public class func animateKeyFrames(withDuration duration: TimeInterval,
                                       delay: TimeInterval = 0.0,
                                       options: UIView.KeyframeAnimationOptions = [],
                                       animations:  @escaping (() -> Void),
                                       completion: ((Bool) -> Void)?) {
        UIView.animateKeyframes(withDuration: duration,
                                delay: delay,
                                options: options,
                                animations: animations,
                                completion: completion)
    }
    
    public class func animateSpring(withDuration duration: TimeInterval,
                                    delay: TimeInterval = 0.0,
                                    usingSpringWithDamping damping: CGFloat,
                                    initialSpringVelocity: CGFloat = 0.0,
                                    options: UIView.AnimationOptions,
                                    animations: @escaping () -> Void,
                                    completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: initialSpringVelocity,
                       options: options,
                       animations: animations,
                       completion: completion)
    }
}
