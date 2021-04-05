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

/// A wrapper over `UIView` which detects customized swipe gestures. The swipe recognition is
/// based on both speed and translation, and can and be set for each direction.
///
/// This view is intended to be subclassed.
open class SwipeView: UIView {

  /// The swipe directions to be detected by the view. Set this variable to ignore certain directions.
  /// Defaults to `SwipeDirection.allDirections`.
  open var swipeDirections = SwipeDirection.allDirections

  /// The pan gesture recognizer attached to the view.
  public var panGestureRecognizer: UIPanGestureRecognizer {
    return internalPanGestureRecognizer
  }

  private lazy var internalPanGestureRecognizer = PanGestureRecognizer(target: self,
                                                                       action: #selector(handlePan))

  /// The tap gesture recognizer attached to the view.
  public var tapGestureRecognizer: UITapGestureRecognizer {
    return internalTapGestureRecognizer
  }

  private lazy var internalTapGestureRecognizer = TapGestureRecognizer(target: self,
                                                                       action: #selector(didTap))

  // MARK: - Initialization

  /// Initializes the `SwipeView` with the required gesture recognizers.
  /// - Parameter frame: The frame rectangle for the view, measured in points.
  override public init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  /// Initializes the `SwipeView` with the required gesture recognizers.
  /// - Parameter aDecoder: An unarchiver object.
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  private func initialize() {
    addGestureRecognizer(internalPanGestureRecognizer)
    addGestureRecognizer(internalTapGestureRecognizer)
  }

  // MARK: - Swipe Calculations

  /// The active swipe direction on the view, if any.
  /// - Returns: The member of `swipeDirections` which returns the highest `dragPercentage:`.
  public func activeDirection() -> SwipeDirection? {
    return swipeDirections.reduce((CGFloat.zero, nil)) { [unowned self] lastResult, direction in
      let dragPercentage = self.dragPercentage(on: direction)
      return dragPercentage > lastResult.0 ? (dragPercentage, direction) : lastResult
    }.1
  }

  /// The speed of the current drag velocity projected onto the specified direction.
  ///
  ///  Expressed in points per second.
  /// - Parameter direction: The direction to project the drag onto.
  /// - Returns: The speed of the current drag velocity on the specifed direction.
  public func dragSpeed(on direction: SwipeDirection) -> CGFloat {
    let velocity = panGestureRecognizer.velocity(in: superview)
    return abs(direction.vector * CGVector(to: velocity))
  }

  /// The percentage of `minimumSwipeDistance` the current drag translation attains in the specified direction.
  ///
  /// The provided swipe direction need not be a member of `swipeDirections`.
  /// Can return a value greater than 1.
  /// - Parameter direction: The swipe direction.
  /// - Returns: The percentage of `minimumSwipeDistance` the current drag translation attains in
  /// the specified direction.
  public func dragPercentage(on direction: SwipeDirection) -> CGFloat {
    let translation = CGVector(to: panGestureRecognizer.translation(in: superview))
    let scaleFactor = 1 / minimumSwipeDistance(on: direction)
    let percentage = scaleFactor * (translation * direction.vector)
    return percentage < 0 ? 0 : percentage
  }

  /// The minimum required speed on the intended direction to trigger a swipe. Subclasses can override
  /// this method for custom swipe behavior.
  /// - Parameter direction: The swipe direction.
  /// - Returns: The minimum speed required to trigger a swipe in the indicated direction, measured in
  ///            points per second. Defaults to 1100 for each direction.
  open func minimumSwipeSpeed(on direction: SwipeDirection) -> CGFloat {
    return 1100
  }

  /// The minimum required drag distance on the intended direction to trigger a swipe, measured from the
  /// swipe's initial touch point. Subclasses can override this method for custom swipe behavior.
  /// - Parameter direction: The swipe direction.
  /// - Returns: The minimum distance required to trigger a swipe in the indicated direction, measured in
  ///            points. Defaults to 1/4 of the minimum of the screen's width and height.
  open func minimumSwipeDistance(on direction: SwipeDirection) -> CGFloat {
    return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 4
  }

  // MARK: - Gesture Recognition

  /// This function is called whenever the view is tapped. The default implementation does nothing;
  /// subclasses can override this method to perform whatever actions are necessary.
  /// - Parameter recognizer: The gesture recognizer associated with the tap.
  @objc
  open func didTap(_ recognizer: UITapGestureRecognizer) {}

  /// This function is called whenever the view recognizes the beginning of a swipe. The default
  /// implementation does nothing; subclasses can override this method to perform whatever actions
  /// are necessary.
  /// - Parameter recognizer: The gesture recognizer associated with the swipe.
  open func beginSwiping(_ recognizer: UIPanGestureRecognizer) {}

  /// This function is called whenever the view recognizes a change in the active swipe. The default
  /// implementation does nothing; subclasses can override this method to perform whatever actions are
  /// necessary.
  /// - Parameter recognizer: The gesture recognizer associated with the swipe.
  open func continueSwiping(_ recognizer: UIPanGestureRecognizer) {}

  /// This function is called whenever the view recognizes the end of a swipe, regardless if the swipe
  /// was successful or cancelled.
  /// - Parameter recognizer: The gesture recognizer associated with the swipe.
  open func endSwiping(_ recognizer: UIPanGestureRecognizer) {
    if let direction = activeDirection() {
      if dragSpeed(on: direction) >= minimumSwipeSpeed(on: direction)
          || dragPercentage(on: direction) >= 1 {
        didSwipe(recognizer, with: direction)
        return
      }
    }
    didCancelSwipe(recognizer)
  }

  /// This function is called whenever the view recognizes a swipe. The default implementation does
  /// nothing; subclasses can override this method to perform whatever actions are necessary.
  /// - Parameters:
  ///   - recognizer: The gesture recognizer associated with the recognized swipe.
  ///   - direction: The direction of the swipe.
  open func didSwipe(_ recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {}

  /// This function is called whenever the view recognizes a cancelled swipe. The default implementation
  /// does nothing; subclasses can override this method to perform whatever actions are necessary.
  /// - Parameter recognizer: The gesture recognizer associated with the cancelled swipe.
  open func didCancelSwipe(_ recognizer: UIPanGestureRecognizer) {}

  // MARK: - Selectors

  @objc
  private func handlePan(_ recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .possible, .began:
      beginSwiping(recognizer)
    case .changed:
      continueSwiping(recognizer)
    case .ended, .cancelled:
      endSwiping(recognizer)
    default:
      break
    }
  }
}
