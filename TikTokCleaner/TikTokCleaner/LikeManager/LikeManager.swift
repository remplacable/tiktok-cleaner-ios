import Foundation
import Combine

/// Gestionnaire des vidéos aimées (Likes).
public final class LikeManager: ObservableObject {
    public static let shared = LikeManager()
    
    @Published public private(set) var items: [CleanableItem] = []
    @Published public private(set) var isLoading: Bool = false
    
    private init() {}
    
    public func setItems(_ newItems: [CleanableItem]) {
        self.items = newItems.filter { $0.category == .likes }
    }
    
    public func addItems(_ newItems: [CleanableItem]) {
        let likesOnly = newItems.filter { $0.category == .likes }
        let existingIds = Set(items.map { $0.id })
        let filtered = likesOnly.filter { !existingIds.contains($0.id) }
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
