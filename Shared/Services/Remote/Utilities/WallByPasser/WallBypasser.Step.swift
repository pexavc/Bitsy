//
//  WallBypasser.Step.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Granite
import MarbleKit

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

extension MarbleRemoteConfig.StreamConfig.Kind {
    var bypassSteps: [WallBypasser.Step] {
        switch self {
        case .kick:
            return [
                .init(targetInnerText: "Start watching",
                      detectionText: "This content has been marked as mature. You must be 18 or older to view this content.",
                      kind: .button),
                .init(targetInnerText: "Accept",
                      detectionText: "Kick uses cookies to improve user experience and site performance, offer content tailored to your interests and enable social media sharing. By clicking \"Agree\" or continuing to use our site, you agree to our use of cookies and our Privacy Policy.",
                      kind: .button)
            ]
        case .twitch:
            return [
                .init(targetInnerText: "Start Watching",
                      detectionText: "The broadcaster has indicated that this channel is intended for mature audiences.",
                      kind: .button),
                //Mobile view has a slightly different variation of above
                .init(targetInnerText: "Start Watching",
                      detectionText: "The broadcaster indicated that this channel is intended for mature audiences.",
                      kind: .button),
                //Another variant
                .init(targetInnerText: "Start Watching",
                      detectionText: "content is intended for certain audiences",
                      kind: .button)
            ]
        }
    }
}
