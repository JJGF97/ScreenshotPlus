import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 14) {
            if let icon = NSApp.applicationIconImage {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 96, height: 96)
            }

            Text("ScreenshotPlus")
                .font(.title2).bold()
            Text("Versión \(version) (\(build))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Captura, anota, extrae texto (OCR) y genera códigos QR sin salir de la barra de menú.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 260)

            Divider()

            Text("¿Te resulta útil? Puedes invitarme un café ☕️")
                .font(.footnote)

            Button {
                openURL("https://ko-fi.com/flowmac")
            } label: {
                Label("Invitarme un café en Ko-fi", systemImage: "heart.fill")
            }
            .buttonStyle(.borderedProminent)

            Button("Cerrar") {
                NSApp.keyWindow?.close()
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 320)
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        NSWorkspace.shared.open(url)
    }
}
