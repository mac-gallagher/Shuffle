//
//  SwipeCardStackDataSource.swift
//  Shuffle
//
//  Created by Mac Gallagher on 6/8/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Foundation

public protocol SwipeCardStackDataSource: class {
    func numberOfCards(in cardStack: SwipeCardStack) -> Int
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard
}
