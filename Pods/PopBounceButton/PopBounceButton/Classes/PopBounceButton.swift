//
//  PopBounceButton.swift
//  PopBounceButton
//
//  Created by Mac Gallagher on 5/25/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

open class PopBounceButton: UIButton {
    ///The effective bounciness of the spring animation. Higher values increase spring movement range resulting in more oscillations and springiness. Defined as a value in the range [0, 20]. Defaults to 19.
    public var springBounciness: CGFloat = 19

    ///The effective speed of the spring animation. Higher values increase the dampening power of the spring. Defined as a value in the range [0, 20]. Defaults to 10.
    public var springSpeed: CGFloat = 10
    
    ///The initial velocity of the spring animation. Higher values increase the percieved force from the user's touch. Expressed in scale factor per second. Defaults to 6.
    public var springVelocity: CGFloat = 6
    
    ///The total duration of the scale animation performed after a touchUpOutside event is recognized. Expressed in seconds. Defaults to 0.3.
    public var cancelTapScaleDuration: TimeInterval = 0.3
    
    ///The factor by which to scale the button after a long-press has been recognized. Defaults to 0.7.
    public var longPressScaleFactor: CGFloat = 0.7
    
    ///The total duration of the scale animation performed after a long-press has been recognized. Expressed in seconds. Defaults to 0.1.
    public var longPressScaleDuration: TimeInterval = 0.1
    
    ///The minimum period fingers must press on the button for a long-press to be recognized. Expressed in seconds. Defaults to 0.2.
    public var minimumPressDuration: TimeInterval = 0.2
    
    var touchUpInsideScaledDelay: TimeInterval = 0.05
    
    var animator: ButtonAnimatable = ButtonAnimator()
    var longPressTimer: Timer = Timer()
    var isScaled: Bool = false
    
    private var initialBounds: CGSize = .zero
    
    public init() {
        super.init(frame: .zero)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(handleTouchUpOutside), for: .touchUpOutside)
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        initialBounds = rect.size
    }
    
    @objc private func handleTouchDown() {
        longPressTimer = Timer.scheduledTimer(timeInterval: minimumPressDuration,
                                              target: self,
                                              selector: #selector(handleScale),
                                              userInfo: nil,
                                              repeats: false)
    }
    
    @objc private func handleScale() {
        pop_removeAllAnimations()
        animator.applyScaleAnimation(to: self,
                                     toValue: CGPoint(c: longPressScaleFactor),
                                     delay: 0,
                                     duration: longPressScaleDuration)
        isScaled = true
    }
    
    @objc private func handleTouchUpInside() {
        pop_removeAllAnimations()
        let scaleFactor: CGFloat = min(frame.width / initialBounds.width, 1)
        animator.applySpringScaleAnimation(to: self,
                                              fromValue: CGPoint(c: scaleFactor - 0.01),
                                              toValue: .one,
                                              springBounciness: springBounciness,
                                              springSpeed: springSpeed,
                                              initialVelocity: isScaled ? .zero : CGPoint(c: -scaleFactor * springVelocity),
                                              delay: isScaled ? touchUpInsideScaledDelay : 0)
        longPressTimer.invalidate()
        isScaled = false
    }
    
    @objc private func handleTouchUpOutside() {
        pop_removeAllAnimations()
        animator.applyScaleAnimation(to: self,
                                     toValue: .one,
                                     delay: 0,
                                     duration: cancelTapScaleDuration)
        longPressTimer.invalidate()
        isScaled = false
    }
}

extension CGPoint {
    static var one = CGPoint(x: 1, y: 1)
    
    init(c: CGFloat) {
        self.init()
        self.x = c
        self.y = c
    }
}
