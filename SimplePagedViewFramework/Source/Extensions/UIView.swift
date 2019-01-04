import UIKit

extension UIView {
    public func replace<T: UIView>(
        subview: UIView,
        with other: UIView,
        constraints: (_ child: UIView, _ parent: T) -> [NSLayoutConstraint]
    ) {
        let newConstraints = constraints(other, self as! T)
        guard let subviewIndex = subview.superview?.subviews.firstIndex(of: subview) else { fatalError() }
        subview.removeFromSuperview()
        self.insertSubview(other, at: subviewIndex)

        NSLayoutConstraint.activate(newConstraints)
    }
}
