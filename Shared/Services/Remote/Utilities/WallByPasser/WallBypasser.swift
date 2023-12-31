//
//  StreamWall.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Fuzi
import MarbleKit

class WallBypasser: NSObject {
    let kind: MarbleRemoteConfig.StreamConfig.Kind
    var steps: [WallBypasser.Step]
    
    var detectedWall: Bool {
        steps.isEmpty == false
    }
    
    var isByPassing: Bool = false
    
    var htmlString: String? = nil
    var htmlDocument: HTMLDocument? = nil
    
    init(_ kind: MarbleRemoteConfig.StreamConfig.Kind) {
        self.kind = kind
        self.steps = []
        super.init()
    }
    
    func updateHTML(_ htmlString: String) {
        self.htmlString = htmlString
        self.htmlDocument = htmlString.htmlDocument
        
        steps.removeAll()
        
        kind.bypassSteps.forEach { step in
            if htmlString.contains(step.detectionText) {
                steps.append(step)
            }
        }
        
        if detectedWall {
            print("[WallBypasser] Wall detected for: \(kind)")
        }
    }
}

