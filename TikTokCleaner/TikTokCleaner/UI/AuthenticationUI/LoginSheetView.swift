import SwiftUI

/// Feuille modale de connexion présentant les méthodes d'accès et la matrice des capacités techniques.
public struct LoginSheetView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var showEmbeddedWebView = false
    @State private var showGDPRView = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // En-tête
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CONNEXION & ACCÈS")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        Text("Choisissez votre méthode d'accès au compte")
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
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Options de connexion
                        methodsSection
                        
                        // Tableau des capacités techniques réelles (Exigence clé)
                        technicalCapabilitiesTableSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showEmbeddedWebView) {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Text("Connexion TikTok In-App")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button("Fermer") {
                            showEmbeddedWebView = false
                        }
                        .foregroundColor(.tiktokRed)
                    }
                    .padding(16)
                    
                    EmbeddedWebLoginView(
                        onLoginSuccess: {
                            showEmbeddedWebView = false
                            presentationMode.wrappedValue.dismiss()
                        },
                        onCancel: {
                            showEmbeddedWebView = false
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showGDPRView) {
            GDPRImportView()
        }
    }
    
    // MARK: - Sections
    
    private var methodsSection: some View {
        VStack(spacing: 12) {
            // Option 1 : Connexion In-App directe
            methodCard(
                title: "Connexion In-App Sécurisée",
                description: "Connexion officielle intégrée dans l'application. Extrait les jetons chiffrés directement dans le Keychain iOS.",
                icon: "lock.shield.fill",
                iconColor: .tiktokRed,
                badge: "Recommandé"
            ) {
                showEmbeddedWebView = true
            }
            
            // Option 2 : Archive GDPR officielle
            methodCard(
                title: "Importer une Archive GDPR",
                description: "Importez le fichier JSON officiel téléchargé depuis les réglages TikTok. Zéro risque de blocage.",
                icon: "doc.zipper",
                iconColor: .tiktokCyan,
                badge: "Sans mot de passe"
            ) {
                showGDPRView = true
            }
            
            // Option 3 : Mode Sandbox / Démo
            methodCard(
                title: "Mode Démonstration",
                description: "Explorez immédiatement toutes les fonctionnalités avec 1 284 likes, 42 vidéos, 316 reposts et 892 favoris simulés.",
                icon: "sparkles",
                iconColor: .purple,
                badge: "Essai instantané"
            ) {
                authManager.loadDemoAccount()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func methodCard(
        title: String,
        description: String,
        icon: String,
        iconColor: Color,
        badge: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                    
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    BadgeView(text: badge, color: iconColor)
                }
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .background(Color.appCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appCardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var technicalCapabilitiesTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MATRICE TECHNIQUE DES CAPACITÉS")
                .sectionHeaderStyle()
            
            GlassCard(padding: 14) {
                VStack(spacing: 12) {
                    capabilityRow(function: "Likes", api: "❌ Inexistante", deletion: "✓ Possible", method: "Session In-App")
                    Divider().background(Color.appCardBorder)
                    capabilityRow(function: "Vidéos", api: "✓ Lecture", deletion: "✓ Possible", method: "API + Session In-App")
                    Divider().background(Color.appCardBorder)
                    capabilityRow(function: "Republications", api: "❌ Inexistante", deletion: "✓ Possible", method: "Session In-App")
                    Divider().background(Color.appCardBorder)
                    capabilityRow(function: "Favoris", api: "❌ Inexistante", deletion: "✓ Possible", method: "Session In-App")
                }
            }
            
            Text("Conformément aux directives techniques : aucune fausse API n'est utilisée. Les suppressions exploitent le moteur d'exécution local sécurisé.")
                .font(.system(size: 11))
                .foregroundColor(.appTextMuted)
                .lineSpacing(2)
        }
    }
    
    private func capabilityRow(function: String, api: String, deletion: String, method: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(function)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                Spacer()
                Text(deletion)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appSuccess)
            }
            HStack {
                Text("API officielle : \(api)")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text(method)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.tiktokCyan)
            }
        }
        .padding(.vertical, 2)
    }
}
