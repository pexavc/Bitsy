//
//  WebView.Coordinator.Helpers.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Fuzi

extension WebViewCoordinator {
    func bypassSteps() {
        webView.action = .evaluateJS("document.documentElement.outerHTML.toString()") { [weak self] result in
            switch result {
            case .success(let any):
                if let htmlString = any as? String {
                    self?.bypasser?.updateHTML(htmlString)
                    
                    if self?.webView.config.isDebug == true || self?.bypasser?.isComplete == true ||
                        self?.webView.config.disableContentBypass == true {
                        self?.updateContentURL()
                    } else if let step = self?.bypasser?.nextStep {
                        self?.webView.action = step.trigger { result in
                            self?.bypasser?.update(step, state: result)
                            
                            guard result else { return }
                            
                            self?.webView.action = .reload
                        }
                    }
                }
            default:
                print("[WebView.Coordinator.Helpers] Failed to retrieve DOM.")
            }
        }
    }
    
    func updateContentURL(_ url: URL? = nil) {
        var newState = self.webView.state
        newState.contentURL = url ?? self.bypasser?.getURL()
        self.webView.state = newState
    }
}
