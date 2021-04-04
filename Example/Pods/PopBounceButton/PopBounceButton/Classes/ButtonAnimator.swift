//
//  ButtonAnimator.swift
//  PopBounceButton
//
//  Created by Mac Gallagher on 1/11/19.
//

import pop

protocol ButtonAnimatable {
    func applyScaleAnimation(to view: UIView, toValue: CGPoint, delay: TimeInterval, duration: TimeInterval)
    func applySpringScaleAnimation(to view: UIView,
                                   fromValue: CGPoint,
                                   toValue: CGPoint,
                                   springBounciness: CGFloat,
                                   springSpeed: CGFloat,
                                   initialVelocity: CGPoint,
                                   delay: TimeInterval)
}

class ButtonAnimator: ButtonAnimatable {
    func applyScaleAnimation(to view: UIView, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval) {
        guard let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY) else { return }
        scaleAnimation.duration = duration
        scaleAnimation.toValue = toValue
        scaleAnimation.beginTime = CACurrentMediaTime() + delay
        view.pop_add(scaleAnimation, forKey: ButtonAnimator.scaleKey)
    }
    
    func applySpringScaleAnimation(to view: UIView,
                                   fromValue: CGPoint,
                                   toValue: CGPoint,
                                   springBounciness: CGFloat,
                                   springSpeed: CGFloat,
                                   initialVelocity: CGPoint,
                                   delay: TimeInterval = 0) {
        guard let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY) else { return }
        scaleAnimation.fromValue = fromValue
        scaleAnimation.toValue = toValue
        scaleAnimation.beginTime = CACurrentMediaTime() + delay
        scaleAnimation.springBounciness = springBounciness
        scaleAnimation.springSpeed = springSpeed
        scaleAnimation.velocity = initialVelocity
        view.pop_add(scaleAnimation, forKey: ButtonAnimator.springScaleKey)
    }
}

extension ButtonAnimator {
    static var scaleKey = "POPScaleAnimation"
    static var springScaleKey = "springScaleAnimation"
}
