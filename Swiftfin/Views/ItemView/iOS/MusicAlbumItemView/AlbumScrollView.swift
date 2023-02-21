//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import BlurHashKit
import SwiftUI

extension ItemView {

    struct AlbumScrollView<Content: View>: View {

        @EnvironmentObject
        private var itemRouter: ItemCoordinator.Router
        @State
        private var scrollViewOffset: CGFloat = 0
        @State
        private var blurHashBottomEdgeColor: Color = .secondarySystemFill
        @ObservedObject
        var viewModel: AlbumItemViewModel
        
        init(viewModel: AlbumItemViewModel,content: @escaping () -> Content){
            self.content = content
            self.viewModel = viewModel
        }
        
        let content: () -> Content

        private var headerTextOpacity: CGFloat {
            let progress = -scrollViewOffset / (UIScreen.main.bounds.height * 0.1)
            let opacity = min(max(1 - progress, 0), 1)
            return opacity
        }
        
        private var headerHeight: CGFloat {
            UIScreen.main.bounds.height * 0.45
        }

        private var headerOverlayOpacity: CGFloat{
            return scrollViewOffset / headerHeight * 1.5
        }
        

        var body: some View {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
               
                    Color.clear.frame(height: headerHeight)
                    
                    DetailsView()
                    
                    content()
                        .background(Color.systemBackground)
                     
                }
            }
            .edgesIgnoringSafeArea(.top)
            .scrollViewOffset($scrollViewOffset)
            .navBarOffset(
                backgroundColor: viewModel.backgroundColor!,
                $scrollViewOffset,
                start: UIScreen.main.bounds.height * 0.28,
                end: UIScreen.main.bounds.height * 0.28 + 50
            )
            .backgroundParallaxHeader(
                $scrollViewOffset,
                height: headerHeight,
                multiplier: 1
            ) {
                HeaderView()
            }
            .onChange(of: scrollViewOffset) { newValue in
                print(newValue)
            }
        }
       
        @ViewBuilder
        func HeaderView() -> some View{
            ZStack(alignment: .bottomLeading){
                
                ImageView(viewModel.item.imageSource(.primary, maxWidth: UIScreen.main.bounds.width))
                    .frame(height: headerHeight)
                    .overlay(
                        viewModel.backgroundColor!
                            .opacity(headerOverlayOpacity)
                    )
                
                Text(viewModel.item.displayName)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.primary)
                    .opacity(headerTextOpacity)
                    .padding(.leading, 30)
                    .padding(.bottom, 10)
                    .lineLimit(1)
            }
        }
        
        @ViewBuilder
        func DetailsView() -> some View {
            
            ZStack {
                LinearGradient(colors: [viewModel.backgroundColor!, .systemBackground], startPoint: .top, endPoint: .bottom)
                
                HStack{
                    
                    VStack(alignment: .leading, spacing: 5){
                    
                        DotHStack{
                            Text(viewModel.item.albumArtist ?? "")
                            Text("\(viewModel.albumItems.count) songs")
                        }
                        
                        HStack(spacing: 10){
                            
                            Button {
                                
                                UIDevice.impact(.light)
                                viewModel.toggleFavoriteState()
                                
                            } label: {
                                
                                if viewModel.isFavorited {
                                    Image(systemName: "heart.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(Color.red)
                                } else {
                                    Image(systemName: "heart")
                                        .foregroundColor(.primary)
                                }
                                
                            }
                            .frame(width: 40, height: 40)
                            
                            Button {
                            
                                
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.primary)
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Circle()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.jellyfinPurple)
                            .overlay(Image(systemName: "play.fill").foregroundColor(.systemBackground))
                        
                    }
                   
                }.padding(20)
            
            }
    }
    }
}

