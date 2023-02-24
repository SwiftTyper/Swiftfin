//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

public extension Color {

    internal static let jellyfinPurple = Color(uiColor: .jellyfinPurple)

    #if os(tvOS) // tvOS doesn't have these
    static let systemFill = Color(UIColor.white)
    static let secondarySystemFill = Color(UIColor.gray)
    static let tertiarySystemFill = Color(UIColor.black)
    static let lightGray = Color(UIColor.lightGray)
    #else
    static let systemFill = Color(UIColor.systemFill)
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    #endif
}

extension UIColor {
    static let jellyfinPurple = UIColor(red: 172 / 255, green: 92 / 255, blue: 195 / 255, alpha: 1)
}

extension UIColor {
    convenience init(from hsl : HSLColor) {
        self.init(hue: hsl.hue, saturation: hsl.saturation, brightness: hsl.brightness, alpha: hsl.alpha)
    }
    var hslColor: HSLColor {
        get {
            return HSLColor(from: self)
        }
    }
}

struct HSLColor {
    let hue, saturation, brightness, alpha : CGFloat
    init(hue : CGFloat, saturation : CGFloat, brightness : CGFloat, alpha : CGFloat = 1) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
    init(from color : UIColor) {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        if color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            hue = h
            saturation = s
            brightness = b
            alpha = a
        } else {
            hue = 0
            saturation = 0
            brightness = 0
            alpha = 1
        }
    }
    var uiColor : UIColor {
        get {
            return UIColor(from: self)
        }
    }
    
    func shiftHue(by amount : CGFloat) -> HSLColor {
        return HSLColor(hue: shift(hue, by: amount), saturation: saturation, brightness: brightness, alpha: alpha)
    }
    func shiftBrightness(by amount : CGFloat) -> HSLColor {
        return HSLColor(hue: hue, saturation: saturation, brightness: shift(brightness, by: amount), alpha: alpha)
    }
    func shiftSaturation(by amount : CGFloat) -> HSLColor {
        return HSLColor(hue: hue, saturation: shift(saturation, by: amount), brightness: brightness, alpha: alpha)
    }
    private func shift(_ value : CGFloat, by amount : CGFloat) -> CGFloat {
        return abs((value + amount).truncatingRemainder(dividingBy: 1))
    }
}
