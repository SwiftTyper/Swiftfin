//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import SwiftUI
import Defaults

struct AlbumItemView: View {
    @ObservedObject
    var viewModel: AlbumItemViewModel
    @Default(.Customization.itemViewType)
    private var itemViewType
    
    var body: some View {
//        switch itemViewType{
//        case .cinematic:
//            ItemView.CinematicScrollView(viewModel: viewModel){
//                ContentView(viewModel: viewModel)
//            }
//        case .compactPoster:
//            ItemView.CompactPosterScrollView(viewModel: viewModel){
//                ContentView(viewModel: viewModel)
//            }
//        case .compactLogo:
//            ItemView.CompactLogoScrollView(viewModel: viewModel){
//                ContentView(viewModel: viewModel)
//            }
//        }
        
        ItemView.AlbumScrollView(viewModel: viewModel){
            ContentView(viewModel: viewModel)
        }
        
    }
}


