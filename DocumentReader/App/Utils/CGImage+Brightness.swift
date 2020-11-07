import UIKit

// swiftlint:disable identifier_name
extension CGImage {
    /// returns image brightness in value from 0 to 255
    var brightness: Double {
        guard let imageData = self.dataProvider?.data,
              let ptr = CFDataGetBytePtr(imageData) else { return 0 }
        var x = 0
        var result: Double = 0
        for _ in 0..<self.height {
            for _ in 0..<self.width {
                let r = ptr[0]
                let g = ptr[1]
                let b = ptr[2]
                result += (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                x += 1
            }
        }
        let bright = result / Double(x)
        return bright
    }
}
