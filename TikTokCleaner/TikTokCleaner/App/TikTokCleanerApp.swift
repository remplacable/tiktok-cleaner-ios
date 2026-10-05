import SwiftUI

@main
struct TikTokCleanerApp: App {
    @StateObject private var environment = AppEnvironment.shared
    
    init() {
        configureGlobalAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(environment)
                .preferredColorScheme(.dark)
        }
    }
    
    private func configureGlobalAppearance() {
        // Apparence sombre pour UINavigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 12/255, green: 12/255, blue: 15/255, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
    }
}
