import SwiftUI

enum AnnotationTool: String, CaseIterable {
    case pen = "pencil"
    case line = "line.diagonal"
    case rectangle = "rectangle"
    case arrow = "arrow.up.right"
    case text = "textformat"
}

struct AnnotationShape: Identifiable {
    let id = UUID()
    var tool: AnnotationTool
    var points: [CGPoint]
    var text: String = ""
    var color: Color = .red
}

struct AnnotationView: View {
    let image: NSImage
    let onFinish: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var shapes: [AnnotationShape] = []
    @State private var currentShape: AnnotationShape?
    @State private var selectedTool: AnnotationTool = .pen
    @State private var selectedColor: Color = .red
    @State private var showTextField = false
    @State private var textInput = ""
    @State private var pendingTextPoint: CGPoint?

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            canvasArea
            HStack {
                Button("Copiar resultado") {
                    ClipboardHelper.copyImage(flattenAnnotations())
                    dismiss(); onFinish()
                }
                Button("Guardar resultado") {
                    FileSaveHelper.saveImage(flattenAnnotations())
                    dismiss(); onFinish()
                }
                Button("Cancelar") { dismiss(); onFinish() }
            }
            .padding(10)
        }
        .frame(minWidth: 520, minHeight: 420)
        .sheet(isPresented: $showTextField) {
            VStack(spacing: 12) {
                Text("Agregar texto")
                TextField("Texto", text: $textInput).textFieldStyle(.roundedBorder)
                Button("Añadir") {
                    if let point = pendingTextPoint {
                        shapes.append(AnnotationShape(tool: .text, points: [point], text: textInput, color: selectedColor))
                    }
                    textInput = ""
                    showTextField = false
                }
            }
            .padding(20)
            .frame(width: 260)
        }
    }

    private var toolbar: some View {
        HStack {
            Picker("Herramienta", selection: $selectedTool) {
                ForEach(AnnotationTool.allCases, id: \.self) { Image(systemName: $0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            ColorPicker("", selection: $selectedColor).labelsHidden()
            Spacer()
            Button("Deshacer") { if !shapes.isEmpty { shapes.removeLast() } }
        }
        .padding(10)
    }

    private var canvasArea: some View {
        GeometryReader { geo in
            ZStack {
                Image(nsImage: image).resizable().aspectRatio(contentMode: .fit)
                Canvas { context, _ in
                    for shape in shapes { draw(shape: shape, in: &context) }
                    if let currentShape { draw(shape: currentShape, in: &context) }
                }
                .gesture(drawGesture())
            }
        }
        .aspectRatio(image.size.width / max(image.size.height, 1), contentMode: .fit)
        .border(Color.gray.opacity(0.3))
    }

    private func drawGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if selectedTool == .text { return }
                if currentShape == nil {
                    currentShape = AnnotationShape(tool: selectedTool, points: [value.startLocation], color: selectedColor)
                }
                if selectedTool == .pen {
                    currentShape?.points.append(value.location)
                } else {
                    currentShape?.points = [value.startLocation, value.location]
                }
            }
            .onEnded { value in
                if selectedTool == .text {
                    pendingTextPoint = value.location
                    showTextField = true
                    return
                }
                if let shape = currentShape { shapes.append(shape) }
                currentShape = nil
            }
    }

    private func draw(shape: AnnotationShape, in context: inout GraphicsContext) {
        switch shape.tool {
        case .pen:
            guard shape.points.count > 1 else { return }
            var path = Path(); path.addLines(shape.points)
            context.stroke(path, with: .color(shape.color), lineWidth: 3)
        case .line:
            guard shape.points.count == 2 else { return }
            var path = Path(); path.move(to: shape.points[0]); path.addLine(to: shape.points[1])
            context.stroke(path, with: .color(shape.color), lineWidth: 3)
        case .rectangle:
            guard shape.points.count == 2 else { return }
            let rect = CGRect(x: shape.points[0].x, y: shape.points[0].y,
                               width: shape.points[1].x - shape.points[0].x,
                               height: shape.points[1].y - shape.points[0].y)
            context.stroke(Path(rect), with: .color(shape.color), lineWidth: 3)
        case .arrow:
            guard shape.points.count == 2 else { return }
            drawArrow(from: shape.points[0], to: shape.points[1], color: shape.color, in: &context)
        case .text:
            guard let point = shape.points.first else { return }
            context.draw(Text(shape.text).foregroundColor(shape.color).font(.system(size: 18, weight: .bold)), at: point)
        }
    }

    private func drawArrow(from start: CGPoint, to end: CGPoint, color: Color, in context: inout GraphicsContext) {
        var path = Path(); path.move(to: start); path.addLine(to: end)
        context.stroke(path, with: .color(color), lineWidth: 3)

        let angle = atan2(end.y - start.y, end.x - start.x)
        let length: CGFloat = 12
        let spread: CGFloat = .pi / 6
        let p1 = CGPoint(x: end.x - length * cos(angle - spread), y: end.y - length * sin(angle - spread))
        let p2 = CGPoint(x: end.x - length * cos(angle + spread), y: end.y - length * sin(angle + spread))
        var head = Path(); head.move(to: end); head.addLine(to: p1); head.move(to: end); head.addLine(to: p2)
        context.stroke(head, with: .color(color), lineWidth: 3)
    }

    /// NOTA IMPORTANTE: esta función asume que el Canvas se muestra a la misma escala
    /// que "image.size". Como la imagen se ajusta con aspectRatio(.fit) dentro de un
    /// GeometryReader, para un mapeo 100% preciso en cualquier tamaño de ventana
    /// conviene calcular el factor de escala real (tamaño mostrado vs. image.size)
    /// y aplicarlo aquí antes de dibujar cada forma. Se deja como mejora recomendada.
    private func flattenAnnotations() -> NSImage {
        let size = image.size
        let result = NSImage(size: size)
        result.lockFocus()
        image.draw(in: CGRect(origin: .zero, size: size))
        if let context = NSGraphicsContext.current?.cgContext {
            for shape in shapes { drawOnCGContext(shape: shape, context: context) }
        }
        result.unlockFocus()
        return result
    }

    private func drawOnCGContext(shape: AnnotationShape, context: CGContext) {
        context.setStrokeColor(NSColor(shape.color).cgColor)
        context.setLineWidth(3)
        switch shape.tool {
        case .pen, .line:
            guard shape.points.count > 1 else { return }
            context.move(to: shape.points[0])
            shape.points.dropFirst().forEach { context.addLine(to: $0) }
            context.strokePath()
        case .rectangle:
            guard shape.points.count == 2 else { return }
            let rect = CGRect(x: shape.points[0].x, y: shape.points[0].y,
                               width: shape.points[1].x - shape.points[0].x,
                               height: shape.points[1].y - shape.points[0].y)
            context.stroke(rect)
        case .arrow:
            guard shape.points.count == 2 else { return }
            context.move(to: shape.points[0]); context.addLine(to: shape.points[1]); context.strokePath()
        case .text:
            guard let point = shape.points.first else { return }
            let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: 18),
                                                          .foregroundColor: NSColor(shape.color)]
            NSAttributedString(string: shape.text, attributes: attrs).draw(at: point)
        }
    }
}
