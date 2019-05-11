//
//  MockCardLayoutProvider.swift
//  ShuffleTests
//
//  Created by Mac Gallagher on 5/30/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

@testable import Shuffle

struct MockCardLayoutProvider: CardLayoutProvidable {
    
    static var testOverlayContainerFrame: CGRect = .zero
    static var overlayContainerFrame: (SwipeCard) -> CGRect {
        return { _ in
            return testOverlayContainerFrame
        }
    }
    
    static var testContentFrame: CGRect = .zero
    static var contentFrame: (SwipeCard) -> CGRect {
        return { _ in
            return testContentFrame
        }
    }
    
    static var testFooterFrame: CGRect = .zero
    static var footerFrame: (SwipeCard) -> CGRect {
        return { _ in
            return testFooterFrame
        }
    }
    
    // MARK: - Test Helpers
    
    static func reset() {
        testOverlayContainerFrame = .zero
        testContentFrame = .zero
        testFooterFrame = .zero
    }
}
