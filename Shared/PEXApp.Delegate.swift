//
//  PEXApp.Delegate.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import SwiftUI
import MarbleKit

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //MarbleRemote.initializeNetwork()
        return true
    }
}
#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        //MarbleRemote.initializeNetwork()
        //TODO: Profiles a memory leak, may be a red herring.
        //Without this, delegates such as detecting windows closing
        //will not fire
        //NSApplication.shared.delegate = self
    }
}
#endif
