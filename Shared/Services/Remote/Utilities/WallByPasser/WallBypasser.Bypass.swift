//
//  WallBypasser.Kick.swift
//  Bitsy
//
//  Created by PEXAVC on 6/18/23.
//

import Foundation

extension WallBypasser {
    func getURL() -> URL? {
        switch kind {
        case .kick:
            if let videoNodes = htmlDocument?.xpath("//video") {
                if let firstNode = videoNodes.first(where: { ($0.attr("src"))?.contains(".m3u8") == true }) {
                    if let streamURLString = firstNode.attr("src"),
                       let url = URL(string: streamURLString) {
                        print("[WallBypasser] url found \(url)")
                        return url
                    }
                } /* else if let firstNode = videoNodes.first(where: { ($0.attr("src"))?.contains("blob:") == true }) {
                    
                    if let streamURLString = firstNode.attr("src"),
                       let url = URL(string: streamURLString) {
                        print("[WallBypasser] blob url found \(url)")
                        return url
                    }
                } */ else {
                    
                    print("[WallBypasser.Bypass.getURL] Failed to find HLS part. \(videoNodes.map({ $0.attr("src") }))")
                }
            }
        default:
            return nil
        }
        
        return nil
    }
    
    func update(_ step: Step, state: Bool) {
        if let index = self.steps.firstIndex(of: step) {
            self.steps.remove(at: index)
            var newStep = step
            newStep.update(state)
            self.steps.insert(newStep, at: index)
        }
    }
    
    var isComplete: Bool {
        nextStep == nil
    }
    
    var nextStep: WallBypasser.Step? {
        print("[WallBypasser] completed \(completedSteps.count)/\(steps.count) steps")
        let step = self.steps.first(where: { $0.success == false })
        print(step?.description ?? "")
        return step
    }
    
    var completedSteps: [WallBypasser.Step] {
        self.steps.filter { $0.success }
    }
}
