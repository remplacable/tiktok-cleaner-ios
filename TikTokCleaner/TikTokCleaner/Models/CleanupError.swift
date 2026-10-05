import Foundation

/// Erreurs de nettoyage structurées avec causes précises et actions recommandées.
public enum CleanupError: LocalizedError, Codable, Hashable {
    case rateLimited(retryAfterSeconds: Int)
    case sessionExpired
    case itemNotFoundOrAlreadyDeleted
    case networkUnavailable
    case captchaRequired
    case permissionDenied(reason: String)
    case serverError(statusCode: Int, message: String)
    case cancelled
    case invalidResponse
    case quotaExceeded
    case unknown(message: String)
    
    public var errorDescription: String? {
        title
    }
    
    public var title: String {
        switch self {
        case .rateLimited:
            return "Limite temporaire atteinte"
        case .sessionExpired:
            return "Session TikTok expirée"
        case .itemNotFoundOrAlreadyDeleted:
            return "Élément introuvable ou déjà supprimé"
        case .networkUnavailable:
            return "Connexion réseau indisponible"
        case .captchaRequired:
            return "Vérification de sécurité TikTok requise"
        case .permissionDenied:
            return "Action non autorisée par TikTok"
        case .serverError(let code, _):
            return "Erreur serveur TikTok (\(code))"
        case .cancelled:
            return "Opération annulée par l'utilisateur"
        case .invalidResponse:
            return "Réponse inattendue des serveurs TikTok"
        case .quotaExceeded:
            return "Quota journalier TikTok dépassé"
        case .unknown:
            return "Échec de l'opération"
        }
    }
    
    public var cause: String {
        switch self {
        case .rateLimited(let seconds):
            return "TikTok applique une protection anti-spam suite à un nombre trop élevé d'actions rapprochées. Délai recommandé : \(seconds)s."
        case .sessionExpired:
            return "Les jetons de session ou cookies d'authentification ont expiré ou ont été révoqués par TikTok."
        case .itemNotFoundOrAlreadyDeleted:
            return "Le contenu a déjà été retiré, masqué ou rendu privé par son auteur original."
        case .networkUnavailable:
            return "L'iPhone ne parvient pas à joindre les serveurs TikTok. Vérifiez votre connexion Wi-Fi ou 4G/5G."
        case .captchaRequired:
            return "L'algorithme de détection de trafic TikTok a déclenché un test de vérification pour s'assurer que vous êtes humain."
        case .permissionDenied(let reason):
            return "L'API ou le profil ne dispose pas des droits nécessaires pour supprimer cet élément. (\(reason))"
        case .serverError(let code, let msg):
            return "Les serveurs TikTok ont retourné le code HTTP \(code). Détail : \(msg)"
        case .cancelled:
            return "Le processus de nettoyage a été suspendu ou arrêté manuellement."
        case .invalidResponse:
            return "Les données retournées par l'infrastructure TikTok n'ont pas pu être validées."
        case .quotaExceeded:
            return "TikTok a temporairement bloqué les modifications pour ce compte pour les prochaines 24 heures."
        case .unknown(let msg):
            return "Une condition inattendue s'est produite : \(msg)"
        }
    }
    
    public var action: String {
        switch self {
        case .rateLimited(let seconds):
            return "L'application met automatiquement en pause la file d'attente pendant \(seconds) secondes puis reprendra le nettoyage."
        case .sessionExpired:
            return "Veuillez rafraîchir votre session en réouvrant la section de connexion dans l'application."
        case .itemNotFoundOrAlreadyDeleted:
            return "L'élément est automatiquement marqué comme traité et retiré de votre liste locale."
        case .networkUnavailable:
            return "Vérifiez vos réglages réseau et appuyez sur 'Réessayer'."
        case .captchaRequired:
            return "Résolvez le captcha directement depuis la vue sécurisée in-app pour débloquer les requêtes."
        case .permissionDenied:
            return "Vérifiez que votre compte est bien propriétaire de cette publication ou que le compte n'est pas restreint."
        case .serverError:
            return "L'élément sera réessayé avec un délai exponentiel (backoff)."
        case .cancelled:
            return "Vous pouvez reprendre le nettoyage à tout moment là où il s'est arrêté."
        case .invalidResponse:
            return "Une tentative de renvoi sera effectuée avec un nouvel identifiant de transaction."
        case .quotaExceeded:
            return "Il est recommandé de patienter quelques heures pour préserver la réputation de votre compte TikTok."
        case .unknown:
            return "Appuyez sur 'Réessayer' ou consultez les logs développeur pour plus de détails."
        }
    }
    
    public var isRetryable: Bool {
        switch self {
        case .rateLimited, .networkUnavailable, .serverError, .invalidResponse:
            return true
        case .sessionExpired, .captchaRequired, .permissionDenied, .itemNotFoundOrAlreadyDeleted, .cancelled, .quotaExceeded, .unknown:
            return false
        }
    }
}
