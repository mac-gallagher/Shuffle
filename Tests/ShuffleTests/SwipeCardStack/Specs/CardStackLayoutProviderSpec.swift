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

import Nimble
import Quick
@testable import Shuffle
import UIKit

// swiftlint:disable implicitly_unwrapped_optional
class CardStackLayoutProviderSpec: QuickSpec {

  override func spec() {
    let insets = UIEdgeInsets(top: -1, left: 2, bottom: 3, right: -4)
    let cardStackWidth: CGFloat = 100
    let cardStackHeight: CGFloat = 200

    var cardStack: SwipeCardStack!
    var subject: CardStackLayoutProvider!

    beforeEach {
      cardStack = SwipeCardStack(animator: MockCardStackAnimator(),
                                 layoutProvider: MockCardStackLayoutProvider(),
                                 notificationCenter: NotificationCenter.default,
                                 stateManager: MockCardStackStateManager(),
                                 transformProvider: MockCardStackTransformProvider())
      cardStack.cardStackInsets = insets
      cardStack.frame = CGRect(x: 0, y: 0, width: cardStackWidth, height: cardStackHeight)

      subject = CardStackLayoutProvider()
    }

    // MARK: - Card Container Frame

    describe("When calling createCardContainerFrame") {
      it("should return the correct frame") {
        let expectedWidth = cardStackWidth - (insets.left + insets.right)
        let expectedHeight = cardStackHeight - (insets.top + insets.bottom)
        let expectedFrame = CGRect(x: insets.left,
                                   y: insets.top,
                                   width: expectedWidth,
                                   height: expectedHeight)
        let actualFrame = subject.createCardContainerFrame(for: cardStack)
        expect(actualFrame) == expectedFrame
      }
    }

    // MARK: - Card Frame

    describe("When calling createCardFrame") {
      it("should return the correct frame") {
        let expectedWidth = cardStackWidth - (insets.left + insets.right)
        let expectedHeight = cardStackHeight - (insets.top + insets.bottom)
        let expectedFrame = CGRect(x: 0,
                                   y: 0,
                                   width: expectedWidth,
                                   height: expectedHeight)
        let actualFrame = subject.createCardFrame(for: cardStack)
        expect(actualFrame) == expectedFrame
      }
    }
  }
}
// swiftlint:enable implicitly_unwrapped_optional
