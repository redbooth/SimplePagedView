import UIKit

public extension UIViewController {
    /// Adds a child ViewController
    public func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// Adds a subViewController and constraints to self
    public func add(
        _ childViewController: UIViewController,
        constraints: (UIView) -> [NSLayoutConstraint]
    ) {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.didMove(toParent: self)
        NSLayoutConstraint.activate(constraints(childViewController.view))
    }

    /// Removes a child ViewController
    public func removeFromParent() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
