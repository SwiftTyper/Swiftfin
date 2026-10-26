//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import SwiftUI
import JellyfinAPI

struct SongItemView: View{
   
    @EnvironmentObject var viewModel: MusicPlayerViewModel
    let song: BaseItemDto
    
    var body: some View{
        
        Button {
            viewModel.currentSong = song
        } label: {
            
            HStack(spacing: 20){
                
                ImageView(song.imageSource(.primary, maxWidth: 50, maxHeight: 50))
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 5){
                    
                    Text(song.displayName)
                        .bold()
                        .lineLimit(1)
                        .allowsTightening(true)
                        .foregroundColor(.primary)
                        .font(.subheadline)
                       
                   
                    HStack(spacing: 5){
                        ForEach(song.artists ?? [], id: \.self){ artist in
                            NavigationLink {
                                ArtistItemView(viewModel: .init(item: song))
                            } label: {
                                Text(String(artist))
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        Spacer()
                    }
                    .lineLimit(1)
                   
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(-90))
                    .frame(height: 15)
                    .foregroundColor(.primary)
            }
        }
    }
}
