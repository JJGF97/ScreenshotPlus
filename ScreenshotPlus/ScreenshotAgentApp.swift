import SwiftUI

@main
struct ScreenshotAgentApp: App {
    // El AppDelegate maneja TODO el ciclo de vida real (StatusItem, hotkey, capturas).
    // No usamos WindowGroup porque la app no debe mostrar ninguna ventana al iniciar.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Settings{} no crea una ventana visible al lanzar; solo aparece si el usuario
        // la invoca explícitamente (aquí no la usamos, pero es la Scene "vacía" recomendada
        // para apps de solo StatusItem).
        Settings {
            EmptyView()
        }
    }
}
