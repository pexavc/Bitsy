//
//  ConfigService._.swift
//  Bitsy
//
//  Created by PEXAVC on 6/27/23.
//

import Foundation
import Granite
import SwiftUI
import MarbleKit

extension ConfigService {
    struct SetHistory: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            var config: MarbleRemoteConfig
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            var newHistory = Array(state.history.prefix(6))
            newHistory.insert(meta.config, at: 0)
            state.history = newHistory
        }
    }
    
    struct ClearHistory: GraniteReducer {
        typealias Center = ConfigService.Center
        
        func reduce(state: inout Center.State) {
            state.history = []
        }
    }
}
