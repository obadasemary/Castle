import SwiftUI

public struct ProgressRing: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let tint: Color
    private let track: Color

    public init(
        progress: Double,
        lineWidth: CGFloat = 8,
        tint: Color = .castleAccentBrand,
        track: Color = .castleSurfaceMuted
    ) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.tint = tint
        self.track = track
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(track, style: StrokeStyle(lineWidth: lineWidth))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
    }
}

public struct ProgressBar: View {
    private let progress: Double
    private let tint: Color
    private let track: Color
    private let height: CGFloat

    public init(
        progress: Double,
        tint: Color = .castleAccentBrand,
        track: Color = .castleSurfaceMuted,
        height: CGFloat = 8
    ) {
        self.progress = max(0, min(1, progress))
        self.tint = tint
        self.track = track
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule()
                    .fill(tint)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: height)
    }
}
