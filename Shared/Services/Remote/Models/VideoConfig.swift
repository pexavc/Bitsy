//
//  Video.swift
//  KickIt
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Network
import Granite

struct VideoConfig: GraniteModel, Identifiable, Hashable {
    var id: String {
        "\(date.timeIntervalSince1970)"
    }
    
    let date: Date = .init()
    var name: String
    var kind: StreamKind
    var streams: [StreamConfig]
    
    var description: String {
        name + "'s Stream on " + kind.rawValue.capitalized
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum StreamKind: String, CaseIterable, GraniteModel {
    case kick
    case twitch
}

struct StreamConfig: GraniteModel {
    let resolution: Resolution
    let streamURL: URL
}

enum Resolution: Int, GraniteModel, Identifiable, Comparable, CaseIterable {
    case p360 = 0
    case p540
    case p720
    case p1080
    
    var id: Int { rawValue }
    
    var displayValue: String {
        switch self {
        case .p360: return "360p"
        case .p540: return "540p"
        case .p720: return "720p"
        case .p1080: return "1080p"
        }
    }
    
    static func ==(lhs: Resolution, rhs: Resolution) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    static func <(lhs: Resolution, rhs: Resolution) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
