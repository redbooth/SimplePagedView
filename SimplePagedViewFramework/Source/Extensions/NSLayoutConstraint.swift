import UIKit

public extension NSLayoutConstraint {

    /// Convenience method that activates each constraint in the list of arrays, in the same manner as setting active=true. This is often more efficient than activating each constraint individually.
    ///
    /// - Parameter constraintsList: Set of typically related constraints
    @available(iOS 8.0, *)
    class func activate(_ constraintsList: [NSLayoutConstraint]...) {
        let constraints = Array(constraintsList.joined())
        NSLayoutConstraint.activate(constraints)
    }
}
