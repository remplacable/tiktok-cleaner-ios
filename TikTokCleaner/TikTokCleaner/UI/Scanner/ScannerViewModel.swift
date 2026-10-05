import Foundation
import Combine

/// Modèle de vue pilotant l'écran de scan du compte.
public final class ScannerViewModel: ObservableObject {
    public let scanner = ContentScanner.shared
    
    @Published public var hasStarted = false
    
    public init() {}
    
    public func startScanning() {
        hasStarted = true
        scanner.startScan()
    }
    
    public func cancel() {
        scanner.cancelScan()
    }
}
