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

final class BookItemViewModel: ItemViewModel{

    @Published var downloadedBookItem: BaseItemDto?
    
    override init(item: BaseItemDto){
        super.init(item: item)
        getBookItem()
    }
    
    func getBookItem(){
        
        let downloadURL = LibraryAPI.getDownload(itemId: item.id ?? "")
            .sink(receiveCompletion: { compleation in
                self.handleAPIRequestError(completion: compleation)
            }, receiveValue: { fileURL in
                
                //guard let document = EPUBDocument(url: fileURL) else { return }
                if let data = try? Data(contentsOf: fileURL){
                    print(data)
                }
            
                
                
                
            })
            .store(in: &cancellables)
//            .mapError{ error -> Never in
//                fatalError("Error occured while downloding url")
//            }
//            .map{ url -> URLRequest in
//                URLRequest(url: url)
////            }
//            .flatMap { urlRequest -> AnyPublisher<Data,Never> in
//                print(urlRequest)
//                return URLSession.shared.dataTaskPublisher(for: urlRequest)
//                    .map{ (data: Data, response: URLResponse) in
//                        return data
//                    }
//                    .replaceError(with: Data())
//                    .eraseToAnyPublisher()
//            }
//            .sink { compleation in
//                self.handleAPIRequestError(completion: compleation)
//            } receiveValue: { data in
//                print(data)
//            }

            
      
    }
        
        
//        ItemsAPI.getItems(
//            userId: SessionManager.main.currentLogin.user.id,
//            limit: 1,
//            enableUserData: true,
//            ids: [item.id ?? ""]
//        )
//        .sink { compleation in
//            self.handleAPIRequestError(completion: compleation)
//        } receiveValue: { value in
//            if let bookItem = value.items?.first {
//                self.downloadedBookItem = bookItem
//            }
//        }
//        .store(in: &cancellables)
    
  
}
