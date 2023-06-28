import Granite
import SwiftUI

extension Home: View {
    public var view: some View {
        ZStack {
            Stream()
                .padding(.top, MonitorView.compactMonitorHeight + 16 + titleBarHeight)//20  = Titlebar
                .padding(.bottom, Menu.controlsHeight + 16)
            Menu()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var titleBarHeight: CGFloat {
        #if os(macOS)
        //TODO: don't hardcode
        return 20
        #else
        return 0
        #endif
    }
}
