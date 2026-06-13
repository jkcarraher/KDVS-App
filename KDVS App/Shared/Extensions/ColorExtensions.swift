//
//  ColorExtension.swift
//  KDVS
//
//  Created by John Carraher on 6/13/26.
//

import SwiftUI

extension UIColor {
    func adjustedBrightness(by factor: CGFloat) -> UIColor? {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            b = max(0, min(1, b + factor))
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        return nil
    }
}


extension Color {
    init?(hex: String?) {
        guard let hex = hex?.replacingOccurrences(of: "#", with: "") else {
            return nil
        }

        guard let rgb = Int(hex, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
    
    func brightened(by factor: Double) -> Color {
        let uiColor = UIColor(self)
        guard let modifiedColor = uiColor.adjustedBrightness(by: CGFloat(factor)) else {
            return self
        }
        return Color(modifiedColor)
    }
}
