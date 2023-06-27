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
                    Color.black.opacity(state.showUsernameEntry || service.state.isLoadingStream ? 0.9 : 0.0)
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
            
            VStack {
                HStack {
                    MonitorView()
                    Spacer()
                }
                
                Spacer()
            }
            
            inputView
            
            if state.showUsernameEntry && service.state.history.isEmpty == false {
                historyView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
