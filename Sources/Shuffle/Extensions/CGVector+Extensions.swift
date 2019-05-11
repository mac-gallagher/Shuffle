//
//  CGVector+Extensions.swift
//  Shuffle
//
//  Created by Mac Gallagher on 4/24/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import CoreGraphics

extension CGVector {
    
    // MARK: - Operators
    
    public static prefix func +(vector: CGVector) -> CGVector {
        return vector
    }
    
    public static prefix func -(vector: CGVector) -> CGVector {
        return CGVector(dx: -vector.dx, dy: -vector.dy)
    }
    
    public static func +(lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    public static func -(lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    public static func *(scalar: CGFloat, vector: CGVector) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
    
    public static func *(scalar: Int, vector: CGVector) -> CGVector {
        return vector * CGFloat(scalar)
    }
    
    public static func *(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
    
    public static func *(vector: CGVector, scalar: Int) -> CGVector {
        return vector * CGFloat(scalar)
    }
    
    public static func /(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }
    
    public static func /(vector: CGVector, scalar: Int) -> CGVector {
        return vector / CGFloat(scalar)
    }
    
    public static func +=(lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs + rhs
    }
    
    public static func -=(lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs - rhs
    }
    
    public static func *=(vector: inout CGVector, scalar: CGFloat) {
        vector = vector * scalar
    }
    
    public static func *=(vector: inout CGVector, scalar: Int) {
        vector = vector * scalar
    }
    
    public static func /=(vector: inout CGVector, scalar: CGFloat) {
        vector = vector / scalar
    }
    
    public static func /=(vector: inout CGVector, scalar: Int) {
        vector = vector / scalar
    }
    
    public static func *(lhs: CGVector, rhs: CGVector) -> CGFloat {
        return lhs.dx * rhs.dx + lhs.dy * rhs.dy
    }
    
    // MARK: - Miscellaneous
    
    public init(from origin: CGPoint = .zero, to target: CGPoint) {
        let dx = target.x - origin.x
        let dy = target.y - origin.y
        self = CGVector(dx: dx, dy: dy)
    }
    
    public init(_ size: CGSize) {
        self = CGVector(dx: size.width, dy: size.height)
    }
    
    public var length: CGFloat {
        return hypot(self.dx, self.dy)
    }
    
    public var normalized: CGVector {
        return self / self.length
    }
}

// MARK: - Functions

public func abs(_ vector: CGVector) -> CGFloat {
    return vector.length
}
