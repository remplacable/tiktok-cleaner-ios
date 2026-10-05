import SwiftUI

/// Typographie et styles de texte de l'application.
public extension View {
    func statNumberStyle() -> some View {
        self.font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.appTextPrimary)
    }
    
    func cardTitleStyle() -> some View {
        self.font(.system(size: 17, weight: .semibold, design: .default))
            .foregroundColor(.appTextPrimary)
    }
    
    func sectionHeaderStyle() -> some View {
        self.font(.system(size: 13, weight: .semibold, design: .default))
            .foregroundColor(.appTextMuted)
            .textCase(.uppercase)
    }
}
