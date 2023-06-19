import Granite
import SwiftUI

extension RemoteService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var config: VideoConfig? = nil
            var history: [VideoConfig] = []
        }
        
        @Event var reset: Reset.Reducer
        @Event var set: Set.Reducer
        @Event var clearHistory: ClearHistory.Reducer
        
        @Store(persist: "bitsy.remote.persistence.0000", autoSave: true) public var state: State
    }
}
