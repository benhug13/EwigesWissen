import SwiftUI

private enum NAMap {
    static let imageAspectRatio: CGFloat = 713.0 / 810.0
    /// Image is 713 px wide; the d-maps scale bar shows 1000 km ≈ ~100 px → 0.14 fraction.
    /// So 1 km ≈ 0.00014 of the image width.
    static let kmPerWidthFraction: Double = 1000.0 / 0.14
}

// MARK: - Learning View (blank map with item pins + labels)

struct StummeKarteNordamerikaLernView: View {
    let items: [GeographyItem]

    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let imgH = min(geo.size.height, geo.size.width / NAMap.imageAspectRatio)
            let imgW = imgH * NAMap.imageAspectRatio

            Image("StummeKarteNordamerika")
                .resizable()
                .frame(width: imgW, height: imgH)
                .overlay {
                    ZStack {
                        ForEach(items.filter { $0.naMapPoint != nil }) { item in
                            annotation(for: item, imageSize: CGSize(width: imgW, height: imgH))
                        }
                    }
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .scaleEffect(zoom)
                .offset(offset)
                .gesture(magnifyGesture)
                .simultaneousGesture(dragGesture)
                .onTapGesture(count: 2) { toggleZoom() }
                .clipShape(Rectangle())
        }
    }

    private func annotation(for item: GeographyItem, imageSize: CGSize) -> some View {
        let p = item.naMapPoint!
        return VStack(spacing: 2) {
            Image(systemName: item.type.iconName)
                .font(.system(size: 9, weight: .bold))
                .padding(5)
                .background(AppColors.geographyColor(for: item.type))
                .foregroundStyle(.white)
                .clipShape(Circle())
            Text(item.name)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .position(x: imageSize.width * p.x, y: imageSize.height * p.y)
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { zoom = min(max(lastZoom * $0.magnification, 1.0), 5.0) }
            .onEnded { _ in
                lastZoom = zoom
                if zoom <= 1.0 {
                    withAnimation(.spring(duration: 0.3)) { offset = .zero; lastOffset = .zero }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged {
                offset = CGSize(
                    width: lastOffset.width + $0.translation.width,
                    height: lastOffset.height + $0.translation.height
                )
            }
            .onEnded { _ in lastOffset = offset }
    }

    private func toggleZoom() {
        withAnimation(.spring(duration: 0.3)) {
            if zoom > 1.5 {
                zoom = 1.0; lastZoom = 1.0; offset = .zero; lastOffset = .zero
            } else {
                zoom = 3.0; lastZoom = 3.0
            }
        }
    }
}

// MARK: - Quiz View (blank map, tap-to-place pin, returns image-space fraction)

struct StummeKarteNordamerikaQuizView: View {
    let onTap: (CGPoint) -> Void
    let placedFraction: CGPoint?
    let correctFraction: CGPoint?
    let isCorrect: Bool
    let toleranceKm: Double

    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let imgH = min(geo.size.height, geo.size.width / NAMap.imageAspectRatio)
            let imgW = imgH * NAMap.imageAspectRatio
            let imgSize = CGSize(width: imgW, height: imgH)

            Image("StummeKarteNordamerika")
                .resizable()
                .frame(width: imgW, height: imgH)
                .overlay {
                    GeometryReader { _ in
                        pinsOverlay(imageSize: imgSize)
                    }
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .scaleEffect(zoom)
                .offset(offset)
                .gesture(magnifyGesture)
                .simultaneousGesture(dragGesture)
                .simultaneousGesture(tapGesture(geoSize: geo.size, imageSize: imgSize))
                .onTapGesture(count: 2) { toggleZoom() }
                .clipShape(Rectangle())
        }
    }

    @ViewBuilder
    private func pinsOverlay(imageSize: CGSize) -> some View {
        if let placed = placedFraction {
            let pos = CGPoint(x: imageSize.width * placed.x, y: imageSize.height * placed.y)
            let color = correctFraction != nil
                ? (isCorrect ? Color.green : Color.red)
                : AppColors.primary
            pinMarker(at: pos, color: color, icon: nil)
        }
        if let correct = correctFraction {
            let pos = CGPoint(x: imageSize.width * correct.x, y: imageSize.height * correct.y)
            let radiusPx = CGFloat(toleranceKm / NAMap.kmPerWidthFraction) * imageSize.width
            Circle()
                .fill(Color.green.opacity(0.15))
                .stroke(Color.green, lineWidth: 2)
                .frame(width: radiusPx * 2, height: radiusPx * 2)
                .position(pos)
            pinMarker(at: pos, color: .green, icon: "checkmark")
        }
    }

    private func pinMarker(at pos: CGPoint, color: Color, icon: String?) -> some View {
        ZStack {
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 20)
                .position(x: pos.x, y: pos.y - 10)
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .overlay { Circle().strokeBorder(.white, lineWidth: 1.5) }
                .position(pos)
            ZStack {
                Circle().fill(color).frame(width: 20, height: 20)
                Image(systemName: icon ?? "mappin")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
            .position(x: pos.x, y: pos.y - 24)
        }
    }

    private func tapGesture(geoSize: CGSize, imageSize: CGSize) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                let centerX = geoSize.width / 2
                let centerY = geoSize.height / 2
                let tapInContainer = CGPoint(
                    x: (value.location.x - centerX - offset.width) / zoom + centerX,
                    y: (value.location.y - centerY - offset.height) / zoom + centerY
                )
                let imageOriginX = (geoSize.width - imageSize.width) / 2
                let imageOriginY = (geoSize.height - imageSize.height) / 2
                let tapInImage = CGPoint(
                    x: tapInContainer.x - imageOriginX,
                    y: tapInContainer.y - imageOriginY
                )
                let fraction = CGPoint(
                    x: tapInImage.x / imageSize.width,
                    y: tapInImage.y / imageSize.height
                )
                if fraction.x >= 0, fraction.x <= 1, fraction.y >= 0, fraction.y <= 1 {
                    onTap(fraction)
                }
            }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { zoom = min(max(lastZoom * $0.magnification, 1.0), 5.0) }
            .onEnded { _ in
                lastZoom = zoom
                if zoom <= 1.0 {
                    withAnimation(.spring(duration: 0.3)) { offset = .zero; lastOffset = .zero }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged {
                offset = CGSize(
                    width: lastOffset.width + $0.translation.width,
                    height: lastOffset.height + $0.translation.height
                )
            }
            .onEnded { _ in lastOffset = offset }
    }

    private func toggleZoom() {
        withAnimation(.spring(duration: 0.3)) {
            if zoom > 1.5 {
                zoom = 1.0; lastZoom = 1.0; offset = .zero; lastOffset = .zero
            } else {
                zoom = 3.0; lastZoom = 3.0
            }
        }
    }
}

// MARK: - Distance helper

extension StummeKarteNordamerikaQuizView {
    /// Distance between two fractional points expressed in km, using the
    /// d-maps amnord09 scale (1000 km ≈ 14% of image width).
    static func distanceKm(from a: CGPoint, to b: CGPoint) -> Double {
        let dx = Double(a.x - b.x)
        let dy = Double(a.y - b.y)
        let fractionDistance = (dx * dx + dy * dy).squareRoot()
        return fractionDistance * NAMap.kmPerWidthFraction
    }
}
