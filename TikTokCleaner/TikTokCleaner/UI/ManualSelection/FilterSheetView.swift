import SwiftUI

public enum SortOrder: String, CaseIterable {
    case newestFirst = "Plus récents d'abord"
    case oldestFirst = "Plus anciens d'abord"
    case mostLiked = "Plus de likes"
}

/// Feuille de réglage des filtres et du tri.
public struct FilterSheetView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding public var currentSortOrder: SortOrder
    @Binding public var filterOnlySelected: Bool
    
    public init(currentSortOrder: Binding<SortOrder>, filterOnlySelected: Binding<Bool>) {
        self._currentSortOrder = currentSortOrder
        self._filterOnlySelected = filterOnlySelected
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("FILTRES & TRI")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.appTextMuted)
                    }
                }
                .padding(.top, 16)
                
                // Tri par date
                VStack(alignment: .leading, spacing: 12) {
                    Text("ORDRE D'AFFICHAGE")
                        .sectionHeaderStyle()
                    
                    GlassCard(padding: 6) {
                        VStack(spacing: 2) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Button(action: { currentSortOrder = order }) {
                                    HStack {
                                        Text(order.rawValue)
                                            .foregroundColor(.appTextPrimary)
                                            .font(.system(size: 15))
                                        Spacer()
                                        if currentSortOrder == order {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.tiktokRed)
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                    }
                                    .padding(14)
                                }
                                if order != SortOrder.allCases.last {
                                    Divider().background(Color.appCardBorder.opacity(0.5))
                                }
                            }
                        }
                    }
                }
                
                // Filtre éléments cochés
                VStack(alignment: .leading, spacing: 12) {
                    Text("FILTRE DE SÉLECTION")
                        .sectionHeaderStyle()
                    
                    GlassCard(padding: 14) {
                        Toggle("Afficher uniquement les éléments cochés", isOn: $filterOnlySelected)
                            .toggleStyle(SwitchToggleStyle(tint: .tiktokRed))
                            .foregroundColor(.appTextPrimary)
                    }
                }
                
                Spacer()
                
                TikTokButton(title: "Appliquer les filtres", style: .primary) {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
    }
}
