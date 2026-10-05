import SwiftUI

/// Liste détaillée des éléments dont la suppression a échoué avec cause et remédiation.
public struct ErrorDetailSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    public let failedTasks: [CleanupTask]
    
    @State private var selectedTaskForInspection: CleanupTask? = nil
    
    public init(failedTasks: [CleanupTask]) {
        self.failedTasks = failedTasks
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre de titre
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DIAGNOSTIC DES ÉCHECS")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        Text("\(failedTasks.count) éléments nécessitent votre attention")
                            .font(.system(size: 13))
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.appTextMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Liste des erreurs
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(failedTasks) { task in
                            failedTaskRow(task)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(item: $selectedTaskForInspection) { task in
            ErrorAlertSheet(
                error: task.lastError ?? .unknown(message: "Erreur inattendue"),
                onRetry: {
                    // Relance de la tâche individuelle
                },
                onDismiss: {
                    selectedTaskForInspection = nil
                }
            )
        }
    }
    
    private func failedTaskRow(_ task: CleanupTask) -> some View {
        Button(action: { selectedTaskForInspection = task }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: task.item.category.iconName)
                        .foregroundColor(task.item.category.symbolColor)
                        .font(.system(size: 14))
                    
                    Text(task.item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    BadgeView(text: "Tentatives: \(task.attempts)", color: .appWarning)
                }
                
                if let err = task.lastError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.appError)
                        Text(err.title)
                            .font(.system(size: 13))
                            .foregroundColor(.appError)
                    }
                }
                
                HStack {
                    Text("Touchez pour voir la cause et la solution")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextMuted)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextMuted)
                }
            }
            .padding(14)
            .background(Color.appCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.appError.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
