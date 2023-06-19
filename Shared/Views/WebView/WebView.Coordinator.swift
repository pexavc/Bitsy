//
//  WebView.Actions.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import WebKit
import AVKit

public class WebViewCoordinator: NSObject {
    let webView: WebView
    let bypasser: WallBypasser?
    var actionInProgress = false
    
    init(webView: WebView) {
        self.webView = webView
        
        switch webView.config.contentKind {
        case .stream(let kind):
            self.bypasser = .init(kind)
        default:
            self.bypasser = nil
        }
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WebViewCoordinator.updateNetworkLog), name: .didReceiveURLResponse, object: nil)
    }
    
    func setLoading(_ isLoading: Bool,
                    canGoBack: Bool? = nil,
                    canGoForward: Bool? = nil,
                    error: Error? = nil) {
        var newState =  webView.state
        newState.isLoading = isLoading
        if let canGoBack = canGoBack {
            newState.canGoBack = canGoBack
        }
        if let canGoForward = canGoForward {
            newState.canGoForward = canGoForward
        }
        if let error = error {
            newState.error = error
        }
        webView.state = newState
        webView.action = .idle
        actionInProgress = false
    }
}

extension WebViewCoordinator: WKNavigationDelegate, WKScriptMessageHandlerWithReply, WKScriptMessageHandler {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setLoading(false,
                   canGoBack: webView.canGoBack,
                   canGoForward: webView.canGoForward)
        
        webView.evaluateJavaScript("document.title") { (response, error) in
            if let title = response as? String {
                var newState = self.webView.state
                newState.pageTitle = title
                self.webView.state = newState
            }
        }
        
        webView.evaluateJavaScript("document.URL.toString()") { (response, error) in
            if let url = response as? String {
                var newState = self.webView.state
                newState.pageURL = url
                self.webView.state = newState
            }
        }
        
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (response, error) in
            if let html = response as? String {
                if self.webView.htmlInState {
                    var newState = self.webView.state
                    newState.pageHTML = html
                    self.webView.state = newState
                }
                
                self.bypasser?.updateHTML(html)
                
                //TODO: Kick might need a delayed wall check.
                if self.bypasser?.detectedWall == true {
//                    if webView.config.disableContentBypass == false {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//                            self?.bypassSteps()
//                        }
//                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.bypassSteps()
                    }
                }
            }
        }
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        setLoading(false)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        setLoading(false, error: error)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        setLoading(true)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        setLoading(true,
                   canGoBack: webView.canGoBack,
                   canGoForward: webView.canGoForward)
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let host = navigationAction.request.url?.host {
            if self.webView.restrictedPages?.first(where: { host.contains($0) }) != nil {
                decisionHandler(.cancel)
                setLoading(false)
                return
            }
        }
        
        if let url = navigationAction.request.url,
           let scheme = url.scheme,
           let schemeHandler = self.webView.schemeHandlers[scheme] {
            schemeHandler(url)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage,
                                      replyHandler: @escaping (Any?, String?) -> Void) {
        
        if message.name == "callbackHandler" {
            if let messageString = message.body as? String {
                if messageString.contains("StreamURL") {
                    
                    let sanitized: String = messageString.replacingOccurrences(of: "StreamURL:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if let url = URL(string: sanitized) {
                        
                        print("[WebView.Coordinator] Found StreamURL: \(sanitized)")
                        
                        updateContentURL(url)
                    }
                } else if messageString == "VideoIsPlaying" {
                    print("[WebViewCoordinator] Content started.")
                    webView.state.contentStarted = true
                    
                    guard webView.state.contentURL == nil else { return }
                    
                    DispatchQueue.main.async {
                        //After the stream loads on Twitch we will swizzle requests to get the .m3u8 stream file
                        URLProtocol.registerClass(SwizzleURLProtocol.self)
                        URLProtocol.wk_register(scheme: "https")
                        URLProtocol.wk_register(scheme: "http")
                    }
                }
            }
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            print("LOG: \(message.body)")
        }
    }
    
    @objc func updateNetworkLog(notification: NSNotification) {
        if let response = notification.userInfo?["response"] as? URLResponse {
            DispatchQueue.main.async { [weak self] in
                if let url = response.url,
                   url.absoluteString.contains(".m3u8"),
                   self?.webView.state.contentURL == nil {
                    self?.updateContentURL(url)
                    
                    DispatchQueue.main.async {
                        //Remove registry.
                        URLProtocol.unregisterClass(SwizzleURLProtocol.self)
                        URLProtocol.wk_unregister(scheme: "https")
                        URLProtocol.wk_unregister(scheme: "http")
                    }
                }
            }
        }
    }
}
