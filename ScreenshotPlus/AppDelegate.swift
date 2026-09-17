import Cocoa
import Carbon.HIToolbox
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var hotKeyManager: HotKeyManager?
    private var captureCoordinator: CaptureCoordinator!
    private var aboutWindowController: AboutWindowController?
    private var launchAtLoginItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        captureCoordinator = CaptureCoordinator()
        setupStatusItem()
        setupGlobalHotKey()

        // Se revisa después de tener el ícono en la barra, para que el usuario ya vea
        // que la app corrió antes de que le aparezca el diálogo de permiso.
        PermissionsManager.ensureScreenRecordingAccess()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Captura de pantalla")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()

        let captureItem = NSMenuItem(title: "Capturar área (⌘⇧X)", action: #selector(startCapture), keyEquivalent: "")
        captureItem.target = self
        menu.addItem(captureItem)

        menu.addItem(.separator())

        launchAtLoginItem = NSMenuItem(title: "Iniciar al abrir sesión", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(launchAtLoginItem)

        let permissionsItem = NSMenuItem(title: "Ajustes de Grabación de Pantalla…", action: #selector(openScreenRecordingSettings), keyEquivalent: "")
        permissionsItem.target = self
        menu.addItem(permissionsItem)

        menu.addItem(.separator())

        let aboutItem = NSMenuItem(title: "Acerca de ScreenshotPlus", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Salir", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
                launchAtLoginItem.state = .off
            } else {
                try SMAppService.mainApp.register()
                launchAtLoginItem.state = .on
            }
        } catch {
            print("No se pudo cambiar el inicio automático: \(error)")
        }
    }

    private func setupGlobalHotKey() {
        hotKeyManager = HotKeyManager(keyCode: UInt32(kVK_ANSI_X), modifiers: [.command, .shift]) { [weak self] in
            self?.startCapture()
        }
    }

    @objc private func startCapture() {
        captureCoordinator.beginCapture()
    }

    @objc private func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        NSApp.activate(ignoringOtherApps: true)
        aboutWindowController?.showWindow(nil)
        aboutWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    @objc private func openScreenRecordingSettings() {
        PermissionsManager.openScreenRecordingSettings()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

