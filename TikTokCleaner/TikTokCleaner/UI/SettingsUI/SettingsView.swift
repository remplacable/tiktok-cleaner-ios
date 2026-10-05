import SwiftUI

/// Vue des réglages de l'application, paramètres de sécurité et console de diagnostic.
public struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var settings = AppSettings.shared
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var showLogsView = false
    @State private var showResetAlert = false
    @State private var showSingleLikeTestView = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Section Compte
                        accountSection
                        
                        // Section Mode Sécurisé / Simulation
                        safetySection
                        
                        // Section Régulation de Débit (Anti-Bot)
                        rateLimiterSection
                        
                        // Section Outils Développeur & Diagnostics
                        developerSection
                        
                        // Informations et Mentions
                        footerInfoSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.tiktokRed)
                }
            }
            .sheet(isPresented: $showLogsView) {
                NavigationView {
                    DeveloperLogsView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Fermer") { showLogsView = false }
                                    .foregroundColor(.tiktokRed)
                            }
                        }
                }
            }
            .sheet(isPresented: $showSingleLikeTestView) {
                SingleLikeTestView()
            }
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("Déconnexion & Réinitialisation"),
                    message: Text("Voulez-vous purger les tokens du Keychain et réinitialiser les caches locaux ?"),
                    primaryButton: .destructive(Text("Réinitialiser")) {
                        authManager.logout()
                        settings.resetToDefaults()
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("Annuler"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Sections
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COMPTE CONNECTÉ")
                .sectionHeaderStyle()
            
            GlassCard(padding: 16) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.currentAccount?.displayName ?? "Non connecté")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                            Text("@\(authManager.currentAccount?.username ?? "--")")
                                .font(.system(size: 13))
                                .foregroundColor(.appTextSecondary)
                        }
                        Spacer()
                        BadgeView(
                            text: authManager.currentAccount?.connectionMethod.rawValue ?? "Déconnecté",
                            color: .tiktokCyan
                        )
                    }
                    
                    Divider().background(Color.appCardBorder)
                    
                    Button(action: { showResetAlert = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Déconnecter et effacer les clés Keychain")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appError)
                    }
                }
            }
        }
    }
    
    private var safetySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PROTECTION DU COMPTE")
                .sectionHeaderStyle()
            
            GlassCard(padding: 16) {
                VStack(spacing: 16) {
                    Toggle(isOn: $settings.isDryRunEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mode Simulation (Dry-Run)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            Text("Simule le nettoyage sans modifier le compte réel.")
                                .font(.system(size: 12))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .tiktokRed))
                    
                    Divider().background(Color.appCardBorder)
                    
                    Toggle(isOn: $settings.autoPauseOnRateLimit) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pause automatique anti-spam")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            Text("Interrompt le traitement si TikTok signale une fréquence excessive.")
                                .font(.system(size: 12))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .tiktokRed))
                }
            }
        }
    }
    
    private var rateLimiterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CADENCE DES REQUÊTES (LIMITEUR)")
                .sectionHeaderStyle()
            
            GlassCard(padding: 16) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Intervalle moyen")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appTextPrimary)
                            Text("Délai de sécurité entre 2 actions")
                                .font(.system(size: 12))
                                .foregroundColor(.appTextMuted)
                        }
                        Spacer()
                        Text(String(format: "%.1f s", settings.rateLimitSettings.requestIntervalSeconds))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.tiktokCyan)
                    }
                    
                    Slider(
                        value: $settings.rateLimitSettings.requestIntervalSeconds,
                        in: 1.5...6.0,
                        step: 0.5
                    )
                    .accentColor(.tiktokCyan)
                    
                    Divider().background(Color.appCardBorder)
                    
                    HStack {
                        Text("Pause de repos après salves")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appTextPrimary)
                        Spacer()
                        Text("\(settings.rateLimitSettings.burstSizeBeforeRest) actions")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
    }
    
    private var developerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OUTILS & LOGS")
                .sectionHeaderStyle()
            
            GlassCard(padding: 14) {
                VStack(spacing: 12) {
                    Button(action: { showSingleLikeTestView = true }) {
                        HStack {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(.tiktokRed)
                            Text("Banc d'essai E2E (Test réel 1 Like)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.appTextMuted)
                                .font(.system(size: 13))
                        }
                    }
                    
                    Divider().background(Color.appCardBorder)
                    
                    Button(action: { showLogsView = true }) {
                        HStack {
                            Image(systemName: "terminal.fill")
                                .foregroundColor(.tiktokCyan)
                            Text("Ouvrir la console de logs développeur")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.appTextMuted)
                                .font(.system(size: 13))
                        }
                    }
                }
            }
        }
    }
    
    private var footerInfoSection: some View {
        VStack(spacing: 6) {
            Text("TikTok Cleaner iOS • Version 1.0.0")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appTextMuted)
            Text("Conçu pour le respect de la vie privée. Aucun serveur tiers intermédiaire.")
                .font(.system(size: 11))
                .foregroundColor(.appTextMuted.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
    }
}
