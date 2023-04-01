//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct BookItemView: View {
    
    @ObservedObject
    var viewModel: BookItemViewModel
   
    private var image: some View{
        let url = viewModel.item.imageURL(.primary, maxWidth: 100, maxHeight: 100)
        let image = ImageView(url)
        return image
    }
    
    var body: some View{
        VStack(spacing: 10){
          
            Text(viewModel.item.displayName)
            Text(String(viewModel.item.chapters?.count ?? 0))
            ForEach(0..<(viewModel.item.chapters?.count ?? 0)){ index in
                Text(viewModel.item.chapters?[index].name ?? "")
                    .font(.caption)
            }
            Text(viewModel.downloadedBookItem?.displayName ?? "")
            ForEach(0..<(viewModel.downloadedBookItem?.chapters?.count ?? 0)){ index in
                Text(viewModel.item.chapters?[index].name ?? "")
                    .font(.caption)
            }
            Text(viewModel.item.overview ?? "")
            image
            
        }
    }
}
