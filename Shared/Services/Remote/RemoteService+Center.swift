import Granite
import SwiftUI

extension RemoteService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var config: VideoConfig? = nil
            var history: [VideoConfig] = []
            
            var username: String = ""
            var streamKind: StreamKind = .kick
            var isLoadingStream: Bool = false
            
            var streamURLString: String? = nil
        }
        
        @Event var reset: Reset.Reducer
        @Event var setStream: SetStream.Reducer
        @Event var set: Set.Reducer
        @Event var clearHistory: ClearHistory.Reducer
        
        @Store(persist: "bitsy.remote.persistence.0001",
               autoSave: true,
               preload: true) public var state: State
    }
}
