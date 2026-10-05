import SwiftUI

/// Palette de couleurs sobre, sombre et moderne inspirée de TikTok.
public extension Color {
    // Fond principal ultra sombre
    static let appBackground = Color(red: 12/255, green: 12/255, blue: 15/255) // #0C0C0F
    
    // Cartes et conteneurs
    static let appCard = Color(red: 22/255, green: 22/255, blue: 28/255) // #16161C
    static let appCardHover = Color(red: 28/255, green: 28/255, blue: 36/255) // #1C1C24
    static let appCardBorder = Color(red: 38/255, green: 38/255, blue: 48/255) // #262630
    
    // Accents TikTok
    static let tiktokRed = Color(red: 254/255, green: 44/255, blue: 85/255) // #FE2C55
    static let tiktokCyan = Color(red: 37/255, green: 244/255, blue: 238/255) // #25F4EE
    
    // Typographie
    static let appTextPrimary = Color.white
    static let appTextSecondary = Color(red: 161/255, green: 161/255, blue: 170/255) // Zinc 400
    static let appTextMuted = Color(red: 113/255, green: 113/255, blue: 122/255) // Zinc 500
    
    // États fonctionnels
    static let appSuccess = Color(red: 16/255, green: 185/255, blue: 129/255) // Emerald 500
    static let appWarning = Color(red: 245/255, green: 158/255, blue: 11/255) // Amber 500
    static let appError = Color(red: 239/255, green: 68/255, blue: 68/255) // Red 500
}
