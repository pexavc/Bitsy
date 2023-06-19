//
//  WebView.Helpers.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import WebKit
import Fuzi

extension WebView {
    func execute(action: WebViewAction, _ webView: WKWebView, _ context: Context) {
        
        context.coordinator.actionInProgress = true
        
        switch action {
        case .automateClick,
                .evaluateJS,
                .clearCookies,
                .reload:
            context.coordinator.webView.state.isLoading = true
        default:
            break
        }
        
        switch action {
        case .idle:
            break
        case .load(let request):
            clearCookies()
            webView.load(request)
        case .loadHTML(let pageHTML):
            webView.loadHTMLString(pageHTML, baseURL: nil)
        case .reload:
            webView.reload()
        case .goBack:
            webView.goBack()
        case .goForward:
            webView.goForward()
        case .printCookies:
            DispatchQueue.main.async {
                self.action = .idle
                context.coordinator.actionInProgress = false
                
                printCookies(webView)
            }
        case .clearCookies:
            DispatchQueue.main.async {
                self.action = .idle
                context.coordinator.actionInProgress = false
                
                clearCookies(reload: true)
            }
        case .automateClick(let innerText, let callback):
            getLatestHTML(webView) { result in
                guard let htmlString = result else {
                    self.action = .idle
                    return
                }
                
                guard let js = generateAutomationJS(innerText,
                                                    html: htmlString) else {
                    self.action = .idle
                    context.coordinator.actionInProgress = false
                    callback(true)
                    return
                }
                
                webView.evaluateJavaScript(js) { result, error in
                    self.action = .idle
                    context.coordinator.actionInProgress = false
                    
                    if let error = error {
                        print("[WebView.Helpers] Automation Error: \(error.localizedDescription)")
                        callback(false)
                    } else {
                        print("[WebView.Helpers] Automation Success")
                        callback(true)
                    }
                }
            }
        case .evaluateJS(let command, let callback):
            webView.evaluateJavaScript(command) { result, error in
                self.action = .idle
                context.coordinator.webView.state.isLoading = false
                context.coordinator.actionInProgress = false
                if let error = error {
                    callback(.failure(error))
                } else {
                    callback(.success(result))
                }
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch action {
            case .automateClick,
                    .evaluateJS,
                    .clearCookies:
                break
            default:
                self.action = .idle
                context.coordinator.actionInProgress = false
            }
        }
    }
}

extension WebView {
    func clearCookies(reload: Bool = false) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[GraniteWebView] Cookie :: \(record) deleted")
            }
            
            if reload {
                action = .reload
            }
        }
    }
    
    func printCookies(_ webView: WKWebView) {
        guard let url = webView.url else { return }
        webView.getCookies(for: url.host) { data in
              print("=========================================")
              print("\(url.absoluteString)")
              print(data)
        }
    }
}

extension WebView {
    func generateAutomationJS(_ innerText: String, html: String) -> String? {
        guard let document = html.htmlDocument else {
            print("[WebView.Helpers] Failed to create document.")
            return ""
        }
        
        let buttonNodes = document.xpath("//button")
        
        var targetClass: String? = nil
        
        //Found a match, execute another JS action via query selector
        if let firstNode = buttonNodes.first(where: { ($0.stringValue == innerText) }) {
            
            guard let buttonClass = firstNode.attributes["class"] else {
                print("[WebView.Helpers] failed to find button class.")
                return ""
            }
            
            targetClass = buttonClass.components(separatedBy: " ").first ?? buttonClass.replacingOccurrences(of: " ", with: ".")
        } else {
            print("[WebView.Helpers] Failed to find button for: \(innerText)")
            return nil
        }
        
        guard let buttonClass = targetClass else {
            print("[WebView.Helpers] No suitable class found")
            return ""
        }
        
        //let command_old: String = "document.querySelectorAll(\"button.\(buttonClass)\").forEach(button=>button.click())"
        let command: String = """
        [...document.querySelectorAll("button.\(buttonClass)")]
        .filter(e => {
        return e.innerHTML.includes('Start Watching')

        }).forEach(button => button.click());
        """
        
        print("[WebView.Helpers] Invoking: \(command)")
        
        return command
    }
}

extension WebView {
    func getLatestHTML(_ webView: WKWebView,
                       _ callback: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { result, error in
            
            if error == nil {
                callback(result as? String)
            } else {
                print("[WebView.Helpers] failed to get latest HTML: \(String(describing: error))")
                callback(nil)
            }
        }
    }
}

extension String {
    var htmlDocument: HTMLDocument? {
        try? HTMLDocument(string: self, encoding: .utf8)
    }
}

extension WKWebView {

    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }

    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}
