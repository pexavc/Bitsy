import Granite
import GraniteUI
import SwiftUI
import Foundation

import WebKit

extension Menu: View {
    public var view: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(
                    Color.black.opacity(streamIsActive || state.showUsernameEntry == false ? 0.0 : 0.5)
                )
                .animation(.default,
                           value: state.showUsernameEntry || service.state.isLoadingStream)
            
            if service.state.isLoadingStream {
                VStack {
                    Spacer()
                    
                    ProgressView()
                        .scaleEffect(.init(width: 1.2, height: 1.2))
                    
                    Spacer()
                }
                .opacity(state.showUsernameEntry ? 0.25 : 1.0)
            }
            
            MonitorView()
            
            inputView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
