import SwiftUI

public enum TikTokButtonStyle {
    case primary
    case secondary
    case destructive
    case outline
}

public struct TikTokButton: View {
    public let title: String
    public let icon: String?
    public let style: TikTokButtonStyle
    public let isLoading: Bool
    public let action: () -> Void
    
    public init(
        title: String,
        icon: String? = nil,
        style: TikTokButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.9)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .default))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: style == .outline ? 1.5 : 1)
            )
            .shadow(color: shadowColor, radius: style == .primary ? 8 : 0, x: 0, y: 3)
        }
        .disabled(isLoading)
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .tiktokRed
        case .secondary:
            return .appCard
        case .destructive:
            return .appError.opacity(0.18)
        case .outline:
            return Color.clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .appTextPrimary
        case .destructive:
            return .appError
        case .outline:
            return .appTextPrimary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.white.opacity(0.1)
        case .secondary:
            return .appCardBorder
        case .destructive:
            return .appError.opacity(0.4)
        case .outline:
            return .appCardBorder
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return .tiktokRed.opacity(0.3)
        default:
            return .clear
        }
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
