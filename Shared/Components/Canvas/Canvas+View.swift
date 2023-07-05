import Foundation
import Granite
import MarbleKit
import SwiftUI
import AVKit

extension Canvas {
    public var view: some View {
        ZStack {
            MarblePlayerView(config)
        }
    }
}
