import UIKit

extension UIColor {
    static let ypBlackDay      = UIColor(named: "BlackDay")      ?? .black
    static let ypGray          = UIColor(named: "Gray")          ?? .gray
    static let ypLightGray     = UIColor(named: "LightGray")     ?? .lightGray
    static let ypBackgroundDay = UIColor(named: "BackgroundDay") ?? .lightGray.withAlphaComponent(0.3)
    static let ypRed           = UIColor(named: "Red")           ?? .red
    static let ypBlue          = UIColor(named: "Blue")          ?? .blue

    static var trackerPalette: [UIColor] {
        (1...18).compactMap { UIColor(named: "Color\($0)") }
    }
}
