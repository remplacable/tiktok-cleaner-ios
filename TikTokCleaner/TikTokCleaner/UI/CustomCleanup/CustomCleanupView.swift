import SwiftUI

/// Vue de configuration du nettoyage personnalisé.
public struct CustomCleanupView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = CustomCleanupViewModel()
    
    public let onStartCleanup: (CleanupConfiguration) -> Void
    
    public init(onStartCleanup: @escaping (CleanupConfiguration) -> Void) {
        self.onStartCleanup = onStartCleanup
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre de navigation supérieure
                HStack {
                    Text("NETTOYAGE")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.appTextMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Section 1 : Catégories à nettoyer
                        categorySelectionSection
                        
                        Divider()
                            .background(Color.appCardBorder)
                        
                        // Section 2 : Mode de sélection
                        selectionModeSection
                        
                        // Sélecteurs contextuels si par date ou période
                        contextualDatePickers
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                
                // Barre inférieure d'action
                bottomActionBar
            }
        }
        .sheet(item: $viewModel.selectedCategoryForManualReview) { cat in
            ManualSelectionView(category: cat)
        }
    }
    
    // MARK: - Sections
    
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CATÉGORIES CIBLÉES")
                .sectionHeaderStyle()
            
            GlassCard(padding: 6) {
                VStack(spacing: 2) {
                    ForEach(CleanupCategory.allCases) { category in
                        categoryCheckboxRow(for: category)
                        if category != CleanupCategory.allCases.last {
                            Divider().background(Color.appCardBorder.opacity(0.5))
                        }
                    }
                }
            }
        }
    }
    
    private func categoryCheckboxRow(for category: CleanupCategory) -> some View {
        let isSelected = viewModel.isCategorySelected(category)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.toggleCategory(category)
            }
        }) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .tiktokRed : .appTextMuted)
                
                Image(systemName: category.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(category.symbolColor)
                    .frame(width: 24)
                
                Text(category.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                if viewModel.selectionMode == .manualSelection && isSelected {
                    Button(action: { viewModel.selectedCategoryForManualReview = category }) {
                        Text("Choisir")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.tiktokCyan)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.tiktokCyan.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var selectionModeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SÉLECTION")
                .sectionHeaderStyle()
            
            GlassCard(padding: 6) {
                VStack(spacing: 2) {
                    radioOptionRow(title: "Tout", mode: .all)
                    Divider().background(Color.appCardBorder.opacity(0.5))
                    radioOptionRow(title: "Sélection manuelle", mode: .manualSelection)
                    Divider().background(Color.appCardBorder.opacity(0.5))
                    radioOptionRow(title: "Par date", mode: .byDate(targetDate: viewModel.targetDate))
                    Divider().background(Color.appCardBorder.opacity(0.5))
                    radioOptionRow(title: "Par période", mode: .byPeriod(startDate: viewModel.startDate, endDate: viewModel.endDate))
                }
            }
        }
    }
    
    private func radioOptionRow(title: String, mode: SelectionMode) -> some View {
        let isChosen: Bool
        switch (viewModel.selectionMode, mode) {
        case (.all, .all), (.manualSelection, .manualSelection):
            isChosen = true
        case (.byDate, .byDate):
            isChosen = true
        case (.byPeriod, .byPeriod):
            isChosen = true
        default:
            isChosen = false
        }
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectionMode = mode
            }
        }) {
            HStack(spacing: 14) {
                Image(systemName: isChosen ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isChosen ? .tiktokRed : .appTextMuted)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var contextualDatePickers: some View {
        switch viewModel.selectionMode {
        case .byDate:
            GlassCard(padding: 16) {
                DatePicker("Date cible", selection: $viewModel.targetDate, displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                    .colorScheme(.dark)
            }
            .transition(.opacity)
            
        case .byPeriod:
            GlassCard(padding: 16) {
                VStack(spacing: 14) {
                    DatePicker("Date de début", selection: $viewModel.startDate, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                    DatePicker("Date de fin", selection: $viewModel.endDate, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                }
                .colorScheme(.dark)
            }
            .transition(.opacity)
            
        default:
            EmptyView()
        }
    }
    
    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            Divider().background(Color.appCardBorder)
            
            HStack {
                Text("Éléments estimés :")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text("~\(viewModel.estimatedCount)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
            }
            .padding(.horizontal, 24)
            
            TikTokButton(
                title: "COMMENCER LE NETTOYAGE",
                icon: "trash.fill",
                style: .primary
            ) {
                let config = viewModel.buildConfiguration()
                presentationMode.wrappedValue.dismiss()
                onStartCleanup(config)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.appBackground)
    }
}
