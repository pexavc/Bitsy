//
//  ConfigService._.swift
//  Bitsy
//
//  Created by PEXAVC on 7/3/23.
//

import Foundation
import Granite
import SwiftUI
import MarbleKit

extension ConfigService {
    struct EnableClipping: GraniteReducer {
        typealias Center = ConfigService.Center
        
        @Payload var meta: GraniteToggle.Meta?
        
        func reduce(state: inout Center.State) {
            Clip.childDebug = true
            state.enableClipping = meta?.isEnabled == true
            MarblePlayerOptions.isVideoClippingEnabled = meta?.isEnabled == true
            if meta?.isEnabled == false {
                MarbleRemote.current.clearClipCache()
            }
        }
    }
}
