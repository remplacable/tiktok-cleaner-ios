import SwiftUI

/// Badge visuel indiquant le statut ou la catégorie d'un élément.
public struct BadgeView: View {
    public let text: String
    public let color: Color
    public var icon: String? = nil
    
    public init(text: String, color: Color = .tiktokRed, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}
