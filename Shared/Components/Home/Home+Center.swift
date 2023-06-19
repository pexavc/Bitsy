//
//  HomeState.swift
//  PEX
//
//  Created by PEXAVC on 7/18/22.
//  Copyright (c) 2022 Stoic Collective, LLC.. All rights reserved.
//
import Granite
import GraniteUI
import SwiftUI
import Combine

extension Home {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var username: String = ""
            var streamKind: StreamKind = .kick
            var streamURLString: String? = nil
            var showUsernameEntry: Bool = true
            var isLoadingStream: Bool = false
            var errorMessage: String? = nil
        }

        @Event var reset: Reset.Reducer
        @Event var toggleEditStream: ToggleEditStream.Reducer
        @Event var setStream: SetStream.Reducer
        @Event var renderStream: RenderStream.Reducer
        
        @Store public var state: Center.State
    }
    
    var webViewConfig: WebViewConfig {
        .init(.stream(state.streamKind),
              isHeadless: true,
              isDebug: false)
    }
}
