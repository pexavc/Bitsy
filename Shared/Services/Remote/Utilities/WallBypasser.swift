//
//  StreamWall.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation
import Fuzi

class WallBypasser: NSObject {
    let kind: StreamKind
    var steps: [WallBypasser.Step]
    
    var htmlString: String? = nil
    var htmlDocument: HTMLDocument? = nil
    
    init(_ kind: StreamKind) {
        self.kind = kind
        self.steps = kind.bypassSteps
        super.init()
    }
    
    func updateHTML(_ htmlString: String) {
        self.htmlString = htmlString
        self.htmlDocument = htmlString.htmlDocument
    }
}

