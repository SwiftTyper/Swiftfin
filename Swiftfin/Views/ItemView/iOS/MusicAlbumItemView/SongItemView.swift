//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import SwiftUI

extension AlbumItemView{
    
    struct SongItemView: View {

        @ObservedObject var viewModel: ItemViewModel
        
        init(viewModel: ItemViewModel){
            self.viewModel = viewModel
        }
       
        var body: some View {
            
            HStack(spacing: 0){
                
                VStack(alignment: .leading, spacing: 0){
                        
                    Text(viewModel.item.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(viewModel.item.albumArtist ?? "")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu{
                    favoriteButton()
                    checkmarkButton()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
               
            }
            
        }

        @ViewBuilder
        func favoriteButton() -> some View{
            
            Button {
                UIDevice.impact(.light)
                viewModel.toggleFavoriteState()
            } label: {
                
                Label {
                    Text("favorite")
                } icon: {
                    if viewModel.isFavorited {
                        Image(systemName: "heart.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.red)
                    } else {
                        Image(systemName: "heart")
                    }
                }
                
            }
         
            
        }
        
        @ViewBuilder
        func checkmarkButton() -> some View{
            
            Button {
                UIDevice.impact(.light)
                viewModel.toggleWatchState()
            } label: {
                Label {
                    Text("watched")
                } icon: {
                    if viewModel.isWatched {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(
                                .primary,
                                Color.jellyfinPurple
                            )
                    } else {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
           
        }
    }
}

