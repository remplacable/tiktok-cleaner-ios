import SwiftUI

/// Vue de sélection manuelle granulaire pour une catégorie de contenu.
public struct ManualSelectionView: View {
    @Environment(\.presentationMode) private var presentationMode
    public let category: CleanupCategory
    
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .newestFirst
    @State private var filterOnlySelected = false
    @State private var showFilterSheet = false
    @State private var items: [CleanableItem] = []
    
    // Suivi de l'exécution
    @State private var showExecutionView = false
    
    public init(category: CleanupCategory) {
        self.category = category
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre supérieure
                topNavigationBar
                
                // Barre de recherche et actions globales
                controlsHeaderView
                
                // Liste défilante optimisée (LazyVStack)
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    itemsListView
                }
                
                // Barre inférieure de confirmation
                bottomActionBar
            }
        }
        .onAppear {
            loadItems()
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(currentSortOrder: $sortOrder, filterOnlySelected: $filterOnlySelected)
        }
        .fullScreenCover(isPresented: $showExecutionView) {
            CleanupProgressView {
                showExecutionView = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // MARK: - Composants
    
    private var topNavigationBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .foregroundColor(category.symbolColor)
                Text(category.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appTextPrimary)
            }
            
            Spacer()
            
            Button(action: { showFilterSheet = true }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(.trailing, 8)
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.appTextMuted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var controlsHeaderView: some View {
        VStack(spacing: 12) {
            // Champ de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appTextMuted)
                TextField("Rechercher par titre ou auteur...", text: $searchText)
                    .foregroundColor(.appTextPrimary)
                    .font(.system(size: 15))
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextMuted)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.appCard)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appCardBorder, lineWidth: 1))
            
            // Actions de sélection rapide
            HStack {
                Text("\(selectedCount) / \(items.count) sélectionnés")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                
                Spacer()
                
                Button("Tout sélectionner") {
                    selectAll(true)
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.tiktokRed)
                
                Text("•")
                    .foregroundColor(.appTextMuted)
                
                Button("Tout désélectionner") {
                    selectAll(false)
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredItems) { item in
                    CleanableItemRow(item: item) {
                        toggleItemSelection(id: item.id)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundColor(.appTextMuted)
            Text("Aucun élément trouvé")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            Text("Essayez de modifier votre recherche ou vos filtres.")
                .font(.system(size: 14))
                .foregroundColor(.appTextMuted)
            Spacer()
        }
        .padding()
    }
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.appCardBorder)
            
            TikTokButton(
                title: "Supprimer la sélection (\(selectedCount))",
                icon: "trash.fill",
                style: selectedCount > 0 ? .primary : .secondary
            ) {
                guard selectedCount > 0 else { return }
                startCleanupOfSelected()
            }
            .disabled(selectedCount == 0)
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Logique
    
    private func loadItems() {
        switch category {
        case .likes:
            self.items = LikeManager.shared.items
        case .posts:
            self.items = PostManager.shared.items
        case .reposts:
            self.items = RepostManager.shared.items
        case .favorites:
            self.items = FavoritesManager.shared.items
        }
    }
    
    private var filteredItems: [CleanableItem] {
        var result = items
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.authorUsername?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if filterOnlySelected {
            result = result.filter { $0.isSelected }
        }
        
        switch sortOrder {
        case .newestFirst:
            result.sort { $0.timestamp > $1.timestamp }
        case .oldestFirst:
            result.sort { $0.timestamp < $1.timestamp }
        case .mostLiked:
            result.sort { ($0.likeCount ?? 0) > ($1.likeCount ?? 0) }
        }
        
        return result
    }
    
    private var selectedCount: Int {
        items.filter { $0.isSelected }.count
    }
    
    private func selectAll(_ select: Bool) {
        for i in items.indices {
            items[i].isSelected = select
        }
        syncToManager()
    }
    
    private func toggleItemSelection(id: String) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items[idx].isSelected.toggle()
            syncToManager()
        }
    }
    
    private func syncToManager() {
        switch category {
        case .likes:
            LikeManager.shared.setItems(items)
        case .posts:
            PostManager.shared.setItems(items)
        case .reposts:
            RepostManager.shared.setItems(items)
        case .favorites:
            FavoritesManager.shared.setItems(items)
        }
    }
    
    private func startCleanupOfSelected() {
        let selectedOnly = items.filter { $0.isSelected }
        let config = CleanupConfiguration(
            selectedCategories: [category],
            selectionMode: .manualSelection,
            customSelectedItems: selectedOnly
        )
        CleanupEngine.shared.startCleanup(configuration: config)
        showExecutionView = true
    }
}
