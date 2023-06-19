import Granite
import SwiftUI
import AVKit

extension Stream: View {
    public var view: some View {
        ZStack {
            VStack {
                if service.state.config != nil {
                    if let remote = self.remote {
                        VideoPlayer(player: remote.player)
                            .onAppear() {
                                remote.player.play()
                            }
    //                        .onDisappear {
    //                            remote.player.pause()
    //                        }
                    } else {
                        Text("Failed to start stream. Config = \(service.state.config?.name ?? "{UNKNOWN}")")
                    }
                } else if let urlString = service.state.streamURLString {
                    GraniteWebView(config: service.webViewConfig,
                                   urlString: urlString)
                        .attach( { url in
                            service
                                .center
                                .set
                                .send(RemoteService
                                    .Set
                                    .Meta(url: url))
                        }, at: \.setContentURL)
                        .opacity(service.webViewConfig.isDebug ? 0.75 : 0.1)
                        .allowsHitTesting(service.webViewConfig.isDebug)
                }
            }
        }
    }
}
