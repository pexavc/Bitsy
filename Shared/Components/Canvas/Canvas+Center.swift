//
//  Canvas+Center.swift
//  PEX
//
//  Created by PEXAVC on 8/8/22.
//

import Foundation
import Granite
import MarbleKit
import SwiftUI

extension Canvas {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            
        }
        
        @Store var state: State
    }
}
