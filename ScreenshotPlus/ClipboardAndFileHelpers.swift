import Cocoa
import UniformTypeIdentifiers

enum ClipboardHelper {
    static func copyImage(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }

    static func copyText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

enum FileSaveHelper {
    static func saveImage(_ image: NSImage) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.nameFieldStringValue = "Captura.png"
        panel.canCreateDirectories = true

        panel.begin { response in
            guard response == .OK, let url = panel.url,
                  let tiffData = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData) else { return }

            let isJPEG = ["jpg", "jpeg"].contains(url.pathExtension.lowercased())
            let data = isJPEG
                ? bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
                : bitmap.representation(using: .png, properties: [:])
            try? data?.write(to: url)
        }
    }
}
