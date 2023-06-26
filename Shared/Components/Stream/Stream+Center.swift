import Granite
import SwiftUI

extension Stream {
    struct Center: GraniteCenter {
        struct State: GraniteState {
        }
        
        @Store public var state: State
    }
    
    var webViewConfig: WebViewConfig {
        .init(.stream(service.state.streamKind),
              isHeadless: true,
              isDebug: false)
    }
}
