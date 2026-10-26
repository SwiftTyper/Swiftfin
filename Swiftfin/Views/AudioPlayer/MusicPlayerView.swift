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

struct MusicPlayerView: View{
    
    @EnvironmentObject var viewModel: MusicPlayerViewModel
    @State private var offset: CGFloat = 0
    
    var body: some View{
        
        Group {
            if let song = viewModel.currentSong, let namespace = viewModel.namespace {
                
                VStack {
                    if viewModel.isExpanded {
                        expanded(song: song, namespace: namespace)
                    } else {
                        minimized(song: song, namespace: namespace)
                    }
                }
                .frame(maxHeight: viewModel.isExpanded ? .infinity : 70)
                .background(Color.systemBackground.cornerRadius(viewModel.isExpanded ? 20 : 0).ignoresSafeArea())
                .offset(y: viewModel.isExpanded ? 0 : -49)
                .offset(y: offset)
                .gesture(
                   DragGesture()
                    .onChanged { onChanged(value: $0) }
                    .onEnded { onEnded(value: $0) }
               )
            }
        }
    }
    
    func onChanged(value: DragGesture.Value) {
        if value.translation.height > 0 && viewModel.isExpanded {
            offset = value.translation.height
        }
    }
    
    func onEnded(value: DragGesture.Value) {
        if viewModel.isExpanded {
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.95)){
                let height = UIScreen.main.bounds.size.height
                if  offset > height / 4 {
                    viewModel.isExpanded = false
                }
                offset = 0
            }
        }
    }
    
    @ViewBuilder
    func minimized(song: BaseItemDto, namespace: Namespace.ID) -> some View{
        
        Button {
            withAnimation(Animation.easeInOut(duration: 0.3)){
                viewModel.isExpanded = true
            }
            
        } label: {
            
            HStack(spacing: 10){
                
                ImageView(song.imageURL(.primary, maxWidth: 50, maxHeight: 50))
                    .matchedGeometryEffect(id: "ARTWORK", in: namespace)
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                    
                
                VStack(alignment: .leading, spacing: 5){
                    
                    Text(song.displayName)
                        .bold()
                        .matchedGeometryEffect(id: "TITLE", in: namespace, properties: .position)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(song.albumArtist ?? "Unknown")
                        .bold()
                        .matchedGeometryEffect(id: "ARTIST", in: namespace, properties: .position)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
             
                Spacer()
                
                Button {
                    viewModel.isPlaying.toggle()
                } label: {
                    ZStack {
                 
                        Image(systemName: "pause.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 15)
                            .scaleEffect(viewModel.isPlaying ? 1 : 0)
                            .opacity(viewModel.isPlaying ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: viewModel.isPlaying)
                           
                        
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 15)
                            .scaleEffect(viewModel.isPlaying ? 0 : 1)
                            .opacity(viewModel.isPlaying ? 0 : 1)
                            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: viewModel.isPlaying)
                        
                    }
                    .foregroundColor(.primary)
                }
               
                .padding(.horizontal, 10)
                
                Button {
                    viewModel.skipForward()
                } label: {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 15)
                        .foregroundColor(.primary)
                }
              
            }
            .padding(.horizontal, 20)
            .frame(height: 70)
            .overlay(
                Color.secondarySystemFill
                    .frame(maxWidth: .infinity, maxHeight: 0.5)
                ,alignment: .bottom
            )
        }
       
    }
    
    @ViewBuilder
    func expanded(song: BaseItemDto, namespace: Namespace.ID) -> some View {
       
        GeometryReader { geo in
            
            VStack(alignment: .center, spacing: 0){
                
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)){
                            viewModel.isExpanded = false
                        }
                    }
                
                Spacer(minLength: 0)
               
                ImageView(song.imageSource(.primary, maxWidth: geo.size.width - 80, maxHeight: geo.size.width - 80))
                    .matchedGeometryEffect(id: "ARTWORK", in: namespace)
                    .frame(width: viewModel.isPlaying ? geo.size.width - 80 : 200, height: viewModel.isPlaying ? geo.size.width - 80 : 200)
                    .cornerRadius(20)
                    .animation(.spring(dampingFraction: 0.55), value: viewModel.isPlaying)
                
                Spacer(minLength: 0)
                
                VStack(alignment: .center, spacing: 40){
                                       
                    VStack(alignment: .center, spacing: 10){
                        
                        Text(viewModel.currentSong?.displayName ?? "")
                            .bold()
                            .allowsTightening(true)
                            .matchedGeometryEffect(id: "TITLE", in: namespace, properties: .position)
                            .font(.title)
                            .lineLimit(1)
                        
                        Text(viewModel.currentSong?.albumArtist ?? "")
                            .bold()
                            .allowsTightening(true)
                            .matchedGeometryEffect(id: "ARTIST", in: namespace, properties: .position)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        VStack(spacing: 20){
                            
                            VStack(spacing: 10){
                                
                                CustomSliderView(value: $viewModel.currentTime,isUserEditing: $viewModel.isUserEditingProgressBar, range: 0...viewModel.duration)
                                    .frame(height: 14)
                                    .padding(.top, 16)
                                
                                HStack {
                                    
                                    Text("\(viewModel.leftSliderText)")
                                        .bold()
                                        .font(.caption)
                                        .scaleEffect(viewModel.isUserEditingProgressBar ? 1.15 : 1)
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.rightSliderText)")
                                        .font(.caption)
                                        .bold()
                                        .scaleEffect(viewModel.isUserEditingProgressBar ? 1.15 : 1)
                                }
                                .foregroundColor(viewModel.isUserEditingProgressBar ? Color.primary : Color.secondary)
                            }
                            
                            HStack{
                                
                                Button {
                                    viewModel.isOnRepeat.toggle()
                                } label: {
                                    Image(systemName: "repeat")
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(viewModel.isOnRepeat ? Color.jellyfinPurple : Color.clear)
                                        )
                                        .animation(nil, value: viewModel.isOnRepeat)
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.skipBackward()
                                } label: {
                                    Image(systemName: "backward.fill")
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.isPlaying.toggle()
                                } label: {
                                    Circle()
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(.jellyfinPurple)
                                        .overlay(
                                            ZStack {
                                         
                                                Image(systemName: "pause.fill")
                                                    .scaleEffect(viewModel.isPlaying ? 1 : 0)
                                                    .opacity(viewModel.isPlaying ? 1 : 0)
                                                    .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: viewModel.isPlaying)
                                                
                                                Image(systemName: "play.fill")
                                                    .scaleEffect(viewModel.isPlaying ? 0 : 1)
                                                    .opacity(viewModel.isPlaying ? 0 : 1)
                                                    .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: viewModel.isPlaying)
                                                
                                            }
                                            .foregroundColor(.primary)
                                            ,alignment: .center
                                        )
                                }
                            
                                Spacer()
                                
                                Button {
                                    viewModel.skipForward()
                                } label: {
                                    Image(systemName: "forward.fill")
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.isShuffled.toggle()
                                } label: {
                                    Image(systemName: "shuffle")
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(viewModel.isShuffled ? Color.jellyfinPurple : Color.clear)
                                        )
                                        .animation(nil, value: viewModel.isShuffled)
                                }
                                
                            }.foregroundColor(.primary)
                            
                        }
                            
                    }
                    .disabled(viewModel.isLoading)
                  
                    ZStack(alignment: .bottom){
                       
                        VStack(spacing: 10){
                            
                            Text("Select Song")
                                .font(.caption)
                            
                            Image(systemName: "control")
                                .rotationEffect(.degrees(-180))
                                .scaleEffect(2)
                            
                            Spacer()
                            
                        }
                        .foregroundColor(.primary)
                        .onTapGesture {
                            withAnimation(Animation.easeInOut(duration: 0.3)){
                                viewModel.isExpanded = false
                            }
                        }
                
                        
                        HStack{
                            
                            AirPlayView()
                                .frame(width: 15, height: 15)
                            Spacer()
                            
                            Image(systemName: "timer")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 15)
                        }
                        .foregroundColor(.secondary)
                        .disabled(viewModel.isLoading)
                         
                    }
                    .frame(height: 0.05 * geo.size.height)
            
                    
                    HStack(spacing: 10){
                        
                        Image(systemName: "speaker.fill")
                            .font(.caption)
                        
                        VolumeSliderView()
                            .frame(width: 200, height: 14)
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.caption)
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 10)

                   
                }
            }
            .padding(.horizontal, 30)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    }
                }
                ,alignment: .top
            )
          
        }
        
    }
}
