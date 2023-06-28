import Granite
import SwiftUI
import MarbleKit

extension RemoteService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var config: MarbleRemoteConfig? = nil
            
            var username: String = ""
            var streamKind: MarbleRemoteConfig.StreamConfig.Kind = .kick
            var isLoadingStream: Bool = false
            
            var streamURLString: String? = nil
        }
        
        @Event var reset: Reset.Reducer
        @Event var setStream: SetStream.Reducer
        @Event var set: Set.Reducer
        
        @Store(persist: "bitsy.remote.persistence.0003",
               autoSave: true,
               preload: true) public var state: State
    }
}
