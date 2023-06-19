# Bitsy (iOS/iPadOS & macOS)

100% SwiftUI lightweight stream viewer for Kick and Twitch. Support for other platforms coming soon!

Kick           |  Twitch
:-------------------------:|:-------------------------:
![Kick Preview](https://stoic-static-files.s3.us-west-1.amazonaws.com/bitsy/demos/bitsy_intro_1.gif) | ![Twitch Preview](https://stoic-static-files.s3.us-west-1.amazonaws.com/bitsy/demos/bitsy_intro_2.gif)

**Table of Contents**
- [Requirements](#requirements)
- [Guide WIP](#guide)
  - [Intercepting](#intercepting)
  - [Bypassing Walls](#bypassing-walls)
  - [Adding a new site](#adding-a-new-site)
- [TODO](#TODO)

**Disclaimer**

1. This implementation, uses a method of Swizzling and editing "Private APIs" in WKWebView, to intercept requests. This is against App Review guidelines and is not recommended to be used in production builds.

2. While building this, I have discovered some new limitations around [Granite](https://github.com/pexavc/Granite), which I will be addressing soon. If some UX interactions seem fragile/odd, I am aware of them. Like [Issue #1](https://github.com/pexavc/Granite/issues/1) in the repo, these are quite deep and have simply been sidetracked open-sourcing and/or building out small fun tools like Bitsy.

## Requirements

- `iOS 14+`  ***Build passing*** 🟢 
- `macOS 12.4+`  ***Build passing*** 🟢                     


## Swift Packages

- [Granite](https://github.com/pexavc/Granite)
- [Fuzi](https://github.com/cezheng/Fuzi) by [@cezheng](https://github.com/cezheng)

## Guide

### Intercepting

> Comments in linked files, explain further

[**Observing HTML `<video />`**](https://github.com/pexavc/Bitsy/tree/main/Shared/Views/WebView/VideoPlayerEvent.js)

On the Swift side, we should tell `WKWebView` to [listen to a custom handler](https://github.com/pexavc/Bitsy/tree/main/Shared/Views/WebView/WebView.swift#L27-L33) we call `callbackHandler`.

This adds a content controller to the WKWebView, giving it an id to listen to from the JS being evaluated.
```swift
fileprivate func createHandler(_ handler: WKScriptMessageHandlerWithReply) -> WKUserContentController {
    let contentController = WKUserContentController()

    contentController.addScriptMessageHandler(handler, contentWorld: .page, name: "callbackHandler")
    
    return contentController
}
```

On the JS side, we fire this handler, when a video DOM element is playing. (Yes, there could be multiple videos on the page that could trip this).
```js
for (var i = 0; i < videos.length; i++) {
    videos.item(i).onplaying = function() {
        webkit.messageHandlers.callbackHandler.postMessage("VideoIsPlaying");
    }
}
```

[**XHR (Kick's Solution)**](https://github.com/pexavc/Bitsy/tree/main/Shared/Views/WebView/InterceptXHR.js)

Kick, fires an XHR request to fetch metadata regarding the stream. The response has the HLS playlist file. We handle the callback in swift and set the URL to begin streaming.

```swift
if messageString.contains("StreamURL") {
    
    let sanitized: String = messageString.replacingOccurrences(of: "StreamURL:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    
    if let url = URL(string: sanitized) {
        
        print("[WebView.Coordinator] Found StreamURL: \(sanitized)")
        
        updateContentURL(url)
    }

 ...
}
```

[**Swizzling in Swift (Twitch Solution)**](https://github.com/pexavc/Bitsy/blob/main/Shared/Views/WebView/WebView.Swizzle.swift)

Twitch is a little complicated. They are actually updating their API, I believe, to prevent easy stream link fetching which is why I feel there's a lot more measures in place here. Not only that, since iOS14, NSURLProtocol class registration has lots of checks in place, in which some requests aren't available out of the box in the usual methods of interception.

Based on the [Obj-C implementation](https://github.com/wilddylan/WKWebViewWithURLProtocol/blob/master/WKWebViewWithURLProtocol/NSURLProtocol%2BWKWebViewSupport.m) by [@wilddylan](https://github.com/wilddylan) this Swift implementation, edits a key-value property of WKBrowsing. [Here's the exact header file of the private Apple package I am talking about.](https://github.com/MP0w/iOS-Headers/blob/master/iOS8.1/PrivateFrameworks/WebKit/WKBrowsingContextController.h)

> Note: Yes, App Review teams can detect if such variables are modified and you can risk rejection.

```swift
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
```

The bigger caveat is, there is a check in place, that prevents Twitch from loading the stream at all. And my theory is around a blocked `POST` response. Which is more on Apple's side, I believe, rather than Twitch's. As a security feature to prevent unwarranted custom URL Protocols intercepting `http/https urlschemes`.

So we just simply, wait for it to complete, [then we Swizzle](https://github.com/pexavc/Bitsy/blob/main/Shared/Views/WebView/WebView.Coordinator.swift#L164-L169), and then unregister the overrides after we fetch the HLS url.


### Bypassing Walls

> May be used in the future, but implementation is in place

Sometimes there are dialog boxes or overlays that could block a stream from loading. 

Systems have been put in place to setup a [basic automation routine](https://github.com/pexavc/Bitsy/blob/main/Shared/Views/WebView/WebView.Coordinator.swift#L87-L93) to click through these until a stream can be found.

> Warning: Potential infinite loop case. If a wall is detected, but automation fails.

```swift
webView.action = .evaluateJS("document.documentElement.outerHTML.toString()") { [weak self] result in
    switch result {
    case .success(let any):
        if let htmlString = any as? String {
            self?.bypasser?.updateHTML(htmlString)
            
            if self?.webView.config.isDebug == true || self?.bypasser?.isComplete == true ||
                self?.webView.config.disableContentBypass == true {
                self?.bypasser?.isByPassing = false
                self?.updateContentURL()
            } else if let step = self?.bypasser?.nextStep {
                self?.webView.action = step.trigger { result in
                    self?.bypasser?.update(step, state: result)
                    
                    guard result else { return }
                    
                    self?.webView.action = .reload//<--- will refresh the page and this function will invoke again if a new wall is detected. 
                }
            }
        }
    default:
        self?.bypasser?.isByPassing = false
        print("[WebView.Coordinator.Helpers] Failed to retrieve DOM.")
    }
}
```

Set the client into debug mode [here](https://github.com/pexavc/Bitsy/blob/main/Shared/Components/Stream/Stream%2BCenter.swift#L12-L16) and turn `isHeadless` off.

```swift
var webViewConfig: WebViewConfig {
    .init(.stream(state.streamKind),
          isHeadless: true,// -> false
          isDebug: false)// -> true
}
```

Then, you can play around/experiment with automation. Editing the button actions [here](https://github.com/pexavc/Bitsy/tree/main/Shared/Views/WebView/GraniteWebView.swift#L41-L91).

### Adding a new site

1. [Add a new `StreamKind`](https://github.com/pexavc/Bitsy/tree/main/Shared/Services/Remote/Models/VideoConfig.swift#L31-L34)

2. [Add a new Sanitization step, when setting a stream](https://github.com/pexavc/Bitsy/blob/main/Shared/Components/Menu/Reducers/Menu.Stream.swift#L40-L45)

3. Using prior methods as reference, observe how to fetch a `.m3u8` file. To finally set it in this [scope](https://github.com/pexavc/Bitsy/blob/main/Shared/Views/WebView/WebView.Coordinator.swift#L139-L170) most likely.

## TODO
- [x] Complete macOS implementation
- [ ] Bypass walls properly (Age rating/Cookies dialog)
- [ ] Design polish
- [ ] UX polish (username entry in-app)
- [ ] Chat viewer
