import Granite
import SwiftUI
import Foundation
import MarbleKit

extension Menu {
    struct Clip: GraniteReducer {
        typealias Center = Menu.Center
        
        func reduce(state: inout Center.State) {
            MarbleRemote.current.clip()
        }
    }
}
