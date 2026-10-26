//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import Combine

final class ArtistItemViewModel: ItemViewModel{
        
    @Published var songs: [BaseItemDto] = []
    
    override init(item: BaseItemDto){
        super.init(item: item)
        
        getArtistId(artist: item.albumArtist ?? "")
            .sink { compleation in
                self.handleAPIRequestError(completion: compleation)
            } receiveValue: { [weak self] id in
                self?.getSongs(id: id)
            }
            .store(in: &cancellables)
    }
    
    private func getArtistId(artist: String) -> AnyPublisher<String,Error> {
        ArtistsAPI.getArtistByName(name: artist, userId: SessionManager.main.currentLogin.user.id)
            .map{ $0.id ?? ""}
            .eraseToAnyPublisher()
    }
    
    private func getSongs(id: String){
        
        ItemsAPI.getItems(
            userId: SessionManager.main.currentLogin.user.id,
            recursive: true,
            includeItemTypes: [.audio],
            albumArtistIds: [id]
           
        )
        .map { response -> [BaseItemDto] in
            if let items = response.items{
                return items.sorted { $0.title < $1.title }
            } else {
               return []
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] compleation in
            self?.handleAPIRequestError(completion: compleation)
        } receiveValue: { [weak self] items in
            self?.songs = items
        }
        .store(in: &self.cancellables)
    }
}
