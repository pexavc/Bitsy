import Granite
import SwiftUI
import Foundation
import MarbleKit

extension Menu {
    enum Controls {
        case clip
        case toggleFX
        case modifyFX(MarbleEffect)
    }
    
    struct Control: GraniteReducer {
        typealias Center = Menu.Center
        
        struct Meta: GranitePayload {
            var control: Menu.Controls
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            switch meta?.control {
            case .clip:
                MarbleRemote.current.clip()
            case .toggleFX:
                //MarbleRemote.enableFX.toggle()
                state.fxEnabled.toggle()
            case .modifyFX(let effect):
                var currentFX: [MarbleEffect] = state.fx
                let lastCount = currentFX.count
                currentFX.removeAll { $0.rawValue == effect.rawValue }
                if currentFX.count == lastCount,
                   lastCount < 3 {
                    currentFX.append(effect)
                }
                state.fx = currentFX
                MarbleRemote.fx = state.fx
            default:
                break
            }
        }
    }
}
