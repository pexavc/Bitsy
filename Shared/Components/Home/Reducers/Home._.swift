import Granite
import SwiftUI
import Foundation

extension Home {
    struct DidAppear: GraniteReducer {
        typealias Center = Home.Center
        
        func reduce(state: inout Center.State) {
        }
    }
    
    struct Reset: GraniteReducer {
        typealias Center = Home.Center
        
        @Relay var service: RemoteService
        
        func reduce(state: inout Center.State) {
            state.username = ""
            state.errorMessage = nil
            state.streamURLString = nil
            state.showUsernameEntry = true
            state.isLoadingStream = false
            service.center.reset.send()
        }
    }
}
