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
    @State var dbValue: Float = 0
    @State var sampleValuePeak: Float = 0
    
    public var body: some View {
        ZStack {
            HStack {
                VStack {
                    Text("\(Int(dbValue.isFinite ? dbValue : 0))")
                    Spacer()
                    
                    
                    Rectangle()
                        .foregroundColor(Color.green)
                        .frame(width: 20, height: CGFloat(dbValue.isNaN || dbValue < 0 ? 0 : dbValue))
                }
                .frame(width: 120, height: 120)
                .onReceive(audioSample.$stats) { stats in
                    DispatchQueue.main.async {
                        self.dbValue = stats.disply_dB
                    }
                }
                
            }
            .frame(height: 120)
        }
        .padding(16)
    }
}
