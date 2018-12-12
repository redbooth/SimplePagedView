import UIKit

// Gestures won't be recognized on subviews that are outside the bounds of a view
// This subclass and override remedies that.
// We're using it because there are situations (kanban view) where we want the page
// indicator to be outside the page view
public class ExternallyInteractiveUIView: UIView {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else { continue }
            return result
        }
        return nil
    }
}
