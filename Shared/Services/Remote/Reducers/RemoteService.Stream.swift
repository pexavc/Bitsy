//
//  RemoteService.Stream.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Granite
import SwiftUI
import MarbleKit

extension RemoteService {
    struct SetStream: GraniteReducer {
        typealias Center = RemoteService.Center
        
        struct Meta: GranitePayload {
            var username: String
            var kind: MarbleRemoteConfig.StreamConfig.Kind
            var urlString: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            state.config = nil
            
            state.streamURLString = meta?.urlString
            state.username = meta?.username ?? ""
            state.streamKind = meta?.kind ?? state.streamKind
            
            state.isLoadingStream = meta?.urlString != nil
        }
    }
    
    struct Set: GraniteReducer {
        typealias Center = RemoteService.Center
        
        struct Meta: GranitePayload {
            var url: URL
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            let config: MarbleRemoteConfig = .init(name: state.username,
                                            kind: state.streamKind,
                                            streams: [
                                                .init(resolution: .p1080,
                                                      streamURL: meta.url)
                                            ])
            
            state.config = config
            
            var newHistory = Array(state.history.prefix(6))
            newHistory.insert(config, at: 0)
            state.history = newHistory
            
            state.isLoadingStream = false
        }
    }
}
