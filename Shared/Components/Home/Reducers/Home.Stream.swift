//
//  Home.SetStream.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Granite
import SwiftUI

extension Home {
    struct SetStream: GraniteReducer {
        typealias Center = Home.Center
        
        struct Meta: GranitePayload {
            var kind: StreamKind
        }
        
        @Relay var service: RemoteService
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            if let kind = meta?.kind {
                state.streamKind = kind
            }
            
            state.errorMessage = nil
            state.streamURLString = nil
            
            let sanitized = state.username.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard sanitized.isEmpty == false else {
                state.errorMessage = "Please enter a valid username"
                return
            }
            
            service.preload()
            
            service.center.reset.send()
            
            var baseURLString: String = "https://"
            
            switch state.streamKind {
            case .kick:
                baseURLString += "kick.com/"
            case .twitch:
                baseURLString += "twitch.tv/"
            }
            
            baseURLString += sanitized
            
            print("[Home.Stream.SetStream] Setting StreamURL: \(baseURLString)")
            
            state.streamURLString = baseURLString
            
            state.showUsernameEntry = false
            state.isLoadingStream = true
        }
    }
    
    struct ToggleEditStream: GraniteReducer {
        typealias Center = Home.Center
        
        func reduce(state: inout Center.State) {
            state.showUsernameEntry.toggle()
        }
    }
    
    struct RenderStream: GraniteReducer {
        typealias Center = Home.Center
        
        func reduce(state: inout Center.State) {
            state.showUsernameEntry = false
            state.isLoadingStream = false
        }
    }
}
