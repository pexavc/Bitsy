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
    var inputView: some View {
        VStack(spacing: 0) {
            if state.showUsernameEntry {
                usernameEntry
                    .frame(maxWidth: 200)
            } else {
                Spacer()
            }
            
            if state.showUsernameEntry == false {
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button {
                        center.toggleEditStream.send()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .font(.title3.bold())
                            .frame(width: 22, height: 22)
                    }.buttonStyle(PlainButtonStyle())
                    
                    Button {
                        center.clip.send()
                    } label: {
                        Image(systemName: "record.circle")
                            .resizable()
                            .font(.title3.bold())
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        MarbleRemote.enableFX.toggle()
                    } label: {
                        Image(systemName: "record.circle.fill")
                            .resizable()
                            .font(.title3.bold())
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        center.reset.send()
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .resizable()
                            .font(.title3.bold())
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.bottom, 16)
            } else {
                Button {
                    center.reset.send()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .resizable()
                        .font(.title3.bold())
                        .frame(width: 24, height: 24)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 16)
            }
            
            
            if (state.showUsernameEntry &&
                service.state.config != nil) ||
                (state.showUsernameEntry &&
                 service.state.isLoadingStream) {
                
                Button {
                    center.toggleEditStream.send()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .font(.title3.bold())
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .animation(.default, value: state.showUsernameEntry)
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
