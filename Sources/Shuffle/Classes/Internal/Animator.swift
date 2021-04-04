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

/// A wrapper around the UIView animate methods.
enum Animator {

  static func addKeyFrame(withRelativeStartTime relativeStartTime: Double = 0.0,
                          relativeDuration: Double = 1.0,
                          animations: @escaping () -> Void) {
    UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                       relativeDuration: relativeDuration,
                       animations: animations)
  }

  static func addFadeKeyFrame(to view: UIView?,
                              withRelativeStartTime relativeStartTime: Double = 0.0,
                              relativeDuration: Double = 1.0,
                              alpha: CGFloat) {
    UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                       relativeDuration: relativeDuration) {
                        view?.alpha = alpha
    }
  }

  static func addTransformKeyFrame(to view: UIView?,
                                   withRelativeStartTime relativeStartTime: Double = 0.0,
                                   relativeDuration: Double = 1.0,
                                   transform: CGAffineTransform) {
    UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                       relativeDuration: relativeDuration) {
                        view?.transform = transform
    }
  }

  static func animateKeyFrames(withDuration duration: TimeInterval,
                               delay: TimeInterval = 0.0,
                               options: UIView.KeyframeAnimationOptions = [],
                               animations: @escaping (() -> Void),
                               completion: ((Bool) -> Void)? = nil) {
    UIView.animateKeyframes(withDuration: duration,
                            delay: delay,
                            options: options,
                            animations: animations,
                            completion: completion)
  }

  static func animateSpring(withDuration duration: TimeInterval,
                            delay: TimeInterval = 0.0,
                            usingSpringWithDamping damping: CGFloat,
                            initialSpringVelocity: CGFloat = 0.0,
                            options: UIView.AnimationOptions,
                            animations: @escaping () -> Void,
                            completion: ((Bool) -> Void)? = nil) {
    UIView.animate(withDuration: duration,
                   delay: delay,
                   usingSpringWithDamping: damping,
                   initialSpringVelocity: initialSpringVelocity,
                   options: options,
                   animations: animations,
                   completion: completion)
  }
}
