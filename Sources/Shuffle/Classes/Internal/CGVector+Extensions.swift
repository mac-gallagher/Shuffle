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

extension CGVector {

  // MARK: - Operators

  static prefix func + (vector: CGVector) -> CGVector {
    return vector
  }

  static prefix func - (vector: CGVector) -> CGVector {
    return CGVector(dx: -vector.dx, dy: -vector.dy)
  }

  static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
  }

  static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
  }

  static func * (scalar: CGFloat, vector: CGVector) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
  }

  static func * (scalar: Int, vector: CGVector) -> CGVector {
    return vector * CGFloat(scalar)
  }

  static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
  }

  static func * (vector: CGVector, scalar: Int) -> CGVector {
    return vector * CGFloat(scalar)
  }

  static func / (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
  }

  static func / (vector: CGVector, scalar: Int) -> CGVector {
    return vector / CGFloat(scalar)
  }

  static func += (lhs: inout CGVector, rhs: CGVector) {
    // swiftlint:disable:next shorthand_operator
    lhs = lhs + rhs
  }

  static func -= (lhs: inout CGVector, rhs: CGVector) {
    // swiftlint:disable:next shorthand_operator
    lhs = lhs - rhs
  }

  static func *= (vector: inout CGVector, scalar: CGFloat) {
    // swiftlint:disable:next shorthand_operator
    vector = vector * scalar
  }

  static func *= (vector: inout CGVector, scalar: Int) {
    // swiftlint:disable:next shorthand_operator
    vector = vector * scalar
  }

  static func /= (vector: inout CGVector, scalar: CGFloat) {
    // swiftlint:disable:next shorthand_operator
    vector = vector / scalar
  }

  static func /= (vector: inout CGVector, scalar: Int) {
    // swiftlint:disable:next shorthand_operator
    vector = vector / scalar
  }

  static func * (lhs: CGVector, rhs: CGVector) -> CGFloat {
    return lhs.dx * rhs.dx + lhs.dy * rhs.dy
  }

  // MARK: - Miscellaneous

  init(from origin: CGPoint = .zero, to target: CGPoint) {
    self = CGVector(dx: target.x - origin.x,
                    dy: target.y - origin.y)
  }

  init(_ size: CGSize) {
    self = CGVector(dx: size.width, dy: size.height)
  }

  var length: CGFloat {
    return hypot(self.dx, self.dy)
  }

  var normalized: CGVector {
    return self / self.length
  }
}

// MARK: - Functions

func abs(_ vector: CGVector) -> CGFloat {
  return vector.length
}
