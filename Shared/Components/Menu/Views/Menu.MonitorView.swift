//
//  Menu.MonitorView.swift
//  Bitsy
//
//  Created by PEXAVC on 6/24/23.
//

import Foundation
import SwiftUI
import MarbleKit

public struct MonitorView: View {
    @ObservedObject var audioSample: AudioSample = .shared
    @State var fftBins: [Float] = .init(repeating: 0, count: 16)
    @State var dbValue: Float = 0
    @State var sampleValuePeak: Float = 0
    
    public var body: some View {
        ZStack {
            HStack {
                VStack {
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(Color.green)
                        .frame(width: 20, height: CGFloat(dbValue.isNaN || dbValue < 0 ? 0 : dbValue))
                }
                .frame(height: 120)
                
                FFTView(bins: self.fftBins)
                    .frame(height: 120)
            }
            .onReceive(audioSample.$stats) { stats in
                DispatchQueue.main.async {
                    self.dbValue = stats.disply_dB
                    self.fftBins = stats.fft
                }
            }
            
            VStack {
                Text("\(Int(dbValue.isFinite ? dbValue : 0)) dB")
                
                Spacer()
            }
            .frame(height: 120)
            .padding(.bottom, 16)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.75))
        )
        .padding(32)
    }
}

public struct FFTView: View {
    let bins: [Float]
    
    var spacing: CGFloat = 4
    var binWidth: CGFloat = 8
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<bins.count, id: \.self) { index in
                bar(CGFloat(bins[index]))
            }
        }
        .frame(width: (spacing * abs(self.bins.count.cgfloat - 1)) + (binWidth * self.bins.count.cgfloat))
    }
    
    func bar(_ heightN: CGFloat) -> some View {
        var color: Color
        {
            if heightN > 0.8 {
                return .red
            } else if heightN > 0.5 {
                return .orange
            } else {
                return .green
            }
        }
        return VStack {
            Spacer()
            Rectangle()
                .foregroundColor(color)
                .frame(width: binWidth, height: max(heightN * 100, 1))
        }
    }
    
    
}
