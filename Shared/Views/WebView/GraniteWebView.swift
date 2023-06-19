//
//  GraniteWebView.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import Fuzi

struct GraniteWebView: View {
    @GraniteAction<URL> var setContentURL
    
    var config: WebViewConfig = .default
    var urlString: String
    
    @State public var action = WebViewAction.idle
    @State public var state = WebViewState.empty
    
    var body: some View {
        WebView(config: config,
                action: $action,
                state: $state,
                restrictedPages: [],
                htmlInState: true)
        .opacity(config.isHeadless ? 0.0001 : 1.0)
        .onAppear {
            if let url = URL(string: urlString) {
                action = .load(URLRequest(url: url))
            }
        }
        .onChange(of: state) { newState in
            if let url = newState.contentURL {
                setContentURL.perform(url)
            }
        }.overlay {
            Group {
                if config.isDebug {
                    VStack {
                        Button {
                            action = .evaluateJS("""
                            console.log(document.getElementsByTagName("video").currentSrc);
                            """) { result in

                            }
                            print("[GraniteWebView] \(state.contentURL)")
                        } label : {
                            Text("Get Stream URL")
                        }
                        
                        Button {
                            action = .automateClick("Accept") { result in
                                
                            }
                        } label : {
                            Text("Automate Click")
                        }
                        
                        Button {
                            action = .printCookies
                            
                        } label : {
                            Text("Print Cookies")
                        }
                        
                        Button {
                            action = .clearCookies
                            
                        } label : {
                            Text("Clear Cookies")
                        }
                        
                        Button {
                            action = .reload
                            
                        } label : {
                            Text("Reload")
                        }
                    }
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)
                    .background(
                        Color
                            .black
                            .opacity(0.75))
                } else {
                    EmptyView()
                }
            }.allowsHitTesting(config.isDebug)
        }
    }
}
