//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import SwiftUI
import AVFoundation
import Combine
import Defaults

final class MusicPlayerViewModel:  ViewModel {
    
    @Published var currentSong: BaseItemDto? = nil {
        didSet{
            update()
        }
    }
       
    @Published private var adjacentSongs: [BaseItemDto] = []
    
    @Published var isExpanded: Bool = false
    
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                startTimer()
                playSong()
            } else {
                stopTimer()
                stopSong()
            }
        }
    }
    
    @Published var isShuffled: Bool = false
    
    @Published var isOnRepeat: Bool = false {
        didSet {
            getAdjacentSongs()
        }
    }
    
    @Published var isUserEditingProgressBar: Bool = false {
        didSet {
            if isUserEditingProgressBar {
                stopTimer()
            } else if isPlaying {
                startTimer()
            }
        }
    }
    
    @Published var currentTime: Double = 0 {
        didSet {
            if isUserEditingProgressBar {
                audioPlayer?.currentTime = currentTime
            }
        }
    }

    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private var audioPlayer2: AVPlayer?
    var namespace: Namespace.ID? = nil
    
    var leftSliderText: String {
        formatTimeText(value: currentTime)
    }
    
    var rightSliderText: String {
        let remainingTime = duration - currentTime
        return "-" + formatTimeText(value: remainingTime)
    }
    
    var duration: Double{
        return Double(currentSong?.runTimeTicks ?? 0) / 10_000_000
    }
    
    private func startTimer() {
        timer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc private func fireTimer() {
        if currentTime < duration {
            currentTime += 1
        }else {
            if isOnRepeat {
                replaySong()
            } else {
                skipForward()
            }
        }
    }

    private func stopTimer(){
        timer?.invalidate()
    }
    
    private func configureAudioPlayer(){
        guard let id = currentSong?.id else { return }
        
        AudioAPI.getAudioStream(itemId: id)
            .trackActivity(loading)
            .sink { compleation in
                self.handleAPIRequestError(completion: compleation)
            } receiveValue: { url in
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.prepareToPlay()
                } catch {
                   print("failed to setup player")
                }
                
                self.isPlaying = true
            }
            .store(in: &cancellables)
    }
    
    private func configureLiveAudioPlayer(){
        
        let tempOverkillBitrate = 360_000_000
        
        AudioAPI.getAudioStream(
            itemId: (currentSong?.id)!,
            _static: true
        )
        .trackActivity(loading)
        .sink { compleation in
            self.handleAPIRequestError(completion: compleation)
        } receiveValue: { url in
            print(url)
        }
        .store(in: &cancellables)
        
//        UniversalAudioAPI.headUniversalAudioStream(
//            itemId: (currentSong?.id)!,
//            deviceId: UIDevice.vendorUUIDString,
//            userId: SessionManager.main.currentLogin.user.id,
//            maxStreamingBitrate: tempOverkillBitrate,
//            startTimeTicks: 0,
//            enableRemoteMedia: false,
//            enableRedirection: true
//        )
//        .trackActivity(loading)
//        .sink { compleation in
//            self.handleAPIRequestError(completion: compleation)
//        } receiveValue: { url in
//            do {
//                   self.audioPlayer = try AVAudioPlayer(contentsOf: url)
//                   self.audioPlayer?.prepareToPlay()
//               } catch {
//                   print("failed to setup a live player")
//               }
//               self.isPlaying = true
//        }
//        .store(in: &cancellables)
        
        
//        UniversalAudioAPI.getUniversalAudioStream(
//            itemId: (currentSong?.id)!,
//            deviceId: UIDevice.vendorUUIDString,
//            userId: SessionManager.main.currentLogin.user.id,
//            audioCodec: "aac",
//            maxStreamingBitrate: tempOverkillBitrate,
//            startTimeTicks: 0,
//            transcodingContainer: "ts",
//            transcodingProtocol: "hls",
//            enableRemoteMedia: false,
//            enableRedirection: true
//        )
//        .sink { compleation in
//            self.handleAPIRequestError(completion: compleation)
//        } receiveValue: { url in
//            do {
//                   self.audioPlayer = try AVAudioPlayer(contentsOf: url)
//                   self.audioPlayer?.prepareToPlay()
//               } catch {
//                   print("failed to setup a live player")
//               }
//               self.isPlaying = true
//        }
//        .store(in: &cancellables)
        
//        UniversalAudioAPI.getUniversalAudioStream(
//              itemId: (currentSong?.id)!,
//              deviceId: UIDevice.vendorUUIDString,
//              userId: SessionManager.main.currentLogin.user.id,
//              audioCodec: "aac",
//              maxStreamingBitrate: tempOverkillBitrate,
//              startTimeTicks: 0,
//              transcodingContainer: "ts",
//              transcodingProtocol: "hls",
//              enableRemoteMedia: true,
//              enableRedirection: true
//          )
//          .sink { compleation in
//              self.handleAPIRequestError(completion: compleation)
//          } receiveValue: { url in
//              do {
//                  self.audioPlayer2 = try AVPlayer(url: url)
//                  self.audioPlayer2?.allowsExternalPlayback = true
//                  self.audioPlayer2?.play()
//              } catch {
//                  print("failed to setup the live audio player, again")
//              }
//
//          }
//          .store(in: &cancellables)
//

        DynamicHlsAPI.getLiveHlsStream(itemId: (currentSong?.id)!)
            .sink { compleation in
                self.handleAPIRequestError(completion: compleation)
            } receiveValue: { url in
                 self.audioPlayer2 = AVPlayer(url: url)
                 self.audioPlayer2?.allowsExternalPlayback = true
                 self.audioPlayer2?.play()
            }
            .store(in: &cancellables)

        //DynamicHlsAPI.getHlsAudioSegment(itemId: , playlistId: , segmentId: , container: , runtimeTicks: , actualSegmentLengthTicks: , liveStreamId: )
        
        
    }
   
    
   private func formatTimeText(value: Double) -> String{
        let hours = Int(value / 3600)
        let minutes: Int = Int(value.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds: Int = Int(value.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
        
        if hours != 0 {
            return "\(Int(hours)):\(String(minutes).leftPad(toWidth: 2, withString: "0")):\(String(seconds).leftPad(toWidth: 2, withString: "0"))"
        } else {
            return "\(String(minutes).leftPad(toWidth: 2, withString: "0")):\(String(seconds).leftPad(toWidth: 2, withString: "0"))"
        }
    }
    
    func replaySong() {
        self.currentTime = 0
        self.audioPlayer?.currentTime = 0
        self.playSong()
    }
    
    func playSong(){
        self.audioPlayer?.play()
    }
    
    func stopSong(){
        self.audioPlayer?.stop()
    }
    
    func skipForward() {
        currentSong = adjacentSongs[2]
    }
    
    func skipBackward() {
        currentSong = adjacentSongs[0]
    }
   
    private func update(){
        currentTime = 0
        isPlaying = false
        audioPlayer = nil
        //pconfigureAudioPlayer()
        configureLiveAudioPlayer()
        getAdjacentSongs()
    }
    
    private func getAdjacentSongs() {
    
        ItemsAPI.getItems(
            userId: SessionManager.main.currentLogin.user.id,
            parentId: currentSong?.albumId ?? ""
        )
        .map{ [weak self] response -> [BaseItemDto] in
            if let items = response.items {
                if (self?.isShuffled ?? false) {
                    return items.shuffled()
                }else {
                    return items.sorted { $0.title < $1.title }
                }
                
            } else {
                return []
            }
        }
        .map{ [weak self] array -> [BaseItemDto] in
            guard let currentSong = self?.currentSong else { return [] }
            let current = array.firstIndex(of: currentSong) ?? 0
            let previous = current == 0 ? (array.count - 1) : (current - 1)
            let next = current == (array.count - 1) ? 0 : current + 1
            return [array[previous], array[current], array[next]]
        }
        .sink { compleation in
            self.handleAPIRequestError(completion: compleation)
        } receiveValue: { [weak self] result in
            self?.adjacentSongs = result
        }
        .store(in: &cancellables)
    }
    
}

