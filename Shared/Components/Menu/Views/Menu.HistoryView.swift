//
//  Home.HistoryView.swift
//  Bitsy
//
//  Created by PEXAVC on 6/19/23.
//

import Foundation
import Granite
import SwiftUI
import MarbleKit

extension Menu {
    var historyView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("History: ")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    service.center.clearHistory.send()
                } label : {
                    
                    Image(systemName: "trash")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                }.buttonStyle(PlainButtonStyle())
            }
            
            ScrollView([.horizontal], showsIndicators: false) {
                HStack {
                    ForEach(service.center.$state.binding.history, id: \.self) { item in
                        VStack {
                            Text(item.name.wrappedValue)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            
                            Text(item.kind.wrappedValue.rawValue.capitalized)
                                .font(.footnote)
                                .foregroundColor(.white)
                        }
                        .frame(minWidth: 90)
                        .frame(height: 40)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(item.kind.wrappedValue.color))
                        .onTapGesture {
                            center.setStream.send(SetStream.Meta(username: item.name.wrappedValue,
                                                                 kind: item.kind.wrappedValue))
                        }
                    }
                }
            }
        }
    }
}

extension MarbleRemoteConfig.StreamConfig.Kind {
    var color: Color {
        switch self {
        case .kick:
            return .green
        case .twitch:
            return .purple
        }
    }
}
