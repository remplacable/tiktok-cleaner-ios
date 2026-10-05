import Foundation
import Combine

/// Modèle de vue pilotant l'écran de configuration du nettoyage personnalisé.
public final class CustomCleanupViewModel: ObservableObject {
    @Published public var selectedCategories: Set<CleanupCategory> = [.likes, .reposts]
    @Published public var selectionMode: SelectionMode = .all
    @Published public var targetDate: Date = Date()
    @Published public var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published public var endDate: Date = Date()
    @Published public var showManualSelectionSheet = false
    @Published public var selectedCategoryForManualReview: CleanupCategory? = nil
    
    public init() {}
    
    public func toggleCategory(_ category: CleanupCategory) {
        if selectedCategories.contains(category) {
            if selectedCategories.count > 1 {
                selectedCategories.remove(category)
            }
        } else {
            selectedCategories.insert(category)
        }
    }
    
    public func isCategorySelected(_ category: CleanupCategory) -> Bool {
        selectedCategories.contains(category)
    }
    
    public func buildConfiguration() -> CleanupConfiguration {
        let finalMode: SelectionMode
        switch selectionMode {
        case .all:
            finalMode = .all
        case .manualSelection:
            finalMode = .manualSelection
        case .byDate:
            finalMode = .byDate(targetDate: targetDate)
        case .byPeriod:
            finalMode = .byPeriod(startDate: startDate, endDate: endDate)
        }
        
        return CleanupConfiguration(
            selectedCategories: selectedCategories,
            selectionMode: finalMode,
            customSelectedItems: nil
        )
    }
    
    public var estimatedCount: Int {
        var count = 0
        let account = AuthManager.shared.currentAccount
        if selectedCategories.contains(.likes) { count += account?.likesCount ?? 0 }
        if selectedCategories.contains(.posts) { count += account?.videosCount ?? 0 }
        if selectedCategories.contains(.reposts) { count += account?.repostsCount ?? 0 }
        if selectedCategories.contains(.favorites) { count += account?.favoritesCount ?? 0 }
        return count
    }
}
