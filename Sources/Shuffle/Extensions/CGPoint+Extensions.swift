//
//  CGPoint+Extensions.swift
//  Shuffle
//
//  Created by Mac Gallagher on 4/29/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    init(_ vector: CGVector) {
        self = CGPoint(x: vector.dx, y: vector.dy)
    }
}
