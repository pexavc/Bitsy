import Granite
import GraniteUI
import SwiftUI
import Foundation

import WebKit

extension Home: View {
    public var view: some View {
        ZStack {
            if service.state.config != nil {
                Stream()
            } else if let urlString = state.streamURLString {
                GraniteWebView(config: webViewConfig,
                               urlString: urlString)
                    .attach( { url in
                        service
                            .center
                            .set
                            .send(RemoteService
                                .Set
                                .Meta(username: state.username,
                                      kind: state.streamKind,
                                      url: url))
                        
                        center.renderStream.send()
                    }, at: \.setContentURL)
                    .opacity(webViewConfig.isDebug ? 0.75 : 0.1)
                    .allowsHitTesting(webViewConfig.isDebug)
            }
            
            
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(
                    Color.black.opacity(state.showUsernameEntry || state.isLoadingStream ? 0.9 : 0.0)
                )
                .animation(.default,
                           value: state.showUsernameEntry || state.isLoadingStream)
            
            if state.isLoadingStream {
                VStack {
                    Spacer()
                    
                    ProgressView()
                        .scaleEffect(.init(width: 1.2, height: 1.2))
                    
                    Spacer()
                }
                .opacity(state.showUsernameEntry ? 0.25 : 1.0)
            }
            
            inputView
            
            if state.showUsernameEntry && service.state.history.isEmpty == false {
                historyView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
