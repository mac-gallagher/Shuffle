//
//  UIView+Extensions.swift
//  Shuffle
//
//  Created by Mac Gallagher on 9/1/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Sets the `isUserInteractionEnabled` property on the view and all of it's subviews.
    ///
    /// - Parameter isEnabled: the value to set the `isUserInteractionEnabled` property to.
    func setUserInteraction(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
        for subview in subviews {
            subview.setUserInteraction(isEnabled)
        }
    }
}
