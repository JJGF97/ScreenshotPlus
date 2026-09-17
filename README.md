# ScreenshotPlus

🇲🇽 [Español](#español) | 🇺🇸 [English](#english)

---

## Español

App nativa y ligera para macOS que vive en la barra de menú: captura de pantalla por área, anotación, extracción de texto (OCR) y generación de códigos QR — sin depender de la app Atajos.

Hecha 100% en Swift + SwiftUI, sin dependencias externas.

### Capturas de pantalla

<!-- Arrastra aquí tus imágenes al editar este archivo desde la web de GitHub -->

### Características

- 📌 Agente de barra de menú (sin ícono en el Dock)
- ⌨️ Atajo global configurable (por default `⌘⇧X`)
- ✂️ Selección de área tipo crop/crosshair
- 📋 Copiar al portapapeles o guardar como PNG/JPG
- ✏️ Anotación: líneas, formas, flechas y texto sobre la captura
- 🔎 OCR nativo con el framework Vision de Apple
- 🔳 Generación de código QR con Core Image
- 🚀 Inicio automático al abrir sesión (opcional)

### Requisitos

- macOS 14.0 o superior
- Xcode 15 o superior (para compilarlo desde el código fuente)

### Instalación

**Opción 1 — Descargar la app compilada**
Ve a la sección [Releases](../../releases) de este repositorio y descarga la última versión.

**Opción 2 — Compilar desde el código fuente**
1. Clona este repositorio.
2. Ábrelo con Xcode (`ScreenshotPlus.xcodeproj`).
3. Compila y ejecuta con `⌘R`.

La primera vez que uses la función de captura, macOS te pedirá el permiso de **Grabación de Pantalla** (Ajustes del Sistema → Privacidad y Seguridad).

### ¿Te resulta útil?

Si te ahorra tiempo, puedes invitarme un café ☕️:

[![Ko-fi](https://img.shields.io/badge/Ko--fi-donate-FF5E5B)](https://ko-fi.com/flowmac)

### Contribuir

¿Encontraste un bug o tienes una idea? Revisa [CONTRIBUTING.md](CONTRIBUTING.md).

### Licencia

Este proyecto está bajo la licencia MIT — consulta el archivo [LICENSE](LICENSE) para más detalles.

---

## English

Lightweight native macOS menu bar app: area screenshot capture, annotation, text extraction (OCR), and QR code generation — no need for the Shortcuts app.

Built 100% with Swift + SwiftUI, no external dependencies.

### Screenshots

<!-- Drag your images here while editing this file from the GitHub web UI -->

### Features

- 📌 Menu bar agent (no Dock icon)
- ⌨️ Configurable global shortcut (default `⌘⇧X`)
- ✂️ Crop/crosshair-style area selection
- 📋 Copy to clipboard or save as PNG/JPG
- ✏️ Annotation: lines, shapes, arrows, and text over the capture
- 🔎 Native OCR using Apple's Vision framework
- 🔳 QR code generation with Core Image
- 🚀 Optional launch at login

### Requirements

- macOS 14.0 or later
- Xcode 15 or later (to build from source)

### Installation

**Option 1 — Download the compiled app**
Go to the [Releases](../../releases) section of this repository and download the latest version.

**Option 2 — Build from source**
1. Clone this repository.
2. Open it with Xcode (`ScreenshotPlus.xcodeproj`).
3. Build and run with `⌘R`.

The first time you use the capture feature, macOS will ask for **Screen Recording** permission (System Settings → Privacy & Security).

### Found it useful?

If it saves you time, you can buy me a coffee ☕️:

[![Ko-fi](https://img.shields.io/badge/Ko--fi-donate-FF5E5B)](https://ko-fi.com/flowmac)

### Contributing

Found a bug or have an idea? Check out [CONTRIBUTING.md](CONTRIBUTING.md).

### License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
