//
//  PEXApp.Delegate.swift
//  KickIt
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import SwiftUI

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.delegate = self
    }
}
#endif
