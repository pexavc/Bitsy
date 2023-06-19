import Granite
import SwiftUI

extension Stream {
    struct Center: GraniteCenter {
        struct State: GraniteState {
        }
        
        @Store public var state: State
    }
    
    var remote: VideoRemote? {
        if let config = service.state.config {
            return .init(video: config)
        } else {
            return nil
        }
    }
}
