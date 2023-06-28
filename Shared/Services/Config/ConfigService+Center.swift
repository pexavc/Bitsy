import Granite
import SwiftUI
import MarbleKit

extension ConfigService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var history: [MarbleRemoteConfig] = []
        }
        
        @Event var setHistory: SetHistory.Reducer
        @Event var clearHistory: ClearHistory.Reducer
        
        @Store(persist: "bitsy.config.persistence.0000",
               autoSave: true,
               preload: true) public var state: State
    }
}
