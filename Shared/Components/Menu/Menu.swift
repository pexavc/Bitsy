//
//  HomeComponent.swift
//  PEX
//
//  Created by PEXAVC on 7/18/22.
//
//
import Granite
import SwiftUI
import Combine

struct Menu: GraniteComponent {
    @Command var center: Center
    @Relay var service: RemoteService
}

