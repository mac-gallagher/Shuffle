import CoreGraphics

extension CGPoint {
    
    init(_ vector: CGVector) {
        self = CGPoint(x: vector.dx, y: vector.dy)
    }
}
