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
