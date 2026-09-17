import Cocoa

final class CaptureCoordinator {
    private var overlayWindows: [SelectionOverlayWindow] = []
    private var actionBarWindow: FloatingActionBarWindow?

    func beginCapture() {
        closeOverlays()

        overlayWindows = NSScreen.screens.map { screen in
            SelectionOverlayWindow(screen: screen) { [weak self] globalRect, screen in
                self?.finishSelection(rect: globalRect, on: screen)
            } onCancel: { [weak self] in
                self?.closeOverlays()
            }
        }
        overlayWindows.forEach { $0.makeKeyAndOrderFront(nil) }
        NSApp.activate(ignoringOtherApps: true)
    }

    private func finishSelection(rect: CGRect, on screen: NSScreen) {
        closeOverlays()
        guard rect.width > 2, rect.height > 2 else { return }

        ScreenCaptureManager.captureImage(rect: rect, on: screen) { [weak self] image in
            guard let self, let image else { return }
            self.showActionBar(near: rect, on: screen, image: image)
        }
    }

    private func closeOverlays() {
        overlayWindows.forEach { $0.orderOut(nil) }
        overlayWindows.removeAll()
    }

    private func showActionBar(near rect: CGRect, on screen: NSScreen, image: NSImage) {
        actionBarWindow?.orderOut(nil)
        let bar = FloatingActionBarWindow(anchorRect: rect, screen: screen, image: image) { [weak self] in
            self?.actionBarWindow?.orderOut(nil)
            self?.actionBarWindow = nil
        }
        actionBarWindow = bar
        bar.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
