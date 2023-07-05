import Granite
import SwiftUI
import MarbleKit

extension ConfigService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var history: [MarbleRemoteConfig] = []
            var enableClipping: Bool = false
        }
        
        @Event var setHistory: SetHistory.Reducer
        @Event var clearHistory: ClearHistory.Reducer
        
        @Event var enableClipping: EnableClipping.Reducer
        
        @Store(persist: "bitsy.config.persistence.0000",
               autoSave: true,
               preload: true) public var state: State
    }
}
