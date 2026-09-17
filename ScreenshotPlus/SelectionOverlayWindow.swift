import Cocoa

final class SelectionOverlayWindow: NSWindow {
    init(screen: NSScreen,
         onComplete: @escaping (CGRect, NSScreen) -> Void,
         onCancel: @escaping () -> Void) {
        super.init(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)

        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = false
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        let view = SelectionOverlayView(frame: NSRect(origin: .zero, size: screen.frame.size))
        view.onComplete = { localRect in
            let globalRect = CGRect(x: screen.frame.minX + localRect.minX,
                                     y: screen.frame.minY + localRect.minY,
                                     width: localRect.width,
                                     height: localRect.height)
            onComplete(globalRect, screen)
        }
        view.onCancel = onCancel

        self.contentView = view
        self.makeFirstResponder(view)
    }

    override var canBecomeKey: Bool { true }
}

final class SelectionOverlayView: NSView {
    var onComplete: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?

    private var startPoint: CGPoint?
    private var currentRect: CGRect = .zero

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        startPoint = point
        currentRect = CGRect(origin: point, size: .zero)
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let point = convert(event.locationInWindow, from: nil)
        currentRect = CGRect(x: min(start.x, point.x), y: min(start.y, point.y),
                              width: abs(point.x - start.x), height: abs(point.y - start.y))
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        onComplete?(currentRect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Esc
            onCancel?()
        }
    }

    override var acceptsFirstResponder: Bool { true }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()

        guard currentRect.width > 0 || currentRect.height > 0 else { return }

        // "Recorta" visualmente la zona seleccionada dejándola sin oscurecer.
        NSGraphicsContext.current?.saveGraphicsState()
        NSColor.clear.setFill()
        currentRect.fill(using: .copy)
        NSGraphicsContext.current?.restoreGraphicsState()

        NSColor.white.setStroke()
        let path = NSBezierPath(rect: currentRect)
        path.lineWidth = 1.5
        path.stroke()

        let text = "\(Int(currentRect.width)) × \(Int(currentRect.height))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black.withAlphaComponent(0.6)
        ]
        text.draw(at: CGPoint(x: currentRect.minX, y: currentRect.maxY + 4), withAttributes: attrs)
    }
}
