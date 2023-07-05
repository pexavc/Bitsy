//
//  CustomSlider.swift
//  Nea
//
//  Created by PEXAVC on 5/14/23.
//

import Foundation
import SwiftUI

struct CustomSliderView: View {
    @Binding var value: Double
    
    var showValue: Bool = false
    var blurBG: Bool = false
    var fastUpdate: Bool = false
    
    @State var UIValue: Double?
    
    var color: Color
    
    @State var currentValue: Double = 0.0
    @State var lastCoordinateValue: CGFloat = 0.0
    
    var body: some View {
        slider
    }
    
    var slider: some View {
        GeometryReader { gr in
            let size = gr.frame(in: .local).size
            let cursorSize = size.height * 0.8
            let radius = size.height * 0.5
            let minValue: Double = 0//gr.size.width * 0.015
            let maxValue = (size.width) - cursorSize//(gr.size.width * 0.98) - cursorSize
            
            let width = maxValue - minValue
            
            return ZStack {
                RoundedRectangle(cornerRadius: radius)
                    .foregroundColor(color)
                
                HStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: cursorSize, height: cursorSize)
                        .offset(x: self.UIValue ?? (self.currentValue * width))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateValue = self.UIValue ?? (self.currentValue * width)
                                    }
                                    
                                    if v.translation.width > 0 {
                                        self.UIValue = (min(maxValue, self.lastCoordinateValue + v.translation.width))
                                    } else {
                                        self.UIValue = (max(minValue, self.lastCoordinateValue + v.translation.width))
                                    }
                                    
                                    DispatchQueue.main.async {
                                        if let uival = self.UIValue {
                                            self.currentValue = uival / maxValue
                                        }
                                        
                                        if fastUpdate {
                                            self.value = self.currentValue
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    self.value = self.currentValue
                                }
                        )
                    
                    Spacer()
                }
            }
            .onAppear {
                self.currentValue = value
            }
        }
    }
}
