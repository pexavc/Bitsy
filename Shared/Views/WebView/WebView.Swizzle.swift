//
//  WebView.Swizzle.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import WebKit

extension Notification.Name {
    static let didReceiveURLResponse = Notification.Name("didReceiveURLResponse")
}

class SwizzleURLProtocol: URLProtocol {
    static let internalKey = "nyc.stoic.SwizzleURLProtocol"
    
    private lazy var session: URLSession = { [unowned self] in
        return URLSession(configuration: .default,
                          delegate: self, delegateQueue: nil)
    }()
    
    private var response: URLResponse?
    private var responseData: NSMutableData?
    
    open override class func canInit(with request: URLRequest) -> Bool {
        
        return canServeRequest(request)
    }
    
    override open class func canInit(with task: URLSessionTask) -> Bool
    {
        if #available(iOS 13.0, macOS 10.15, *) {
            if task is URLSessionWebSocketTask {
                return false
            }
        }

        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }
    
    override open class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    private class func canServeRequest(_ request: URLRequest) -> Bool
    {
        guard
            URLProtocol.property(forKey: SwizzleURLProtocol.internalKey, in: request) == nil,
            let url = request.url,
            (url.absoluteString.hasPrefix("http") || url.absoluteString.hasPrefix("https"))
        else {
            return false
        }
        //print("Request: URL = \(request.url?.absoluteString)")
        
        return true
    }
    
    override func startLoading() {
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: SwizzleURLProtocol.internalKey, in: mutableRequest)
        
        session.dataTask(with: mutableRequest as URLRequest).resume()

    }

    override func stopLoading() {
        session.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach { $0.cancel() }
            self.session.invalidateAndCancel()
        }
        
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
           do {
               try self.init(pattern: pattern)
           } catch {
               preconditionFailure("Illegal regular expression: \(pattern).")
           }
       }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension SwizzleURLProtocol: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        responseData?.append(data)
        
        
        
        client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        self.responseData = NSMutableData()
        
        
        client?.urlProtocol(self,
                            didReceive: response,
                            cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        
        
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        defer {
            if let error = error {
                print(error)
                client?.urlProtocol(self,
                                    didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        guard task.originalRequest != nil else {
            return
        }
        
        if let response = response {
            NotificationCenter.default.post(name: .didReceiveURLResponse,
                                            object: nil,
                                            userInfo: ["response": response])
        }
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        let updatedRequest: URLRequest
        if URLProtocol.property(forKey: SwizzleURLProtocol.internalKey, in: request) != nil {
            let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLProtocol.removeProperty(forKey: SwizzleURLProtocol.internalKey, in: mutableRequest)
            
            updatedRequest = mutableRequest as URLRequest
        } else {
            updatedRequest = request
        }
        
        print("[Swizzle] [Redirect] \(updatedRequest.url?.absoluteString)")
        
        client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
        completionHandler(updatedRequest)
    }
    
    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let wrappedChallenge = URLAuthenticationChallenge(authenticationChallenge: challenge,
                                                          sender: AuthenticationChallengeSender(handler: completionHandler))
        
        client?.urlProtocol(self, didReceive: wrappedChallenge)
    }
    
    #if !os(OSX)
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
    #endif
}

//MARK: NSURLSelectors

extension URLProtocol {
    
    class func contextControllerClass()->AnyClass {
        return NSClassFromString("WKBrowsingContextController")!
    }
    
    class func registerSchemeSelector()->Selector {
        return NSSelectorFromString("registerSchemeForCustomProtocol:")
    }
    
    class func unregisterSchemeSelector()->Selector {
        return NSSelectorFromString("unregisterSchemeForCustomProtocol:")
    }
    
    class func wk_register(scheme:String){
        let cls: AnyClass = contextControllerClass()
        let sel = registerSchemeSelector()
        if cls.responds(to: sel) {
            _ = (cls as AnyObject).perform(sel, with: scheme)
        }
    }
    
    class func wk_unregister(scheme:String){
        let cls: AnyClass = contextControllerClass()
        let sel = unregisterSchemeSelector()
        if cls.responds(to: sel) {
            _ = (cls as AnyObject).perform(sel, with: scheme)
        }
    }
}

//MARK: AuthChallenge
class AuthenticationChallengeSender : NSObject, URLAuthenticationChallengeSender {
    
    typealias AuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    let handler: AuthenticationChallengeHandler
    
    init(handler: @escaping AuthenticationChallengeHandler) {
        self.handler = handler
        //print("[AuthenticationChallengeSender] handling challenge")
        super.init()
    }
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        
        print("[AuthenticationChallengeSender] using \(credential.description)")
        handler(.useCredential, credential)
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        print("[AuthenticationChallengeSender] continuing without")
        handler(.useCredential, nil)
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        print("[AuthenticationChallengeSender] challenging \(challenge.description), failureCount: \(challenge.previousFailureCount)")
        handler(.cancelAuthenticationChallenge, nil)
    }
    
    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        
        
        print("[AuthenticationChallengeSender] default \(challenge.description), failureCount: \(challenge.previousFailureCount), authMethod: \(challenge.protectionSpace.authenticationMethod)")
        handler(.performDefaultHandling, nil)
//        let protectionSpace = challenge.protectionSpace
//
//        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//            if let serverTrust = protectionSpace.serverTrust {
//                let credential = URLCredential(trust: serverTrust)
//                challenge.sender?.use(credential, for: challenge)
//                handler(.performDefaultHandling, credential)
//            }
//        } else {
//            handler(.performDefaultHandling, nil)
//        }
        
    }
    
    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        print("[AuthenticationChallengeSender] reject \(challenge.description), failureCount: \(challenge.previousFailureCount)")
        handler(.rejectProtectionSpace, nil)
    }
}
