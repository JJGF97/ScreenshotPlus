# Guía de configuración — ScreenshotAgent

## 1. Crear el proyecto en Xcode
1. Xcode → File → New → Project → **macOS → App**.
2. Product Name: `ScreenshotAgent`. Interface: **SwiftUI**. Language: **Swift**.
3. Desmarca "Use Core Data" y "Include Tests" (no se necesitan).
4. En **Signing & Capabilities**, elige tu Team.
5. En el target → **General → Minimum Deployments**, pon **macOS 13.0** o superior
   (se usa `Canvas`, `.ultraThinMaterial` y `NSHostingView` moderno).

## 2. Reemplazar el código por defecto
1. Borra `ContentView.swift` (no se usa: la app no tiene ventana principal).
2. Arrastra a la carpeta del proyecto (en Xcode, "Copy items if needed" activado)
   todos los archivos `.swift` entregados:
   - `ScreenshotAgentApp.swift` (reemplaza el `@main` generado por Xcode)
   - `AppDelegate.swift`
   - `HotKeyManager.swift`
   - `CaptureCoordinator.swift`
   - `ScreenCaptureManager.swift`
   - `SelectionOverlayWindow.swift`
   - `FloatingActionBarWindow.swift`
   - `ClipboardAndFileHelpers.swift`
   - `OCRManager.swift`
   - `QRCodeGenerator.swift`
   - `AnnotationView.swift`

## 3. Info.plist — agente en segundo plano (sin ícono en el Dock)
En el target → pestaña **Info** (o editando `Info.plist` directamente), agrega:

| Key | Tipo | Valor |
|---|---|---|
| `Application is agent (UIElement)` (`LSUIElement`) | Boolean | `YES` |

Esto oculta el ícono del Dock; solo se verá el ícono en la barra de menú (StatusItem).

> No necesitas agregar `NSScreenCaptureUsageDescription` para `CGWindowListCreateImage`:
> macOS mostrará automáticamente el diálogo de permiso de **Screen Recording** la
> primera vez que se intente capturar. Sí es buena práctica documentarlo en la
> descripción de la App Store si algún día la distribuyes ahí.

## 4. Signing & Capabilities — Sandbox
- Para distribución **fuera** del Mac App Store (descarga directa, notarizada):
  dejar **App Sandbox desactivado** simplifica todo (acceso a `NSSavePanel`,
  captura de pantalla y hotkeys funcionan sin fricción).
- Si en el futuro quieres publicarla en el **Mac App Store**, deberás activar
  App Sandbox y migrar la captura de `CGWindowListCreateImage` (API en proceso
  de deprecación) a **ScreenCaptureKit**, que es el reemplazo moderno recomendado
  por Apple para captura de pantalla en apps sandboxed.

## 5. Permisos que macOS pedirá en tiempo de ejecución
1. **Screen Recording** (Grabación de pantalla): se solicita automáticamente al
   primer intento de captura. Debes ir a **Ajustes del Sistema → Privacidad y
   Seguridad → Grabación de pantalla**, activar `ScreenshotAgent` y **relanzar
   la app** (macOS lo exige tras otorgar el permiso).
2. **Accesibilidad**: con la implementación entregada (Carbon `RegisterEventHotKey`)
   **NO es necesaria** para el atajo global. Solo tendrías que solicitarla si en
   el futuro decides capturar eventos de teclado con `CGEventTap` o
   `NSEvent.addGlobalMonitorForEvents` en vez del enfoque de Carbon.

## 6. Compilar y ejecutar
1. `⌘R` en Xcode.
2. La app no mostrará ventana ni ícono en el Dock; busca el ícono de cámara en
   la barra de menú superior.
3. Presiona `⌘⇧X` (o usa el menú del ícono) para iniciar una captura.
4. Arrastra para seleccionar el área; al soltar aparece la barra flotante con
   Copiar / Guardar / Anotar / OCR / QR.

## 7. Notas sobre rendimiento (RAM/CPU)
- No hay timers, polling ni observadores activos mientras la app está inactiva:
  el hotkey es 100% basado en eventos del sistema (Carbon), sin costo de CPU.
- Las ventanas de overlay y la barra flotante se crean **bajo demanda** y se
  liberan (`orderOut` + se sueltan las referencias) al terminar cada flujo, por
  lo que no permanecen en memoria entre capturas.
- `NSApp.setActivationPolicy(.accessory)` evita el overhead de una app con
  ventana principal completa.

## 8. Limitaciones conocidas / mejoras recomendadas
- **Multi-monitor**: la conversión de coordenadas en `ScreenCaptureManager`
  asume una disposición horizontal simple. Para arreglos verticales o con
  desplazamientos complejos entre monitores, conviene capturar directamente
  usando el `CGDirectDisplayID` de la pantalla donde ocurrió la selección.
- **Precisión de anotaciones**: el `Canvas` de `AnnotationView` dibuja en las
  coordenadas de la vista mostrada (ajustada con `aspectRatio(.fit)`), mientras
  que `flattenAnnotations()` compone sobre el tamaño real de la imagen. Si la
  ventana no coincide en proporciones exactas con la imagen, puede haber un
  pequeño desfase. Para precisión perfecta, calcula el factor de escala real
  (tamaño renderizado ÷ `image.size`) y aplícalo a los puntos antes de dibujar.
- `CGWindowListCreateImage` está marcada como deprecada desde macOS 14, aunque
  sigue funcionando. Si vas a mantener la app a largo plazo, considera migrar a
  **ScreenCaptureKit** (`SCScreenshotManager`, macOS 14+).
