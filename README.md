# ScreenshotPlus

App nativa y ligera para macOS que vive en la barra de menú: captura de pantalla por área, anotación, extracción de texto (OCR) y generación de códigos QR — sin depender de la app Atajos.

Hecha 100% en Swift + SwiftUI, sin dependencias externas.

## Características

- 📌 Agente de barra de menú (sin ícono en el Dock)
- ⌨️ Atajo global configurable (por default `⌘⇧X`)
- ✂️ Selección de área tipo crop/crosshair
- 📋 Copiar al portapapeles o guardar como PNG/JPG
- ✏️ Anotación: líneas, formas, flechas y texto sobre la captura
- 🔎 OCR nativo con el framework Vision de Apple
- 🔳 Generación de código QR con Core Image
- 🚀 Inicio automático al abrir sesión (opcional)

## Requisitos

- macOS 14.0 o superior
- Xcode 15 o superior (para compilarlo desde el código fuente)

## Instalación

### Opción 1 — Descargar la app compilada
Ve a la sección [Releases](../../releases) de este repositorio y descarga la última versión.

### Opción 2 — Compilar desde el código fuente
1. Clona este repositorio.
2. Ábrelo con Xcode (`ScreenshotPlus.xcodeproj`).
3. Compila y ejecuta con `⌘R`.

La primera vez que uses la función de captura, macOS te pedirá el permiso de **Grabación de Pantalla** (Ajustes del Sistema → Privacidad y Seguridad).

## ¿Te resulta útil?

Si te ahorra tiempo, puedes invitarme un café ☕️:

[![Ko-fi](https://img.shields.io/badge/Ko--fi-donate-FF5E5B)](https://ko-fi.com/flowmac)

## Contribuir

¿Encontraste un bug o tienes una idea? Revisa [CONTRIBUTING.md](CONTRIBUTING.md).

## Licencia

Este proyecto está bajo la licencia MIT — consulta el archivo [LICENSE](LICENSE) para más detalles.
