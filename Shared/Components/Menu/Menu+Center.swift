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

extension Menu {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var username: String = ""
            var streamKind: StreamKind = .kick
            
            var showUsernameEntry: Bool = true
            var errorMessage: String? = nil
        }

        @Event var reset: Reset.Reducer
        @Event var toggleEditStream: ToggleEditStream.Reducer
        @Event var setStream: SetStream.Reducer
        @Event var renderStream: RenderStream.Reducer
        
        @Store public var state: Center.State
    }
}
