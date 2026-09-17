import Cocoa
import SwiftUI

final class AboutWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Acerca de ScreenshotPlus"
        window.isReleasedWhenClosed = false // para poder reabrirla sin recrearla desde cero
        window.contentView = NSHostingView(rootView: AboutView())
        window.center()

        self.init(window: window)
    }
}
