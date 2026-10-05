import Foundation

/// Mode de sélection pour le nettoyage personnalisé.
public enum SelectionMode: Equatable {
    case all
    case manualSelection
    case byDate(targetDate: Date)
    case byPeriod(startDate: Date, endDate: Date)
    
    public var title: String {
        switch self {
        case .all: return "Tout"
        case .manualSelection: return "Sélection manuelle"
        case .byDate: return "Par date"
        case .byPeriod: return "Par période"
        }
    }
}

/// Configuration détaillée d'une session de nettoyage personnalisé.
public struct CleanupConfiguration {
    public var selectedCategories: Set<CleanupCategory>
    public var selectionMode: SelectionMode
    public var customSelectedItems: [CleanableItem]?
    
    public init(
        selectedCategories: Set<CleanupCategory> = [.likes, .reposts],
        selectionMode: SelectionMode = .all,
        customSelectedItems: [CleanableItem]? = nil
    ) {
        self.selectedCategories = selectedCategories
        self.selectionMode = selectionMode
        self.customSelectedItems = customSelectedItems
    }
}
