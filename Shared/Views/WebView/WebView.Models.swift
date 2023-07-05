//
//  WebView.Models.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import SwiftUI
import WebKit
import MarbleKit

public enum WebViewAction: Equatable {
    case idle,
         load(URLRequest),
         loadHTML(String),
         reload,
         goBack,
         goForward,
         printCookies,
         clearCookies,
         automateClick(String, (Bool) -> Void),
         evaluateJS(String, (Result<Any?, Error>) -> Void)
    
    
    public static func == (lhs: WebViewAction, rhs: WebViewAction) -> Bool {
        if case .idle = lhs,
           case .idle = rhs {
            return true
        }
        if case let .load(requestLHS) = lhs,
           case let .load(requestRHS) = rhs {
            return requestLHS == requestRHS
        }
        if case let .loadHTML(htmlLHS) = lhs,
           case let .loadHTML(htmlRHS) = rhs {
            return htmlLHS == htmlRHS
        }
        if case .reload = lhs,
           case .reload = rhs {
            return true
        }
        if case .goBack = lhs,
           case .goBack = rhs {
            return true
        }
        if case .goForward = lhs,
           case .goForward = rhs {
            return true
        }
        if case let .evaluateJS(commandLHS, _) = lhs,
           case let .evaluateJS(commandRHS, _) = rhs {
            return commandLHS == commandRHS
        }
        return false
    }
}

public struct WebViewState: Equatable {
    public internal(set) var isLoading: Bool
    public internal(set) var pageURL: String?
    public internal(set) var pageTitle: String?
    public internal(set) var pageHTML: String?
    public internal(set) var error: Error?
    public internal(set) var canGoBack: Bool
    public internal(set) var canGoForward: Bool
    public internal(set) var contentStarted: Bool
    public internal(set) var contentURL: URL?
    
    public static let empty = WebViewState(isLoading: false,
                                           pageURL: nil,
                                           pageTitle: nil,
                                           pageHTML: nil,
                                           error: nil,
                                           canGoBack: false,
                                           canGoForward: false,
                                           contentStarted: false,
                                           contentURL: nil)
    
    public static func == (lhs: WebViewState, rhs: WebViewState) -> Bool {
        lhs.isLoading == rhs.isLoading &&
        lhs.pageURL == rhs.pageURL &&
        lhs.pageTitle == rhs.pageTitle &&
        lhs.pageHTML == rhs.pageHTML &&
        lhs.error?.localizedDescription == rhs.error?.localizedDescription &&
        lhs.canGoBack == rhs.canGoBack &&
        lhs.canGoForward == rhs.canGoForward &&
        lhs.contentStarted == rhs.contentStarted &&
        lhs.contentURL == rhs.contentURL
    }
}

public struct WebViewConfig {
    public enum ContentKind {
        case stream(MarbleRemoteConfig.StreamConfig.Kind)
        case none
    }
    
    public static let `default` = WebViewConfig()
    
    public let contentKind: ContentKind
    public let javaScriptEnabled: Bool
    public let allowsBackForwardNavigationGestures: Bool
    public let allowsInlineMediaPlayback: Bool
    public let mediaTypesRequiringUserActionForPlayback: WKAudiovisualMediaTypes
    public let isScrollEnabled: Bool
    public let isOpaque: Bool
    public let backgroundColor: Color
    public let disableContentBypass: Bool
    public let isHeadless: Bool
    public let isDebug: Bool
    
    public init(_ contentKind: ContentKind = .none,
                javaScriptEnabled: Bool = true,
                allowsBackForwardNavigationGestures: Bool = true,
                allowsInlineMediaPlayback: Bool = true,
                mediaTypesRequiringUserActionForPlayback: WKAudiovisualMediaTypes = [],
                isScrollEnabled: Bool = true,
                isOpaque: Bool = true,
                backgroundColor: Color = .clear,
                disableContentBypass: Bool = false,
                isHeadless: Bool = false,
                isDebug: Bool = false) {
        self.contentKind = contentKind
        self.javaScriptEnabled = javaScriptEnabled
        self.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        self.mediaTypesRequiringUserActionForPlayback = mediaTypesRequiringUserActionForPlayback
        self.isScrollEnabled = isScrollEnabled
        self.isOpaque = isOpaque
        self.backgroundColor = backgroundColor
        self.disableContentBypass = disableContentBypass
        self.isHeadless = isHeadless
        self.isDebug = isDebug
    }
}
