import SwiftUI

/// Console de logs développeur in-app sécurisée (avec secrets masqués).
public struct DeveloperLogsView: View {
    @ObservedObject private var logger = AppLogger.shared
    @State private var selectedFilter: LogLevel? = nil
    @State private var showShareSheet = false
    @State private var logExportContent = ""
    
    public init() {}
    
    private var filteredLogs: [LogEntry] {
        if let filter = selectedFilter {
            return logger.logs.filter { $0.level == filter }
        }
        return logger.logs
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre d'outils
                filterBar
                
                // Console de logs
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(filteredLogs) { entry in
                                logRow(entry)
                                    .id(entry.id)
                            }
                        }
                        .padding(14)
                    }
                    .background(Color.black)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appCardBorder, lineWidth: 1))
                    .padding(14)
                }
                
                // Actions de purge et export
                HStack(spacing: 12) {
                    TikTokButton(title: "Purger", icon: "trash", style: .secondary) {
                        logger.clear()
                    }
                    
                    TikTokButton(title: "Exporter", icon: "square.and.arrow.up", style: .primary) {
                        logExportContent = logger.exportLogsAsPlainText()
                        showShareSheet = true
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("Logs Développeur")
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(activityItems: [logExportContent])
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "Tous", level: nil)
                ForEach(LogLevel.allCases, id: \.self) { lvl in
                    filterChip(title: lvl.rawValue, level: lvl)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }
    
    private func filterChip(title: String, level: LogLevel?) -> some View {
        let isSelected = selectedFilter == level
        return Button(action: { selectedFilter = level }) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : .appTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.tiktokRed : Color.appCard)
                .cornerRadius(16)
        }
    }
    
    private func logRow(_ entry: LogEntry) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(entry.formattedTime)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.appTextMuted)
            
            Text("[\(entry.level.rawValue)]")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(levelColor(entry.level))
            
            Text("[\(entry.category)]")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.tiktokCyan)
            
            Text(entry.message)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.vertical, 2)
    }
    
    private func levelColor(_ level: LogLevel) -> Color {
        switch level {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .security: return .green
        }
    }
}

public struct ActivityViewController: UIViewControllerRepresentable {
    public let activityItems: [Any]
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
