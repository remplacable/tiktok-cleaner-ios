import Foundation
import WebKit

/// Exécuteur WebKit natif encapsulé en mémoire.
/// Exécute les requêtes de suppression et vérification directement au sein
/// du runtime officiel de TikTok pour garantir l'application des signatures
/// de sécurité obligatoires (X-Bogus, msToken, tt_csrf_token).
public final class WebKitSessionExecutor: NSObject {
    public static let shared = WebKitSessionExecutor()
    
    private var webView: WKWebView?
    private var isEnvironmentReady = false
    private var setupContinuation: CheckedContinuation<Bool, Never>?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Initialisation de l'environnement WebKit en RAM
    
    @MainActor
    public func prepareEngine(for awemeId: String? = nil) async -> Bool {
        if let wv = webView, isEnvironmentReady {
            if let awemeId = awemeId {
                return await loadVideoContext(wv: wv, awemeId: awemeId)
            }
            return true
        }
        
        return await withCheckedContinuation { continuation in
            self.setupContinuation = continuation
            
            let config = WKWebViewConfiguration()
            config.websiteDataStore = WKWebsiteDataStore.default() // Partage des cookies de la session connectée
            config.mediaTypesRequiringUserActionForPlayback = .all
            config.suppressesIncrementalRendering = true
            
            let wv = WKWebView(frame: .zero, configuration: config)
            wv.navigationDelegate = self
            wv.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
            
            self.webView = wv
            
            let targetUrlString = awemeId != nil ? "https://www.tiktok.com/@/video/\(awemeId!)" : "https://www.tiktok.com/"
            guard let url = URL(string: targetUrlString) else {
                continuation.resume(returning: false)
                return
            }
            
            AppLogger.shared.info(category: "WEBKIT_RUNNER", message: "Chargement du contexte TikTok : \(targetUrlString)")
            wv.load(URLRequest(url: url))
        }
    }
    
    @MainActor
    private func loadVideoContext(wv: WKWebView, awemeId: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            self.setupContinuation = continuation
            guard let url = URL(string: "https://www.tiktok.com/@/video/\(awemeId)") else {
                continuation.resume(returning: false)
                return
            }
            wv.load(URLRequest(url: url))
        }
    }
    
    // MARK: - Vérification de l'état `userDigged` (0 ou 1)
    
    /// Inspecte l'état réel côté TikTok pour savoir si la vidéo est likée (1) ou non (0)
    @MainActor
    public func inspectUserDigged(awemeId: String) async throws -> Int {
        guard let wv = webView else {
            throw CleanupError.unknown(message: "Moteur WebKit non initialisé")
        }
        
        // Ce script interroge successivement :
        // 1) L'état hydraté universel dans le DOM (__UNIVERSAL_DATA_FOR_REHYDRATION__ ou SIGI_STATE)
        // 2) L'état du bouton cœur dans le DOM ([data-e2e="like-icon"], aria-pressed)
        // 3) L'API interne /api/item/detail/ via fetch signé
        let script = """
        (async function() {
            try {
                const awemeId = "\(awemeId)";
                
                // Méthode 1 : Vérification dans le state hydraté TikTok
                let diggedFromState = null;
                try {
                    const uniData = document.getElementById('__UNIVERSAL_DATA_FOR_REHYDRATION__');
                    if (uniData) {
                        const parsed = JSON.parse(uniData.textContent || '{}');
                        const defaultScope = parsed['__DEFAULT_SCOPE__'] || {};
                        const itemDetail = defaultScope['webapp.video-detail']?.itemInfo?.itemStruct;
                        if (itemDetail && itemDetail.id === awemeId) {
                            diggedFromState = itemDetail.userDigged ? 1 : 0;
                        }
                    }
                } catch(e) {}
                
                if (diggedFromState !== null) {
                    return JSON.stringify({ "userDigged": diggedFromState, "source": "universal_state" });
                }
                
                // Méthode 2 : Vérification du bouton coeur dans le DOM
                try {
                    const likeButton = document.querySelector('[data-e2e="like-icon"], [data-e2e="browse-like-icon"], button[aria-label*="like" i]');
                    if (likeButton) {
                        const isPressed = likeButton.getAttribute('aria-pressed') === 'true' || 
                                          likeButton.classList.contains('active') ||
                                          likeButton.innerHTML.includes('fill="#FE2C55"') ||
                                          likeButton.innerHTML.includes('fill="rgb(254, 44, 85)"');
                        return JSON.stringify({ "userDigged": isPressed ? 1 : 0, "source": "dom_icon" });
                    }
                } catch(e) {}
                
                // Méthode 3 : Appel API direct signé
                const res = await window.fetch('/api/item/detail/?itemId=' + awemeId, {
                    method: 'GET',
                    headers: { 'accept': 'application/json' }
                });
                const data = await res.json();
                const userDigged = (data?.itemInfo?.itemStruct?.userDigged) ? 1 : 0;
                return JSON.stringify({ "userDigged": userDigged, "source": "api_detail" });
                
            } catch (err) {
                return JSON.stringify({ "userDigged": -1, "error": err.toString() });
            }
        })();
        """
        
        let result = try await wv.evaluateJavaScript(script)
        guard let jsonStr = result as? String,
              let data = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let userDigged = json["userDigged"] as? Int else {
            return 0
        }
        
        AppLogger.shared.info(category: "WEBKIT_RUNNER", message: "Statut userDigged pour \(awemeId) : \(userDigged) (Source: \(json["source"] ?? "unknown"))")
        return userDigged
    }
    
    // MARK: - Test de bout en bout complet sur UN SEUL like
    
    /// Exécute le test strict de bout en bout demandé :
    /// userDigged AVANT (doit être 1) → Suppression → Réponse réelle → userDigged APRÈS (doit être 0)
    @MainActor
    public func executeSingleLikeEndToEndTest(awemeId: String) async throws -> SingleLikeTestReport {
        let startTime = Date()
        let endpoint = "/api/commit/item/digg/?aweme_id=\(awemeId)&type=0"
        
        // Étape 1 : Préparation du contexte WebKit sur la vidéo
        let ready = await prepareEngine(for: awemeId)
        guard ready, let wv = webView else {
            throw CleanupError.unknown(message: "Impossible d'initialiser le moteur WebKit")
        }
        
        // Laisser 1.5s pour l'hydratation des scripts TikTok
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Étape 2 : Vérification userDigged AVANT
        let userDiggedBefore = try await inspectUserDigged(awemeId: awemeId)
        
        if userDiggedBefore != 1 {
            // Le critère absolu exige que la vidéo soit likée au départ
            let elapsed = Date().timeIntervalSince(startTime)
            return SingleLikeTestReport(
                videoUrl: "https://www.tiktok.com/@/video/\(awemeId)",
                awemeId: awemeId,
                endpointUsed: endpoint,
                httpStatusCode: 200,
                tiktokStatusCode: -1,
                tiktokStatusMsg: "Vidéo non likée au départ (userDigged = \(userDiggedBefore))",
                userDiggedBefore: userDiggedBefore,
                userDiggedAfter: userDiggedBefore,
                durationSeconds: elapsed,
                isSuccess: false,
                errorMessage: "Cette vidéo n'est pas marquée comme likée par votre compte actuellement. Veuillez sélectionner une vidéo que vous avez réellement likée."
            )
        }
        
        // Étape 3 : Exécution de la suppression dans le runtime officiel
        let requestScript = """
        (async function() {
            try {
                const awemeId = "\(awemeId)";
                const endpoint = '/api/commit/item/digg/?aweme_id=' + awemeId + '&type=0';
                
                // Récupération du jeton CSRF présent dans les cookies de la page
                function getCookie(name) {
                    const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
                    return match ? match[2] : '';
                }
                const csrf = getCookie('tt_csrf_token') || getCookie('csrf_session_id');
                
                const headers = {
                    'accept': 'application/json, text/plain, */*',
                    'content-type': 'application/x-www-form-urlencoded'
                };
                if (csrf) {
                    headers['x-secsdk-csrf-token'] = csrf;
                }
                
                const response = await window.fetch(endpoint, {
                    method: 'POST',
                    headers: headers
                });
                
                const status = response.status;
                const json = await response.json();
                
                return JSON.stringify({
                    "httpStatus": status,
                    "tiktokStatus": json.status_code !== undefined ? json.status_code : -1,
                    "statusMsg": json.status_msg || "",
                    "raw": json
                });
            } catch (err) {
                return JSON.stringify({
                    "httpStatus": 0,
                    "tiktokStatus": -1,
                    "statusMsg": err.toString(),
                    "raw": {}
                });
            }
        })();
        """
        
        let evalResult = try await wv.evaluateJavaScript(requestScript)
        guard let resStr = evalResult as? String,
              let resData = resStr.data(using: .utf8),
              let resJson = try? JSONSerialization.jsonObject(with: resData) as? [String: Any] else {
            throw CleanupError.invalidResponse
        }
        
        let httpStatus = resJson["httpStatus"] as? Int ?? 0
        let tiktokStatus = resJson["tiktokStatus"] as? Int ?? -1
        let statusMsg = resJson["statusMsg"] as? String ?? ""
        
        // Étape 4 : Attendre 1 seconde la propagation
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Étape 5 : Vérification immédiate de l'état APRÈS (doit valoir 0)
        let userDiggedAfter = try await inspectUserDigged(awemeId: awemeId)
        let elapsed = Date().timeIntervalSince(startTime)
        
        // CRITÈRE DE RÉUSSITE ABSOLU :
        // userDigged AVANT = 1 ET suppression = succès (tiktokStatus == 0) ET userDigged APRÈS = 0
        let isSuccess = (userDiggedBefore == 1) && (tiktokStatus == 0) && (userDiggedAfter == 0)
        let isSecurityChallenge = (tiktokStatus == 10101) || (statusMsg.lowercased().contains("verify"))
        
        let report = SingleLikeTestReport(
            videoUrl: "https://www.tiktok.com/@/video/\(awemeId)",
            awemeId: awemeId,
            endpointUsed: endpoint,
            httpStatusCode: httpStatus,
            tiktokStatusCode: tiktokStatus,
            tiktokStatusMsg: statusMsg.isEmpty ? (isSuccess ? "ok" : "Erreur de validation") : statusMsg,
            userDiggedBefore: userDiggedBefore,
            userDiggedAfter: userDiggedAfter,
            durationSeconds: elapsed,
            isSuccess: isSuccess,
            securityChallengeEncountered: isSecurityChallenge,
            errorMessage: isSuccess ? nil : (isSecurityChallenge ? "Captcha / Défi de sécurité TikTok déclenché" : "Le like n'a pas été validé comme retiré par TikTok (Code: \(tiktokStatus)).")
        )
        
        AppLogger.shared.info(
            category: "E2E_TEST",
            message: "Résultat test : Succès = \(isSuccess), userDigged: \(userDiggedBefore) -> \(userDiggedAfter), code: \(tiktokStatus)"
        )
        
        return report
    }
    
    // MARK: - Actions de masse
    
    @MainActor
    public func verifyVideoLikeStatus(awemeId: String) async throws -> Bool {
        let digged = try await inspectUserDigged(awemeId: awemeId)
        return digged == 1
    }
    
    @MainActor
    public func unlikeVideo(awemeId: String) async throws -> (success: Bool, rawResponse: [String: Any]) {
        let report = try await executeSingleLikeEndToEndTest(awemeId: awemeId)
        return (report.isSuccess, ["status_code": report.tiktokStatusCode, "status_msg": report.tiktokStatusMsg])
    }
    
    @MainActor
    public func unfavoriteVideo(awemeId: String) async throws -> Bool {
        _ = await prepareEngine()
        guard let wv = webView else { throw CleanupError.unknown(message: "Moteur indisponible") }
        let script = "window.fetch('/api/item/collect/?aweme_id=\(awemeId)&action=0', { method: 'POST' }).then(r => r.json());"
        let res = try await wv.evaluateJavaScript(script)
        let dict = res as? [String: Any]
        return (dict?["status_code"] as? Int ?? -1) == 0
    }
    
    @MainActor
    public func deleteVideo(awemeId: String) async throws -> Bool {
        _ = await prepareEngine()
        guard let wv = webView else { throw CleanupError.unknown(message: "Moteur indisponible") }
        let script = "window.fetch('/api/item/delete/?aweme_id=\(awemeId)', { method: 'POST' }).then(r => r.json());"
        let res = try await wv.evaluateJavaScript(script)
        let dict = res as? [String: Any]
        return (dict?["status_code"] as? Int ?? -1) == 0
    }
}

// MARK: - WKNavigationDelegate

extension WebKitSessionExecutor: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        AppLogger.shared.info(category: "WEBKIT_RUNNER", message: "Contexte WebKit TikTok synchronisé.")
        self.isEnvironmentReady = true
        self.setupContinuation?.resume(returning: true)
        self.setupContinuation = nil
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        AppLogger.shared.error(category: "WEBKIT_RUNNER", message: "Échec chargement WebKit : \(error.localizedDescription)")
        self.isEnvironmentReady = false
        self.setupContinuation?.resume(returning: false)
        self.setupContinuation = nil
    }
}
