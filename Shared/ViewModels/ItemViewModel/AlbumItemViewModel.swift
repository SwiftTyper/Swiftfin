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
import Defaults
import SwiftUI

final class AlbumItemViewModel: ItemViewModel {
    
    @Published var albumItems : [BaseItemDto] = []
    @Published var selectedSong : BaseItemDto?
    @Published var backgroundColor: Color?
    @Published var textColor: Color?
    @Published var secondIsLoading: Bool = false
    
    override init(item:BaseItemDto) {
        super.init(item: item)
        setup()
    }
    
    func setup(){

        secondIsLoading = true
        
        Publishers.CombineLatest(self.getSongs(), self.getDominantColor())
            .map{ [weak self] songs, backgroundColor -> ([BaseItemDto], Color?, Color?) in
                let textColor = self?.getOppositeToDominantColor(backgroundColor: backgroundColor)
                return (songs, backgroundColor, textColor)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] compleation in
                self?.handleAPIRequestError(completion: compleation)
            }, receiveValue: { [weak self] (songs, backgroundColor, textColor) in
                
                self?.albumItems = songs
                self?.backgroundColor = backgroundColor
                self?.textColor = textColor
                self?.secondIsLoading = false
            })
            .store(in: &self.cancellables)
    }
    

    func getDominantColor() -> AnyPublisher<Color?,Error> {
        
        return URLSession.shared.dataTaskPublisher(for: URLRequest(url: item.imageURL(.primary, maxWidth: 100)))
            .tryMap{ data, response -> UIImage? in
                return UIImage(data: data)
            }
            .tryMap { image -> [UIColor] in
                guard let image = image else { return [] }
                let smallImage = image.resize(desired: CGSize(width: 100, height: 100))
                let kMeans = KMeansClusterer()
                let points = smallImage.getColors().map({KMeansClusterer.Point(from: $0)})
                let clusters = kMeans.cluster(points: points, into: 3).sorted(by: {$0.points.count > $1.points.count})
                let colors = clusters.map(({$0.center.toUIColor()}))
                return colors
            }
            .tryMap { colors -> Color? in
                guard let mainColor = colors.first else {
                    return nil
                }
                return Color(uiColor: mainColor)
            }
            .eraseToAnyPublisher()
           
    }
    
    func getOppositeToDominantColor(backgroundColor: Color?) -> Color?{
        let textColor = backgroundColor != nil ? UIColor(backgroundColor!).hslColor.shiftHue(by: 0.5).shiftSaturation(by: -0.5).shiftBrightness(by: 0.5).uiColor : nil
        return textColor != nil ? Color(uiColor: textColor!) : nil
    }
    
    func getSongs() -> AnyPublisher<[BaseItemDto], Error> {
        ItemsAPI.getItems(
            userId: SessionManager.main.currentLogin.user.id,
            parentId: item.id
        )
        .map { response -> [BaseItemDto] in
            if let items = response.items {
                return items.sorted { $0.title < $1.title }
            } else {
                return []
            }
        }
        .eraseToAnyPublisher()
   
    }
}


    
class KMeansClusterer {
    func cluster(points : [Point], into k : Int) -> [Cluster] {
        var clusters = [Cluster]()
        for _ in 0 ..< k {
            var p = points.randomElement()
            while p == nil || clusters.contains(where: {$0.center == p}) {
                p = points.randomElement()
            }
            clusters.append(Cluster(center: p!))
        }
        
        for i in 0 ..< 10 {
            clusters.forEach {
                $0.points.removeAll()
            }
            for p in points {
                let closest = findClosest(for: p, from: clusters)
                closest.points.append(p)
            }
            var converged = true
            clusters.forEach {
                let oldCenter = $0.center
                $0.updateCenter()
                if oldCenter.distanceSquared(to: $0.center) > 0.001 {
                    converged = false
                }
            }
            if converged {
                print("Converged. Took \(i) iterations")
                break;
            }
        }
        return clusters
    }
    
    private func findClosest(for p : Point, from clusters: [Cluster]) -> Cluster {
        return clusters.min(by: {$0.center.distanceSquared(to: p) < $1.center.distanceSquared(to: p)})!
    }
}

extension KMeansClusterer {
    class Cluster {
        var points = [Point]()
        var center : Point
        init(center : Point) {
            self.center = center
        }
        func calculateCurrentCenter() -> Point {
            if points.isEmpty {
                return Point.zero
            }
            return points.reduce(Point.zero, +) / points.count
        }
        func updateCenter() {
            if points.isEmpty {
                return
            }
            let currentCenter = calculateCurrentCenter()
            center = points.min(by: {$0.distanceSquared(to: currentCenter) < $1.distanceSquared(to: currentCenter)})!
        }
    }
}

extension KMeansClusterer {
    struct Point : Equatable {
        let x : CGFloat
        let y : CGFloat
        let z : CGFloat
        init(_ x: CGFloat, _ y : CGFloat, _ z : CGFloat) {
            self.x = x
            self.y = y
            self.z = z
        }
        init(from color : UIColor) {
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            var a : CGFloat = 0
            if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
                x = r
                y = g
                z = b
            } else {
                x = 0
                y = 0
                z = 0
            }
        }
        static let zero = Point(0, 0, 0)
        static func == (lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
        }
        static func +(lhs : Point, rhs : Point) -> Point {
            return Point(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
        }
        static func /(lhs : Point, rhs : CGFloat) -> Point {
            return Point(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
        }
        static func /(lhs : Point, rhs : Int) -> Point {
            return lhs / CGFloat(rhs)
        }
        func distanceSquared(to p : Point) -> CGFloat {
            return (self.x - p.x) * (self.x - p.x)
                + (self.y - p.y) * (self.y - p.y)
                + (self.z - p.z) * (self.z - p.z)
        }
        func toUIColor() -> UIColor {
            return UIColor(red: x, green: y, blue: z, alpha: 1)
        }
    }
}

