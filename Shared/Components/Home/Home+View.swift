import Granite
import SwiftUI

extension Home: View {
    public var view: some View {
        ZStack {
            Stream()
            Menu()
        }
    }
}
