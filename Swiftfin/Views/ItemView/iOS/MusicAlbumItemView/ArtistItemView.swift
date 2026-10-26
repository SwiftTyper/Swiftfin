//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import SwiftUI

struct ArtistItemView: View{
    
    @ObservedObject var viewModel: ArtistItemViewModel
    @State private var isPresented: Bool = false
    
    var body: some View{
            
        ScrollView(.vertical, showsIndicators: false){
            
            VStack(alignment: .leading, spacing: 20){
                
//                ImageView(viewModel.item.imageSource(.primary, maxWidth: 250))
//                    .frame(width: 250, height: 250)
//                    .cornerRadius(20)
//
                
                VStack(alignment: .leading, spacing: 0){
                        
                    Text("Artist")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                        VStack(alignment: .leading, spacing: 10){
                            
                            Text(viewModel.songs.first?.albumArtist ?? "")
                                .font(.title)
                                .bold()
                                .foregroundColor(.primary)
                                .padding(.top, 5)
                            
                            Label {
                                Text(String(viewModel.songs.count) + " songs")
                            } icon: {
                                Image(systemName: "music.note")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)

                            HStack(spacing: 20){
                                
                                Image(systemName: "suit.heart")
                                    .onTapGesture {
                                        
                                    }
                                
                                Image(systemName: "square.and.arrow.down")
                                    .onTapGesture {
                                        
                                    }
                                
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(-90))
                                    .onTapGesture {
                                        
                                    }
                            }
                            .foregroundColor(.primary)
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    
                    Button {
                        
                        
                    } label: {
                        Circle()
                            .foregroundColor(.jellyfinPurple)
                            .overlay(
                                Image(systemName: "play.fill")
                                    .foregroundColor(.white)
                                    .frame(height: 20)
                                ,alignment: .center
                            )
                            .frame(width: 60)
                    }
                    ,alignment: .bottomTrailing
                )
                
                Text("About")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
                
                Text("")
                    .frame(height: 70)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("Popular Songs")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
                
                ForEach(viewModel.songs, id: \.self) { item in
                    SongItemView(song: item)
                }
                
            }
        }
        .padding(.horizontal, 20)
    }
}
