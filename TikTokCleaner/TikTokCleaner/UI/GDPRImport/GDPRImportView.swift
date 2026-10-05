import SwiftUI
import UniformTypeIdentifiers

/// Vue d'importation de l'archive officielle de données TikTok (format JSON GDPR).
public struct GDPRImportView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var showDocumentPicker = false
    @State private var importStatus: String? = nil
    @State private var isProcessing = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre supérieure
                HStack {
                    Text("IMPORT EXPORT DONNÉES")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.appTextMuted)
                    }
                }
                .padding(20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Explications pas à pas
                        instructionsCard
                        
                        // Boutons d'importation
                        VStack(spacing: 12) {
                            TikTokButton(
                                title: "Sélectionner un fichier JSON",
                                icon: "folder.badge.plus",
                                style: .primary
                            ) {
                                showDocumentPicker = true
                            }
                            
                            TikTokButton(
                                title: "Charger un exemple d'archive",
                                icon: "doc.text.fill",
                                style: .secondary
                            ) {
                                loadSampleArchive()
                            }
                        }
                        
                        if let status = importStatus {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.appSuccess)
                                Text(status)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextPrimary)
                            }
                            .padding()
                            .background(Color.appSuccess.opacity(0.12))
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                processSelectedFile(url: url)
            }
        }
    }
    
    private var instructionsCard: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.tiktokCyan)
                    Text("Comment obtenir votre archive TikTok ?")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    stepRow(num: "1", text: "Ouvrez l'application TikTok")
                    stepRow(num: "2", text: "Allez dans Profil > Paramètres et confidentialité")
                    stepRow(num: "3", text: "Touchez Compte > Télécharger vos données")
                    stepRow(num: "4", text: "Sélectionnez le format JSON et validez")
                    stepRow(num: "5", text: "Importez le fichier reçu ici-même")
                }
            }
        }
    }
    
    private func stepRow(num: String, text: String) -> some View {
        HStack(spacing: 10) {
            Text(num)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.tiktokRed)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private func processSelectedFile(url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            let items = try GDPRArchiveScanner.shared.parseArchive(jsonData: data)
            LikeManager.shared.setItems(items)
            PostManager.shared.setItems(items)
            RepostManager.shared.setItems(items)
            FavoritesManager.shared.setItems(items)
            
            importStatus = "\(items.count) éléments importés avec succès !"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            importStatus = "Format JSON non reconnu."
        }
    }
    
    private func loadSampleArchive() {
        let sampleJson = """
        {
          "Activity": {
            "Like List": {
              "ItemFavoriteList": [
                {"date": "2026-08-12 14:22:10", "link": "https://www.tiktok.com/@creator/video/7234567890123456789"},
                {"date": "2026-08-11 11:10:00", "link": "https://www.tiktok.com/@creator2/video/7234567890123456790"}
              ]
            },
            "Favorite Videos": {
              "FavoriteVideoList": [
                {"date": "2026-07-04 10:15:00", "link": "https://www.tiktok.com/@creator3/video/7234567890123456791"}
              ]
            },
            "Share History": {
              "ShareHistoryList": [
                {"date": "2026-06-20 18:30:00", "link": "https://www.tiktok.com/@creator4/video/7234567890123456792"}
              ]
            }
          },
          "Video": {
            "Videos": {
              "VideoList": [
                {"date": "2026-05-10 20:00:00", "video_link": "https://www.tiktok.com/@me/video/7234567890123456793", "likes": "24"}
              ]
            }
          }
        }
        """
        guard let data = sampleJson.data(using: .utf8) else { return }
        processSelectedFileContent(data: data)
    }
    
    private func processSelectedFileContent(data: Data) {
        if let items = try? GDPRArchiveScanner.shared.parseArchive(jsonData: data) {
            LikeManager.shared.setItems(items)
            PostManager.shared.setItems(items)
            RepostManager.shared.setItems(items)
            FavoritesManager.shared.setItems(items)
            importStatus = "\(items.count) éléments importés !"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

public struct DocumentPicker: UIViewControllerRepresentable {
    public let onPick: (URL) -> Void
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json, .data], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public final class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let first = urls.first { parent.onPick(first) }
        }
    }
}
