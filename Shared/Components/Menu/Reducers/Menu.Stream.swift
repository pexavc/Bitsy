//
//  Home.SetStream.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Granite
import SwiftUI
import MarbleKit

extension Menu {
    struct SetStream: GraniteReducer {
        typealias Center = Menu.Center
        
        struct Meta: GranitePayload {
            var username: String
            var kind: MarbleRemoteConfig.StreamConfig.Kind
        }
        
        @Relay var service: RemoteService
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            state.errorMessage = nil
            
            service.preload()
            
            print("[Menu.Stream.SetStream] \(meta?.username) \(state.username)")
            
            let sanitized = (meta?.username ?? state.username).trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard sanitized.isEmpty == false else {
                state.errorMessage = "Please enter a valid username"
                return
            }
            
            MarbleRemote.current.shutdown()
            
            let streamKind: MarbleRemoteConfig.StreamConfig.Kind = meta?.kind ?? state.streamKind
            
            var baseURLString: String = "https://"
            
            switch streamKind {
            case .kick:
                baseURLString += "kick.com/"
            case .twitch:
                baseURLString += "twitch.tv/"
            }
            
            baseURLString += sanitized
            
            print("[Menu.Stream.SetStream] Setting StreamURL: \(baseURLString)")
            
            service
                .center
                .setStream
                .send(RemoteService.SetStream.Meta(username: sanitized,
                                                   kind: streamKind,
                                                   urlString: baseURLString))
            
            state.showUsernameEntry = false
        }
    }
    
    struct ToggleEditStream: GraniteReducer {
        typealias Center = Menu.Center
        
        func reduce(state: inout Center.State) {
            state.showUsernameEntry.toggle()
        }
    }
    
    struct RenderStream: GraniteReducer {
        typealias Center = Menu.Center
        
        func reduce(state: inout Center.State) {
            state.showUsernameEntry = false
        }
    }
}
