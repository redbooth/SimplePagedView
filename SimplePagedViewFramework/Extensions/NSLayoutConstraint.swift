import UIKit

extension NSLayoutConstraint {

    /* Convenience method that activates each constraint in the list of arrays, in the same manner as setting
     active=YES. This is often more efficient than activating each constraint individually. */
    @available(iOS 8.0, *)
    class func activate(_ constraintsList: [NSLayoutConstraint]...) {
        let constraints = Array(constraintsList.joined())
        NSLayoutConstraint.activate(constraints)
    }
}
