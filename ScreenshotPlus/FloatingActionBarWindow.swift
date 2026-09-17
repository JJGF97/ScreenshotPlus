import Cocoa
import SwiftUI

final class FloatingActionBarWindow: NSPanel {
    init(anchorRect: CGRect, screen: NSScreen, image: NSImage, onDismiss: @escaping () -> Void) {
        let barSize = CGSize(width: 340, height: 64)
        var origin = CGPoint(x: anchorRect.midX - barSize.width / 2,
                              y: anchorRect.minY - barSize.height - 10)
        if origin.y < screen.frame.minY {
            origin.y = anchorRect.maxY + 10 // si no cabe debajo, se coloca arriba
        }
        let frame = CGRect(origin: origin, size: barSize)

        super.init(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel],
                    backing: .buffered, defer: false)

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        self.contentView = NSHostingView(rootView: ActionBarView(image: image, onDismiss: onDismiss))
    }

    override var canBecomeKey: Bool { true }
}

struct ActionBarView: View {
    let image: NSImage
    let onDismiss: () -> Void

    @State private var showAnnotate = false
    @State private var showQRInput = false

    var body: some View {
        HStack(spacing: 14) {
            actionButton("doc.on.doc", "Copiar") {
                ClipboardHelper.copyImage(image)
                onDismiss()
            }
            actionButton("square.and.arrow.down", "Guardar") {
                FileSaveHelper.saveImage(image)
                onDismiss()
            }
            actionButton("pencil.tip.crop.circle", "Anotar") {
                showAnnotate = true
            }
            actionButton("text.viewfinder", "OCR") {
                OCRManager.recognizeText(in: image) { text in
                    DispatchQueue.main.async {
                        if let text, !text.isEmpty { ClipboardHelper.copyText(text) }
                        onDismiss()
                    }
                }
            }
            actionButton("qrcode", "QR") {
                showQRInput = true
            }
            actionButton("xmark.circle", "Cerrar") {
                onDismiss()
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .sheet(isPresented: $showAnnotate) {
            AnnotationView(image: image, onFinish: onDismiss)
        }
        .sheet(isPresented: $showQRInput) {
            QRInputView(initialText: "", onFinish: onDismiss)
        }
    }

    private func actionButton(_ system: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: system).font(.system(size: 16, weight: .medium))
                Text(label).font(.system(size: 9))
            }
            .frame(width: 46)
        }
        .buttonStyle(.plain)
    }
}
