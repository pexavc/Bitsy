//
//  HomeComponent.swift
//  PEX
//
//  Created by PEXAVC on 7/18/22.
//  Copyright (c) 2022 Stoic Collective, LLC.. All rights reserved.
//
import Granite
import SwiftUI
import Combine

struct Menu: GraniteComponent {
    @Command var center: Center
    @Relay var service: RemoteService
    
    
    @State public var action = WebViewAction.idle
    @State public var state = WebViewState.empty
}

