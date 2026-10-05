import Foundation
import Combine

/// Gestionnaire des favoris et vidéos enregistrées.
public final class FavoritesManager: ObservableObject {
    public static let shared = FavoritesManager()
    
    @Published public private(set) var items: [CleanableItem] = []
    @Published public private(set) var isLoading: Bool = false
    
    private init() {}
    
    public func setItems(_ newItems: [CleanableItem]) {
        self.items = newItems.filter { $0.category == .favorites }
    }
    
    public func addItems(_ newItems: [CleanableItem]) {
        let favsOnly = newItems.filter { $0.category == .favorites }
        let existingIds = Set(items.map { $0.id })
        let filtered = favsOnly.filter { !existingIds.contains($0.id) }
        self.items.append(contentsOf: filtered)
    }
    
    public func removeItem(withId id: String) {
        items.removeAll { $0.id == id }
    }
    
    public func toggleSelection(for id: String) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isSelected.toggle()
        }
    }
    
    public func selectAll(_ select: Bool) {
        for index in items.indices {
            items[index].isSelected = select
        }
    }
    
    public var selectedItems: [CleanableItem] {
        items.filter { $0.isSelected }
    }
    
    public var selectedCount: Int {
        selectedItems.count
    }
    
    public var totalCount: Int {
        items.count
    }
}
