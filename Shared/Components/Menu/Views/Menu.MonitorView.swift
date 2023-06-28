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
    
    static var compactMonitorHeight: CGFloat {
        55
    }
    
    @ObservedObject var buffering: BufferingProgress = .shared
    @ObservedObject var audioSample: AudioSample = .shared
    
    @State var loadState: MarbleMediaLoadState = .idle
    @State var bufferingProgress: Int = 0
    @State var isDroppingFrames: Bool = false
    
    @State var fftBins: [Float] = .init(repeating: 0, count: 16)
    @State var dbValue: Float = 0
    @State var sampleValuePeak: Float = 0
    
    @State var isPlaying: Bool = true
    @State var isMuted: Bool = false
    @State var volume: Double = 0.5
    
    @State var controlsExpanded: Bool = true
    
    public var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        controlsExpanded.toggle()
                    } label: {
                        Image(systemName: "\(controlsExpanded ? "arrow.backward.square" : "slider.horizontal.3")")
                            .font(controlsExpanded ? Font.title.bold() : Font.title3.bold())
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.75))
                    )
                    
                    if controlsExpanded == false {
                        playbackControlsCompact
                    }
                    
                    Spacer()
                }
                
                if controlsExpanded {
                    HStack {
                        playbackControls
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .onReceive(buffering.$stats) { stats in
                self.loadState = stats.loadState
                self.bufferingProgress = stats.progress
                self.isDroppingFrames = stats.isDropping
            }
        }
        .padding(16)
    }
    
    var volumeIcon: String {
        if volume >= 0.25 {
            return "speaker.wave.\(min(3, Int(floor(volume * Double(4))))).fill"
        } else {
            return "speaker.fill"
        }
    }
}

extension MonitorView {
    var playbackControlsCompact: some View {
        HStack {
            HStack {
                Button {
                    isPlaying.toggle()
                    
                    if isPlaying {
                        MarbleRemote.current.play()
                    } else {
                        MarbleRemote.current.pause()
                    }
                } label: {
                    Image(systemName: "\(isPlaying ? "pause.fill" : "play.fill")")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    isMuted.toggle()
                    
                    MarbleRemote.current.isMuted = isMuted
                } label: {
                    Image(systemName: "\(isMuted ? "speaker.slash.fill" : volumeIcon)")
                        .font(.title3.bold())
                        .frame(width: 28)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(height: 18)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
            )
            
            if loadState == .loading {
                HStack {
                    Text("Buffering:")
                        .font(.title3.bold())
                    
                    Text("\(bufferingProgress)%")
                        .font(.title3.bold())
                }
                .frame(height: 18)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.75))
                )
            }
        }
    }
    
    var playbackControls: some View {
        VStack(alignment: .leading) {
            
            ZStack {
                HStack {
                    VStack {
                        Spacer()
                        
                        Rectangle()
                            .foregroundColor(Color.green)
                            .frame(width: 20, height: CGFloat(dbValue.isNaN || dbValue <= 0 ? 1 : dbValue))
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
            }
            .frame(height: 120 + 8)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
            )
            
            HStack {
                Button {
                    isPlaying.toggle()
                    
                    if isPlaying {
                        MarbleRemote.current.play()
                    } else {
                        MarbleRemote.current.pause()
                    }
                } label: {
                    Image(systemName: "\(isPlaying ? "pause.fill" : "play.fill")")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    isMuted.toggle()
                    
                    MarbleRemote.current.isMuted = isMuted
                } label: {
                    Image(systemName: "\(isMuted ? "speaker.slash.fill" : volumeIcon)")
                        .font(.title3.bold())
                        .frame(width: 28)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                CustomSliderView(value: $volume, color: .gray)
                .onChange(of: volume) { newVolume in
                    DispatchQueue.main.async {
                        //guard newVolume != self.volume else { return }
                        MarbleRemote.current.volume = Float(newVolume)
                    }
                }
            }
            .frame(width: 214, height: 24)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
            )
            
            if loadState == .loading {
                HStack {
                    Text("Buffering:")
                        .font(.title3.bold())
                    
                    Text("\(bufferingProgress)%")
                        .font(.title3.bold())
                        .frame(width: 40)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.75))
                )
            }
            
            if isDroppingFrames {
                HStack {
                    Text("Dropping Frames")
                        .font(.title3.bold())
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.75))
                )
            }
        }
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
        .frame(width: (spacing * max(self.bins.count.cgfloat - 1, 0)) + (binWidth * self.bins.count.cgfloat))
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
