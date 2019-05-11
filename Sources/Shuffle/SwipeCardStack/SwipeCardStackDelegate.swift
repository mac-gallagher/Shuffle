//
//  SwipeCardStackDelegate.swift
//  Shuffle
//
//  Created by Mac Gallagher on 6/8/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Foundation

@objc public protocol SwipeCardStackDelegate: class {
    @objc optional func didSwipeAllCards(_ cardStack: SwipeCardStack)
    @objc optional func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection)
    @objc optional func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection)
    @objc optional func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int)
}
