import ScreenCaptureKit
import Cocoa

enum ScreenCaptureManager {
    /// Captura la región indicada (coordenadas Cocoa, origen inferior-izquierdo) usando
    /// ScreenCaptureKit — reemplazo de CGWindowListCreateImage, eliminada en macOS 15.
    static func captureImage(rect: CGRect, on screen: NSScreen, completion: @escaping (NSImage?) -> Void) {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                guard let scDisplay = content.displays.first(where: { $0.displayID == screen.displayID }) else {
                    await MainActor.run { completion(nil) }
                    return
                }

                let filter = SCContentFilter(display: scDisplay, excludingWindows: [])
                let config = SCStreamConfiguration()

                // ScreenCaptureKit usa coordenadas con origen superior-izquierdo, relativas al display.
                let localRect = CGRect(
                    x: rect.minX - screen.frame.minX,
                    y: screen.frame.height - (rect.minY - screen.frame.minY) - rect.height,
                    width: rect.width,
                    height: rect.height
                )
                config.sourceRect = localRect
                config.width = max(1, Int(rect.width * screen.backingScaleFactor))
                config.height = max(1, Int(rect.height * screen.backingScaleFactor))
                config.showsCursor = false

                let cgImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
                await MainActor.run {
                    completion(NSImage(cgImage: cgImage, size: rect.size))
                }
            } catch {
                print("Error de captura: \(error)")
                await MainActor.run { completion(nil) }
            }
        }
    }
}

extension NSScreen {
    var displayID: CGDirectDisplayID {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
    }
}
