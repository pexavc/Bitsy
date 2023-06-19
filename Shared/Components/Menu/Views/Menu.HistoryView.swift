//
//  Home.HistoryView.swift
//  Bitsy
//
//  Created by PEXAVC on 6/19/23.
//

import Foundation
import Granite
import SwiftUI

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
                        .resizable()
                        .font(.title3.bold())
                        .frame(width: 20, height: 20)
                    
                }.buttonStyle(PlainButtonStyle())
            }
            ScrollView([.horizontal]) {
                HStack {
                    ForEach(service.center.$state.binding.history, id: \.self) { item in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(item.kind.wrappedValue.color.opacity(0.5))
                            
                            VStack {
                                Text(item.name.wrappedValue)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                
                                Text(item.kind.wrappedValue.rawValue.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                        }
                        .frame(minWidth: 90)
                        .frame(height: 60)
                        .onTapGesture {
                            center.setStream.send(SetStream.Meta(username: item.name.wrappedValue,
                                                                 kind: item.kind.wrappedValue))
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
}

extension StreamKind {
    var color: Color {
        switch self {
        case .kick:
            return .green
        case .twitch:
            return .purple
        }
    }
}
