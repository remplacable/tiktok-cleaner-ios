import Foundation
import Combine

/// Gestionnaire des vidéos publiées par l'utilisateur.
public final class PostManager: ObservableObject {
    public static let shared = PostManager()
    
    @Published public private(set) var items: [CleanableItem] = []
    @Published public private(set) var isLoading: Bool = false
    
    private init() {}
    
    public func setItems(_ newItems: [CleanableItem]) {
        self.items = newItems.filter { $0.category == .posts }
    }
    
    public func addItems(_ newItems: [CleanableItem]) {
        let postsOnly = newItems.filter { $0.category == .posts }
        let existingIds = Set(items.map { $0.id })
        let filtered = postsOnly.filter { !existingIds.contains($0.id) }
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
