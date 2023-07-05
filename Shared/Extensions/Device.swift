//
//  Device.swift
//  Bitsy
//
//  Created by PEXAVC on 6/27/23.
//

import Foundation

struct Device {
    public static var isIPhone: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }
}
