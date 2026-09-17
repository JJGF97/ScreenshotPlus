import Cocoa

enum PermissionsManager {
    /// Revisa si ya se tiene el permiso de Grabación de pantalla; si no, explica brevemente
    /// por qué se necesita y luego dispara el diálogo nativo del sistema.
    static func ensureScreenRecordingAccess() {
        guard !CGPreflightScreenCaptureAccess() else { return }

        let alert = NSAlert()
        alert.messageText = "Permiso de Grabación de Pantalla"
        alert.informativeText = "ScreenshotPlus necesita este permiso para poder capturar áreas de tu pantalla. A continuación, macOS te pedirá autorizarlo."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Continuar")
        alert.addButton(withTitle: "Ahora no")

        if alert.runModal() == .alertFirstButtonReturn {
            // Dispara el diálogo nativo de TCC (Transparency, Consent and Control) de macOS.
            CGRequestScreenCaptureAccess()
        }
    }

    /// Atajo directo a Ajustes del Sistema → Privacidad y Seguridad → Grabación de pantalla,
    /// por si el usuario dijo "Ahora no" y luego quiere activarlo manualmente.
    static func openScreenRecordingSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") else { return }
        NSWorkspace.shared.open(url)
    }
}
