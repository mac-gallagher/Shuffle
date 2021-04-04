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

/// A type representing the direction of a physical drag.
@objc
public enum SwipeDirection: Int, CustomStringConvertible {
  // swiftlint:disable:next identifier_name
  case left, right, up, down

  /// A static array containing all `SwipeDirection`s.
  public static let allDirections: [SwipeDirection] = [left, up, right, down]

  /// The `SwipeDirection` represented as a unit vector.
  public var vector: CGVector {
    switch self {
    case .left:
      return CGVector(dx: -1, dy: 0)
    case .right:
      return CGVector(dx: 1, dy: 0)
    case .up:
      return CGVector(dx: 0, dy: -1)
    case .down:
      return CGVector(dx: 0, dy: 1)
    }
  }

  /// A textual representation of the `SwipeDirection`.
  public var description: String {
    switch self {
    case .left:
      return "left"
    case .right:
      return "right"
    case .up:
      return "up"
    case .down:
      return "down"
    }
  }
}
