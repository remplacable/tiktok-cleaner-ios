import SwiftUI

/// Barre de progression moderne avec dégradé subtil et animation fluide.
public struct ModernProgressBar: View {
    public let progress: Double // 0.0 à 1.0
    public var tintColor: Color = .tiktokRed
    public var height: CGFloat = 8
    public var showPercentage: Bool = false
    
    public init(
        progress: Double,
        tintColor: Color = .tiktokRed,
        height: CGFloat = 8,
        showPercentage: Bool = false
    ) {
        self.progress = max(0.0, min(1.0, progress))
        self.tintColor = tintColor
        self.height = height
        self.showPercentage = showPercentage
    }
    
    public var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fond de la piste
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: height)
                    
                    // Remplissage avec dégradé
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tintColor.opacity(0.85), tintColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: height)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: height)
            
            if showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
    }
}
