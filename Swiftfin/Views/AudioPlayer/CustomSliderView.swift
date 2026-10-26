//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import SwiftUI

struct CustomSliderView: View{
   
    @Binding var value: Double
    @Binding var isUserEditing: Bool
    
    var currentWidth: CGFloat {
        return value / distance * (size.width + 10)
    }
    
    var distance: CGFloat {
        range.upperBound - range.lowerBound
    }
    
    var range: ClosedRange<CGFloat>
    
    @State var size: CGSize = .zero
    
    init(value: Binding<Double>, isUserEditing: Binding<Bool>, range: ClosedRange<CGFloat>){
        self._value = value
        self._isUserEditing = isUserEditing
        self.range = range
    }
    
    var body: some View{
            
        GeometryReader{ geo in
            
            ZStack(alignment: .leading){
                
                Capsule()
                    .foregroundColor(.systemFill)
                    .frame(width: isUserEditing ? geo.size.width + 10 : geo.size.width)
                              
                Rectangle()
                    .foregroundColor(isUserEditing ? .primary : .secondary)
                    .frame(width: isUserEditing ? currentWidth : ((currentWidth - 10) < 0 ? 0 : (currentWidth - 10)))
                    
            }
            .clipShape(Capsule())
            .offset(x: isUserEditing ? -5 : 0)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let value = value.startLocation.x + value.translation.width
                        guard value <= geo.size.width + 10 && value >= 0 else { return }
                        self.value = Double(distance * value / (size.width + 10))
                        
                        guard !isUserEditing else { return }

                        withAnimation (Animation.easeInOut(duration: 0.2)){
                            isUserEditing = true
                        }
                    }
                    .onEnded{ value in
                        withAnimation(Animation.easeInOut(duration: 0.2)){
                            isUserEditing = false
                        }
                    }
            )
            .animation(.default, value: currentWidth)
            .onAppear{
                size = geo.size
            }
        }
        .frame(height: isUserEditing ? 14 : 7)
     
    }
}
