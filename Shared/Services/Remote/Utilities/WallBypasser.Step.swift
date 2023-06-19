//
//  WallBypasser.Step.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Granite

extension WallBypasser {
    struct Step: GraniteModel {
        enum ElementKind: String, GraniteModel {
            case button
        }
        
        let targetInnerText: String
        let detectionText: String
        var kind: ElementKind
        var success: Bool = false
        
        func trigger(_ callback: ((Bool) -> Void)? = nil) -> WebViewAction {
            switch kind {
            case .button:
                return .automateClick(targetInnerText) { result in
                    callback?(result)
                }
            }
        }
        
        mutating func update(_ state: Bool) {
            success = state
        }
        
        var description: String {
            """
            [WallBypasser Step]
            Automating: \(kind.rawValue)
            InnerText: \(targetInnerText)
            """
        }
    }
}

extension StreamKind {
    var bypassSteps: [WallBypasser.Step] {
        switch self {
        case .kick:
            return [
                .init(targetInnerText: "Start watching",
                      detectionText: "",
                      kind: .button),
                .init(targetInnerText: "Accept",
                      detectionText: "",
                      kind: .button)
            ]
        case .twitch:
            return [
                .init(targetInnerText: "Start Watching",
                      detectionText: "The broadcaster has indicated that this channel is intended for mature audiences.",
                      kind: .button)
            ]
        }
    }
}
