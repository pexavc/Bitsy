//
//  HomeState.swift
//  PEX
//
//  Created by PEXAVC on 7/18/22.
// 
//
import Granite
import GraniteUI
import SwiftUI
import Combine
import MarbleKit

extension Menu {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var username: String = ""
            var username2: String = ""
            var streamKind: MarbleRemoteConfig.StreamConfig.Kind = .kick
            
            var showUsernameEntry: Bool = true
            var errorMessage: String? = nil
            
            var fxEnabled: Bool = MarbleRemote.enableFX
            var fx: [MarbleEffect] = MarbleRemote.fx
        }

        @Event var reset: Reset.Reducer
        @Event var toggleEditStream: ToggleEditStream.Reducer
        @Event var setStream: SetStream.Reducer
        @Event var renderStream: RenderStream.Reducer
        
        @Event var control: Control.Reducer
        
        @Store public var state: Center.State
    }
}
