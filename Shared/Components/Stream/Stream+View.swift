import Granite
import SwiftUI
import AVKit

extension Stream: View {
    public var view: some View {
        ZStack {
            VStack {
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
            }
        }
    }
}
