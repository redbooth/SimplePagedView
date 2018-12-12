import Foundation
import UIKit

public extension UIImage {

    func tint(with color: UIColor) -> UIImage {
        guard let cgImage = cgImage else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        color.setFill()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect(origin: .zero, size: size)
        context.clip(to: rect, mask: cgImage)
        context.fill(rect)

        let result = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return result
    }
}
