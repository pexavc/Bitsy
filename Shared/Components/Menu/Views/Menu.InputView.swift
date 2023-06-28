//
//  Home.InputView.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Granite
import SwiftUI
import MarbleKit

extension Menu {
    var streamIsActive: Bool {
        (state.showUsernameEntry &&
            service.state.config != nil) ||
            (state.showUsernameEntry &&
             service.state.isLoadingStream)
    }
    
    var inputView: some View {
        ZStack {
            VStack {
                
                Spacer()
                
                if state.showUsernameEntry && service.state.history.isEmpty == false {
                    
                    HStack {
                        historyView
                            .frame(maxWidth: 200)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.75))
                            )
                        
                        Spacer()
                    }
                }
                
                if state.showUsernameEntry {
                    HStack {
                        
                        usernameEntry
                            .frame(maxWidth: 200)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.75))
                            )
                        
                        Spacer()
                    }
                }
                
                controlView
                    .frame(height: Menu.controlsHeight - 16 - 4, alignment: .bottom)
            }
            
            VStack {
                Spacer()
                if state.fxEnabled {
                    fxView
                }
            }
            .padding(.bottom, (Menu.controlsHeight - 16 - 4) + 10)//10 = default V stack padding
        }
        .animation(.default, value: state.showUsernameEntry)
        .padding(16)
    }
    
    var usernameEntry: some View {
        VStack(spacing: 0) {
            Text("Bitsy")
                .font(.title.bold())
            
            TextField(
                "\(state.streamKind.rawValue.capitalized) username",
                text: _state.username
            )
            .autocorrectionDisabled()
            .textFieldStyle(PlainTextFieldStyle())
            .font(.title3.bold())
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(.top, 16)
            
            HStack {
                #if os(iOS)
                Picker(selection: center.$state.binding.streamKind,
                       label: Text("Site:")) {
                    ForEach(MarbleRemoteConfig.StreamConfig.Kind.allCases, id: \.self) { kind in
                        Text(kind.rawValue.capitalized)
                            .font(.headline.bold())
                            .cornerRadius(8)
                            .tag(kind)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.white.opacity(0.15))
                )
                #elseif os(macOS)
                Picker(selection: center.$state.binding.streamKind,
                       label: Text("Site:")) {
                    ForEach(MarbleRemoteConfig.StreamConfig.Kind.allCases, id: \.self) { kind in
                        Text(kind.rawValue.capitalized).tag(kind)
                    }
                }.pickerStyle(RadioGroupPickerStyle())
                #endif
                
                Spacer()
                
                Button {
                    center.setStream.send()
                } label: {
                    Image(systemName: "arrow.right.square.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }.buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 16)
            
            if let errorMessage = state.errorMessage {
                Text(errorMessage)
                    .font(.body.bold())
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
}
