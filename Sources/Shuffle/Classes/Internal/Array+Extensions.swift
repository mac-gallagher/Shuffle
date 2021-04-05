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

extension Array {

  mutating func shift(withDistance distance: Int = 1) {
    let offsetIndex = distance >= 0
      ? index(startIndex, offsetBy: distance, limitedBy: endIndex)
      : index(endIndex, offsetBy: distance, limitedBy: startIndex)
    guard let index = offsetIndex else { return }
    self = Array(self[index ..< endIndex] + self[startIndex ..< index])
  }
}

extension Array where Element: Hashable {

  func removingDuplicates() -> [Element] {
    var dict = [Element: Bool]()
    return filter { dict.updateValue(true, forKey: $0) == nil }
  }

  mutating func removeDuplicates() {
    self = self.removingDuplicates()
  }
}
