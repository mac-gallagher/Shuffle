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

/// The animation options provided to the internal card stack animator.
public struct CardStackAnimationOptions {

  /// The duration of the animation applied to the background cards after a canceled swipe has been recognized
  /// on the top card.
  ///
  /// If this value is `nil`, the animation will last exactly half the duration of
  /// `animationOptions.resetDuration` on the top card. This value must be greater than zero.
  /// Defaults to `nil`.
  public var resetDuration: TimeInterval? {
    didSet {
      if let duration = resetDuration {
        resetDuration = max(.leastNormalMagnitude, duration)
      }
    }
  }

  /// The duration of the card stack shift animation.
  ///
  /// This value must be greater than zero. Defaults to `0.1`.
  public var shiftDuration: TimeInterval = 0.1 {
    didSet {
      shiftDuration = max(.leastNormalMagnitude, shiftDuration)
    }
  }

  /// The duration of the animation applied to the background cards after a swipe has been recognized on the top card.
  ///
  /// If this value is `nil`, the animation will last exactly half the duration of
  /// `animationOptions.totalSwipeDuration` on the top card. This value must be greater than zero.
  /// Defaults to `nil`.
  public var swipeDuration: TimeInterval? {
    didSet {
      if let duration = swipeDuration {
        swipeDuration = max(.leastNormalMagnitude, duration)
      }
    }
  }

  /// The duration of the animation applied to the background cards after an `undo` has been triggered.
  ///
  /// If this value is `nil`, the animation will last exactly half the duration of
  /// `animationOptions.totalReverseSwipeDuration` on the top card. This value must be greater than zero.
  /// Defaults to `nil`.
  public var undoDuration: TimeInterval? {
    didSet {
      if let duration = undoDuration {
        undoDuration = max(.leastNormalMagnitude, duration)
      }
    }
  }
}
