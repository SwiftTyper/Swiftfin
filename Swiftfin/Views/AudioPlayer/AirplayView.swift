//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import SwiftUI
import AVKit

struct AirPlayView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        let routePickerView = AVRoutePickerView()
        routePickerView.tintColor = .secondaryLabel
        routePickerView.backgroundColor = .clear
        routePickerView.activeTintColor = .jellyfinPurple
        return routePickerView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
       
    }
}
