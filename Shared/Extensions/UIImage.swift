//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import UIKit
import SwiftUI

public extension UIImage{
    
    func resize(desired size: CGSize) -> UIImage{
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: renderFormat)
        let newImage: UIImage = renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }
    
    func getColors() -> [UIColor]{
        if let cgImage = cgImage, let data = cgImage.dataProvider?.data, let bytes = CFDataGetBytePtr(data){
            assert(cgImage.colorSpace?.model == .rgb)
            var colors: [UIColor] = []
            let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
            for y in 0 ..< cgImage.height{
                for x in 0 ..< cgImage.width{
                    let offset = (y * cgImage.bytesPerRow) + ( x * bytesPerPixel)
                    let red = CGFloat(bytes[offset])/255.0
                    let green = CGFloat(bytes[offset+1])/255.0
                    let blue = CGFloat(bytes[offset+2])/255.0
                    let alpha = CGFloat(bytes[offset+3])/255.0
                    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    colors.append(color)
                }
            }
            return colors
        }
        return []
    }
    
}

