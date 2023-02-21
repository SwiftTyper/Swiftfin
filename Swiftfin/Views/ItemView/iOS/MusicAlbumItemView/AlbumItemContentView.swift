//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import SwiftUI
import JellyfinAPI

extension AlbumItemView{
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: AlbumItemViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 20){
                ForEach(viewModel.albumItems){ item in
                    SongItemView(viewModel: .init(item: item))
                }.padding(.horizontal, 20)
            }
            
        }
    }
}
