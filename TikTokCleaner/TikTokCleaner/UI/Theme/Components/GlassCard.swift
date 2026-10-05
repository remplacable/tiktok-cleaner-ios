import SwiftUI

/// Carte moderne au style sobre et contrasté pour l'interface TikTok Cleaner.
public struct GlassCard<Content: View>: View {
    public let content: Content
    public var padding: CGFloat
    
    public init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(Color.appCard)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.appCardBorder, lineWidth: 1)
            )
    }
}
