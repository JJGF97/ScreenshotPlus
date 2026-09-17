import CoreImage
import Cocoa
import SwiftUI

enum QRCodeGenerator {
    static func generate(from text: String, scale: CGFloat = 10) -> NSImage? {
        guard !text.isEmpty,
              let data = text.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let rep = NSCIImageRep(ciImage: scaled)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

struct QRInputView: View {
    @State var initialText: String
    let onFinish: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var qrImage: NSImage?

    var body: some View {
        VStack(spacing: 16) {
            Text("Generar código QR").font(.headline)
            TextField("Texto o URL", text: $initialText)
                .textFieldStyle(.roundedBorder)
                .onSubmit { qrImage = QRCodeGenerator.generate(from: initialText) }

            if let qrImage {
                Image(nsImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 160, height: 160)
            }

            HStack {
                Button("Generar") { qrImage = QRCodeGenerator.generate(from: initialText) }
                if qrImage != nil {
                    Button("Copiar") { if let qrImage { ClipboardHelper.copyImage(qrImage) } }
                    Button("Guardar") { if let qrImage { FileSaveHelper.saveImage(qrImage) } }
                }
                Button("Cerrar") { dismiss(); onFinish() }
            }
        }
        .padding(24)
        .frame(width: 320)
    }
}
