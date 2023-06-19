//
//  WebView.swift
//  Bitsy
//
//  Created by PEXAVC on 6/17/23.
//

import Foundation
import SwiftUI
import WebKit
import Granite

//MARK: WebView Representable

extension WebViewCoordinator: WKUIDelegate {
  public func webView(_ webView: WKWebView,
                      createWebViewWith configuration: WKWebViewConfiguration,
                      for navigationAction: WKNavigationAction,
                      windowFeatures: WKWindowFeatures) -> WKWebView? {
    if navigationAction.targetFrame == nil {
      webView.load(navigationAction.request)
    }
    return nil
  }
}

fileprivate func createHandler(_ handler: WKScriptMessageHandlerWithReply) -> WKUserContentController {
    let contentController = WKUserContentController()

    contentController.addScriptMessageHandler(handler, contentWorld: .page, name: "callbackHandler")
    
    return contentController
}

fileprivate func loadedJSCallback(_ controller: WKUserContentController) {
    if let jsSource = Bundle.main.url(forResource: "LoadState", withExtension: "js"),
        let jsSourceString = try? String(contentsOf: jsSource) {
        let userScript = WKUserScript(source: jsSourceString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        controller.addUserScript(userScript)
    }
}

fileprivate func videoEventJSCallback(_ controller: WKUserContentController) {
    if let jsSource = Bundle.main.url(forResource: "VideoPlayerEvent", withExtension: "js"),
        let jsSourceString = try? String(contentsOf: jsSource) {
        let userScript = WKUserScript(source: jsSourceString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        controller.addUserScript(userScript)
    }
}

fileprivate func xhrEventJSCallback(_ controller: WKUserContentController) {
    if let jsSource = Bundle.main.url(forResource: "InterceptXHR", withExtension: "js"),
        let jsSourceString = try? String(contentsOf: jsSource) {
        let userScript = WKUserScript(source: jsSourceString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        controller.addUserScript(userScript)
    }
}

#if os(iOS)
public struct WebView: UIViewRepresentable {
    let config: WebViewConfig
    @Binding var action: WebViewAction
    @Binding var state: WebViewState
    let restrictedPages: [String]?
    let htmlInState: Bool
    let schemeHandlers: [String: (URL) -> Void]
    
    public init(config: WebViewConfig = .default,
                action: Binding<WebViewAction>,
                state: Binding<WebViewState>,
                restrictedPages: [String]? = nil,
                htmlInState: Bool = false,
                schemeHandlers: [String: (URL) -> Void] = [:]) {
        self.config = config
        _action = action
        _state = state
        self.restrictedPages = restrictedPages
        self.htmlInState = htmlInState
        self.schemeHandlers = schemeHandlers
    }
    
    public func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(webView: self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = config.javaScriptEnabled
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = config.allowsInlineMediaPlayback
        configuration.mediaTypesRequiringUserActionForPlayback = config.mediaTypesRequiringUserActionForPlayback
        configuration.preferences = preferences
        configuration.userContentController = createHandler(context.coordinator)
        loadedJSCallback(configuration.userContentController)
        videoEventJSCallback(configuration.userContentController)
        xhrEventJSCallback(configuration.userContentController)
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = config.allowsBackForwardNavigationGestures
        webView.scrollView.isScrollEnabled = config.isScrollEnabled
        webView.isOpaque = config.isOpaque
        if #available(iOS 14.0, *) {
            webView.backgroundColor = UIColor(config.backgroundColor)
        } else {
            webView.backgroundColor = .clear
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        if action == .idle || context.coordinator.actionInProgress {
            return
        }
        
        DispatchQueue.main.async {
            execute(action: self.action, uiView, context)
        }
    }
}
#endif

#if os(macOS)
public struct WebView: NSViewRepresentable {
    let config: WebViewConfig
    @Binding var action: WebViewAction
    @Binding var state: WebViewState
    
    let restrictedPages: [String]?
    let htmlInState: Bool
    let schemeHandlers: [String: (URL) -> Void]
    
    public init(config: WebViewConfig = .default,
                action: Binding<WebViewAction>,
                state: Binding<WebViewState>,
                restrictedPages: [String]? = nil,
                htmlInState: Bool = false,
                schemeHandlers: [String: (URL) -> Void] = [:]) {
        self.config = config
        _action = action
        _state = state
        self.restrictedPages = restrictedPages
        self.htmlInState = htmlInState
        self.schemeHandlers = schemeHandlers
    }
    
    public func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(webView: self)
    }
    
    public func makeNSView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = config.javaScriptEnabled
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = createHandler(context.coordinator)
        loadedJSCallback(configuration.userContentController)
        videoEventJSCallback(configuration.userContentController)
        xhrEventJSCallback(configuration.userContentController)
        
        
        //Inspector
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(context.coordinator, name: "logHandler")
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = config.allowsBackForwardNavigationGestures
        
        //Swizzle
        
        return webView
    }
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        if action == .idle || context.coordinator.actionInProgress {
            return
        }
        
        DispatchQueue.main.async {
            execute(action: self.action, nsView, context)
        }
    }
}
#endif
