import Granite
import SwiftUI
import AVKit

extension Stream: View {
    public var view: some View {
        ZStack {
            VStack {
                if let config = service.state.config {
                    Canvas(config: config)
                } else if let urlString = service.state.streamURLString {
                    GraniteWebView(config: webViewConfig,
                                   urlString: urlString)
                        .attach( { url in
                            service
                                .center
                                .set
                                .send(RemoteService
                                    .Set
                                    .Meta(url: url))
                        }, at: \.setContentURL)
                        .opacity(webViewConfig.isDebug ? 0.75 : 0.1)
                        .allowsHitTesting(webViewConfig.isDebug)
                }
            }
        }
    }
}
