# Bitsy (iOS/iPadOS & macOS)

100% SwiftUI lightweight stream viewer for Kick and Twitch. Support for other platforms coming soon!

![Preview](https://stoic-static-files.s3.us-west-1.amazonaws.com/bitsy/demos/bitsy_intro_3.gif)

**Table of Contents**
- [Requirements](#requirements)
- [Guide](#guide)
  - [Clipping](#clipping)
  - [Audio Visualizer](#audio-visualizer)
  - [Intercepting](#intercepting)
  - [Bypassing Walls](#bypassing-walls)
  - [Adding a new site](#adding-a-new-site)
- [Troubleshooting](#Troubleshooting)
- [TODO](#TODO)

**Disclaimer**

This implementation, uses a method of Swizzling and editing "Private APIs" in WKWebView, to intercept requests. This is against App Review guidelines and is not recommended to be used in production builds.

## Requirements

- `iOS 14+`  ***Build passing*** 🟢 
- `macOS 12.4+`  ***Build passing*** 🟢 

**Installation**

Build locally using `XCode 14.2` or download the latest *notarized* build [here](https://github.com/pexavc/Bitsy/releases).                

## Swift Packages

- [Granite](https://github.com/pexavc/Granite)
- [MarbleKit](https://github.com/pexavc/MarbleKit)
- [Fuzi](https://github.com/cezheng/Fuzi) by [@cezheng](https://github.com/cezheng)

## Guide

### Clipping

Clipping any stream is possible when enabling it via the menu on the top right. Memory usage will increase significantly as buffers are stored for video generation. Disable the functionality to free up the occupied memory. 

The default clip length is set to 5 seconds, but that can be modified by editing a static variable a part of `MarbleKit` like so. 

```swift
Clip.maxDuration = 10 //in seconds
```

### Audio Visualizer

The Audio visualizer processes audio data in realtime. Letting you monitor the audio data frequencies and loudness of the stream.

Effects have been implemented using MarbleKit's collection. One can fork MarbleKit to implement their own shaders and effects using Metal and following the design pattern in the kit appropriately. 

[Here](https://github.com/pexavc/Bitsy/blob/8dcdd9df33d3fba63e490f75f106b03254f80ba8/Shared/Components/Menu/Reducers/Menu.Controls.swift#L29-L39) is how fx are being modified. Simply adjust this static variable anywhere to change the fx yourself programmatically. 

```swift
MarbleRemote.fx = [.ink]
```

[Here](https://github.com/pexavc/MarbleKit/blob/a3196174421940ddf778d6033453f7038bf774ad/Sources/MarbleKit/Engine/Core/Catalog/FilterType.swift#L44-L110) is a list of current FX supported. Make note, only the 2D effects are supported in Bitsy for now.

> In the future, other hooks can be available for other types of Audio manipulation such as Speech to text for closed captioning.

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

So we just simply, wait for it to complete, [then we Swizzle](https://github.com/pexavc/Bitsy/blob/main/Shared/Views/WebView/WebView.Coordinator.swift#L152-L157), and then unregister the overrides after we fetch the HLS url.


### Bypassing Walls

Sometimes there are dialog boxes or overlays that could block a stream from loading. 

Systems have been put in place to setup a [basic automation routine](https://github.com/pexavc/Bitsy/blob/main/Shared/Views/WebView/WebView.Coordinator.Helpers.swift) to click through these until a stream can be found.

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

### Adding a new site (Deprecated)

> Adding a new StreamKind will require modifying [MarbleKit](https://github.com/pexavc/MarbleKit). In the future this will be exposed to the front-end side for modification within Bitsy.

1. [Add a new `StreamKind`](https://github.com/pexavc/MarbleKit/blob/a3196174421940ddf778d6033453f7038bf774ad/Sources/MarbleKit/Player/MarbleRemote/MarbleRemoteConfig.swift#L77-L81)

2. [Add a new Sanitization step, when setting a stream](https://github.com/pexavc/Bitsy/blob/main/Shared/Components/Menu/Reducers/Menu.Stream.swift#L45-L50)

3. Using prior methods as reference, observe how to fetch a `.m3u8` file. To finally set it in this [scope](https://github.com/pexavc/Bitsy/blob/main/Shared/Views/WebView/WebView.Coordinator.swift#L139-L170) most likely.

### Troubleshooting

If you are stuck on an infinite loading spiral. The bypass check, might be failing. I have only setup detection for english at the moment. [Add a step for these steps here](https://github.com/pexavc/Bitsy/blob/8dcdd9df33d3fba63e490f75f106b03254f80ba8/Shared/Services/Remote/Utilities/WallByPasser/WallBypasser.Step.swift#L46-L74) to the exact warning/dialog box message in your appropriate language.

Set the `webViewConfig`'s `isHeadless` mode to *false* to see if the stream starts normally or to read the exact dialog box message, button action text.

```swift
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
                      kind: .button),
                .init(targetInnerText: "Start Watching",
                      detectionText: "The broadcaster indicated that this channel is intended for mature audiences.",
                      kind: .button)
            ]
        }
    }
}
```

## TODO
- [ ] Bypass walls properly (Age rating/Cookies dialog) `(Partially working)`
- [ ] Chat viewer
- [ ] Stabilizing stream rendering, further
