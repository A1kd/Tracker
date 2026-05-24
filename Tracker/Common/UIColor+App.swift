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

    convenience init(hex: String) {
        var hexString = hex.uppercased()
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&value)
        let r = CGFloat((value & 0xFF0000) >> 16) / 255
        let g = CGFloat((value & 0x00FF00) >> 8) / 255
        let b = CGFloat(value & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    func toHexString() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }
}
