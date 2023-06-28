//
//  Remote._.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Granite
import SwiftUI
import MarbleKit

extension RemoteService {
    struct Reset: GraniteReducer {
        typealias Center = RemoteService.Center
        
        func reduce(state: inout Center.State) {
            state.config = nil
            state.username = ""
            state.isLoadingStream = false
            state.streamURLString = nil
            MarbleRemote.current.shutdown()
        }
    }
}
