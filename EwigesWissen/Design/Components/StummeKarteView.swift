import SwiftUI
import CoreLocation

// MARK: - Learning View (annotated map, no overlays needed)

/// Shows the annotated school atlas map for learning.
/// Supports pinch-to-zoom and pan gestures.
struct StummeKarteLernView: View {
    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private static let imageAspectRatio: CGFloat = 2561.0 / 1809.0

    var body: some View {
        GeometryReader { geo in
            let imgH = geo.size.height
            let imgW = imgH * Self.imageAspectRatio

            Image("StummeKarteBeschriftet")
                .resizable()
                .frame(width: imgW, height: imgH)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .scaleEffect(zoom)
                .offset(offset)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            zoom = min(max(lastZoom * value.magnification, 1.0), 5.0)
                        }
                        .onEnded { _ in
                            lastZoom = zoom
                            if zoom <= 1.0 {
                                withAnimation(.spring(duration: 0.3)) {
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(duration: 0.3)) {
                        if zoom > 1.5 {
                            zoom = 1.0
                            lastZoom = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            zoom = 3.0
                            lastZoom = 3.0
                        }
                    }
                }
                .clipShape(Rectangle())
        }
    }
}

// MARK: - Quiz View (blank map with tap-to-place pins)

/// Shows the blank school atlas map for quiz mode.
/// Uses Robinson projection for coordinate mapping.
struct StummeKarteQuizView: View {
    let onTap: (CLLocationCoordinate2D) -> Void
    let showTapPin: CLLocationCoordinate2D?
    let resultAnnotation: StummeKarteResultAnnotation?

    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private static let imageAspectRatio: CGFloat = 2561.0 / 1809.0

    // Robinson projection ellipse position within the image (fractions of image size)
    // Measured from grid lines on the actual ÖBV Schulatlas image (2561x1809px)
    private static let ellipseCenterX: CGFloat = 0.500
    private static let ellipseCenterY: CGFloat = 0.508
    private static let ellipseHalfW: CGFloat = 0.486
    private static let ellipseHalfH: CGFloat = 0.413

    var body: some View {
        GeometryReader { geo in
            let imgH = geo.size.height
            let imgW = imgH * Self.imageAspectRatio
            let imgSize = CGSize(width: imgW, height: imgH)

            Image("StummeKarte")
                .resizable()
                .frame(width: imgW, height: imgH)
                .overlay {
                    GeometryReader { overlayGeo in
                        pinsOverlay(imageSize: overlayGeo.size)
                    }
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .scaleEffect(zoom)
                .offset(offset)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            zoom = min(max(lastZoom * value.magnification, 1.0), 5.0)
                        }
                        .onEnded { _ in
                            lastZoom = zoom
                            if zoom <= 1.0 {
                                withAnimation(.spring(duration: 0.3)) {
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            let centerX = geo.size.width / 2
                            let centerY = geo.size.height / 2
                            let tapInContainer = CGPoint(
                                x: (value.location.x - centerX - offset.width) / zoom + centerX,
                                y: (value.location.y - centerY - offset.height) / zoom + centerY
                            )
                            let imageOriginX = (geo.size.width - imgW) / 2
                            let tapInImage = CGPoint(
                                x: tapInContainer.x - imageOriginX,
                                y: tapInContainer.y
                            )
                            let coord = Self.pointToCoordinate(tapInImage, in: imgSize)
                            onTap(coord)
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(duration: 0.3)) {
                        if zoom > 1.5 {
                            zoom = 1.0
                            lastZoom = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            zoom = 3.0
                            lastZoom = 3.0
                        }
                    }
                }
                .clipShape(Rectangle())
        }
    }

    // MARK: - Pin Overlay

    @ViewBuilder
    private func pinsOverlay(imageSize: CGSize) -> some View {
        if let pin = showTapPin {
            let pos = Self.coordinateToPoint(pin, in: imageSize)
            let color = resultAnnotation != nil
                ? (resultAnnotation!.isCorrect ? Color.green : Color.red)
                : AppColors.primary
            pinMarker(at: pos, color: color, icon: nil)
        }

        if let result = resultAnnotation {
            let pos = Self.coordinateToPoint(result.coordinate, in: imageSize)
            // Tolerance circle: compute pixel radius from km
            let radiusPx = Self.kmToPixels(result.toleranceRadiusKm, at: result.coordinate, in: imageSize)
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
            // Line
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 20)
                .position(x: pos.x, y: pos.y - 10)
            // Dot
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .overlay { Circle().strokeBorder(.white, lineWidth: 1.5) }
                .position(pos)
            // Icon
            ZStack {
                Circle().fill(color).frame(width: 20, height: 20)
                Image(systemName: icon ?? "mappin")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
            .position(x: pos.x, y: pos.y - 24)
        }
    }

    // MARK: - Robinson Projection

    private static let robinsonTable: [(lat: Double, plen: Double, pdfe: Double)] = [
        (0,  1.0000, 0.0000), (5,  0.9986, 0.0620), (10, 0.9954, 0.1240),
        (15, 0.9900, 0.1860), (20, 0.9822, 0.2480), (25, 0.9730, 0.3100),
        (30, 0.9600, 0.3720), (35, 0.9427, 0.4340), (40, 0.9216, 0.4958),
        (45, 0.8962, 0.5571), (50, 0.8679, 0.6176), (55, 0.8350, 0.6769),
        (60, 0.7986, 0.7346), (65, 0.7597, 0.7903), (70, 0.7186, 0.8435),
        (75, 0.6732, 0.8936), (80, 0.6213, 0.9394), (85, 0.5722, 0.9761),
        (90, 0.5322, 1.0000),
    ]

    private static func robinsonPLEN(_ absLat: Double) -> Double {
        let clamped = min(max(absLat, 0), 90)
        let index = clamped / 5.0
        let i = min(Int(index), robinsonTable.count - 2)
        let frac = index - Double(i)
        return robinsonTable[i].plen + frac * (robinsonTable[i + 1].plen - robinsonTable[i].plen)
    }

    private static func robinsonPDFE(_ absLat: Double) -> Double {
        let clamped = min(max(absLat, 0), 90)
        let index = clamped / 5.0
        let i = min(Int(index), robinsonTable.count - 2)
        let frac = index - Double(i)
        return robinsonTable[i].pdfe + frac * (robinsonTable[i + 1].pdfe - robinsonTable[i].pdfe)
    }

    /// Convert a distance in km to approximate pixel radius on the map
    static func kmToPixels(_ km: Double, at coordinate: CLLocationCoordinate2D, in size: CGSize) -> CGFloat {
        // Earth circumference at equator ≈ 40075 km
        // Map width at equator in pixels = 2 * ellipseHalfW * size.width
        // This represents 360° = 40075 km
        let mapWidthAtEquator = 2.0 * Double(ellipseHalfW) * Double(size.width)
        let kmPerPixelAtEquator = 40075.0 / mapWidthAtEquator
        // Adjust for latitude (Robinson PLEN makes map narrower at higher latitudes)
        let plen = robinsonPLEN(abs(coordinate.latitude))
        let kmPerPixel = kmPerPixelAtEquator / max(plen, 0.3)
        return CGFloat(km / kmPerPixel)
    }

    static func coordinateToPoint(_ coordinate: CLLocationCoordinate2D, in size: CGSize) -> CGPoint {
        let plen = robinsonPLEN(abs(coordinate.latitude))
        let pdfe = robinsonPDFE(abs(coordinate.latitude))
        let xNorm = plen * coordinate.longitude / 180.0
        let yNorm = pdfe * (coordinate.latitude >= 0 ? -1.0 : 1.0)
        return CGPoint(
            x: size.width * ellipseCenterX + xNorm * size.width * ellipseHalfW,
            y: size.height * ellipseCenterY + yNorm * size.height * ellipseHalfH
        )
    }

    static func pointToCoordinate(_ point: CGPoint, in size: CGSize) -> CLLocationCoordinate2D {
        let xNorm = (point.x - size.width * ellipseCenterX) / (size.width * ellipseHalfW)
        let yNorm = (point.y - size.height * ellipseCenterY) / (size.height * ellipseHalfH)
        let isNorth = yNorm < 0
        let absPdfe = min(abs(yNorm), 1.0)
        let absLat = inversePDFE(absPdfe)
        let lat = isNorth ? absLat : -absLat
        let plen = robinsonPLEN(absLat)
        let lon = plen > 0.001 ? xNorm / plen * 180.0 : 0
        return CLLocationCoordinate2D(
            latitude: max(-85, min(85, lat)),
            longitude: max(-180, min(180, lon))
        )
    }

    private static func inversePDFE(_ pdfe: Double) -> Double {
        let clamped = min(max(pdfe, 0), 1.0)
        for i in 0..<(robinsonTable.count - 1) {
            let p0 = robinsonTable[i].pdfe
            let p1 = robinsonTable[i + 1].pdfe
            if clamped >= p0 && clamped <= p1 {
                let frac = (p1 - p0) > 0 ? (clamped - p0) / (p1 - p0) : 0
                return robinsonTable[i].lat + frac * 5.0
            }
        }
        return 90.0
    }
}

struct StummeKarteResultAnnotation {
    let coordinate: CLLocationCoordinate2D
    let isCorrect: Bool
    let toleranceRadiusKm: Double
}
