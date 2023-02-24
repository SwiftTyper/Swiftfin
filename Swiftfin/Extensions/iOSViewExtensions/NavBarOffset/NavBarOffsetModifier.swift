//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct NavBarOffsetModifier: ViewModifier {
    
    @Binding
    var scrollViewOffset: CGFloat
    var textColor: Color?
    var backgroundColor: Color?
    let start: CGFloat
    let end: CGFloat
    
    init(textColor: Color?, backgroundColor: Color?, scrollViewOffset: Binding<CGFloat>, start: CGFloat, end: CGFloat){
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self._scrollViewOffset = scrollViewOffset
        self.start = start
        self.end = end
    }

    func body(content: Content) -> some View {
        NavBarOffsetView(textColor: textColor, backgroundColor: backgroundColor, scrollViewOffset: $scrollViewOffset, start: start, end: end) {
            content
        }
        .ignoresSafeArea()
    }
}
