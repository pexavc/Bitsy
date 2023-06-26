//
//  CanvasComponent.swift
//  marble
//
//  Created by 0xKala on 2/26/21.
//  Copyright (c) 2021 Stoic Collective, LLC.. All rights reserved.
//

import Granite
import SwiftUI
import Combine
import GraniteML
import MarbleKit
import MetalKit
import AVKit

struct Canvas: GraniteComponent {
    @Command var center: Center
    
    var config: MarbleRemoteConfig
    
    @State var texture: MTLTexture? = nil
    
    init(config: MarbleRemoteConfig) {
        self.config = config
        MarbleRemote.enableFX = false
        MarblePlayerOptions.isVideoClippingEnabled = false
    }
}
