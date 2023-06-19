import Granite
import SwiftUI
import Foundation

extension Menu {
    struct DidAppear: GraniteReducer {
        typealias Center = Menu.Center
        
        func reduce(state: inout Center.State) {
        }
    }
    
    struct Reset: GraniteReducer {
        typealias Center = Menu.Center
        
        @Relay var service: RemoteService
        
        func reduce(state: inout Center.State) {
            state.errorMessage = nil
            state.showUsernameEntry = true
            service.center.reset.send()
        }
    }
}
