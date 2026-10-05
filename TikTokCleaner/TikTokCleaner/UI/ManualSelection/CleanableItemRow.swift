import SwiftUI

/// Ligne représentant un élément sélectionnable avec vignette, titre, auteur et date.
public struct CleanableItemRow: View {
    public let item: CleanableItem
    public let onToggle: () -> Void
    
    public init(item: CleanableItem, onToggle: @escaping () -> Void) {
        self.item = item
        self.onToggle = onToggle
    }
    
    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Case à cocher
                Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.isSelected ? .tiktokRed : .appTextMuted)
                
                // Vignette miniature avec lazy loading / AsyncImage
                thumbnailView
                
                // Métadonnées
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                    
                    if let author = item.authorUsername {
                        Text(author)
                            .font(.system(size: 13))
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    HStack(spacing: 8) {
                        Text(item.formattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(.appTextMuted)
                        
                        if let likes = item.likeCount {
                            Text("•  \(likes) likes")
                                .font(.system(size: 12))
                                .foregroundColor(.appTextMuted)
                        }
                    }
                }
                
                Spacer()
                
                // Icône de catégorie
                Image(systemName: item.category.iconName)
                    .font(.system(size: 13))
                    .foregroundColor(item.category.symbolColor.opacity(0.8))
            }
            .padding(12)
            .background(item.isSelected ? Color.tiktokRed.opacity(0.06) : Color.appCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(item.isSelected ? Color.tiktokRed.opacity(0.4) : Color.appCardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var thumbnailView: some View {
        Group {
            if let thumbUrl = item.thumbnailUrl {
                AsyncImage(url: thumbUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        fallbackThumbnail
                    @unknown default:
                        fallbackThumbnail
                    }
                }
            } else {
                fallbackThumbnail
            }
        }
        .frame(width: 52, height: 68)
        .cornerRadius(8)
        .clipped()
    }
    
    private var fallbackThumbnail: some View {
        ZStack {
            Color.white.opacity(0.06)
            Image(systemName: item.category.iconName)
                .font(.system(size: 20))
                .foregroundColor(item.category.symbolColor)
        }
    }
}
