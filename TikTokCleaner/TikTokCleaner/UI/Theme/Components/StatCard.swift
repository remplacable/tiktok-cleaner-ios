import SwiftUI

/// Carte statistique affichant le décompte d'une catégorie de compte.
public struct StatCard: View {
    public let category: CleanupCategory
    public let count: Int
    public var isSelected: Bool = false
    public var onTap: (() -> Void)? = nil
    
    public init(
        category: CleanupCategory,
        count: Int,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.category = category
        self.count = count
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: category.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(category.symbolColor)
                    
                    Text(category.displayName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.tiktokRed)
                            .font(.system(size: 18))
                    }
                }
                
                Text(formattedNumber(count))
                    .statNumberStyle()
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.tiktokRed.opacity(0.08) : Color.appCard)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.tiktokRed.opacity(0.8) : Color.appCardBorder, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(onTap == nil)
    }
    
    private func formattedNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
}
