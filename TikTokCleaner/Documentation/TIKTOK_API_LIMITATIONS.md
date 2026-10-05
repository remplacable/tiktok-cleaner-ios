# Analyse Technique Approfondie & Limitations de l'API TikTok

Ce document détaille les capacités réelles, les restrictions architecturales et la matrice de faisabilité pour une application tierce iOS interagissant avec TikTok.

---

## 1. Matrice des Capacités Techniques Réelles

Conformément à la directive stricte du projet (**ne jamais inventer d'API fictive**), voici l'état réel des capacités offertes par TikTok pour une application iOS native :

| Fonctionnalité | API Officielle TikTok (Login Kit / Display) | Suppression possible via API Officielle ? | Méthode Réelle & Viable Utilisée | Statut Technique |
|---|---|---|---|---|
| **❤️ Likes (Vidéos aimées)** | ❌ **Inexistante**. Aucun endpoint ni scope public (`user.likes` n'existe pas). | ❌ **Non**. | **1. Ingestion Archive GDPR** (liste exhaustive instantanée).<br>**2. Moteur de session In-App** (`POST /api/commit/item/digg/?type=0`). | Totalement fonctionnel via l'application. |
| **🎬 Vidéos publiées** | ✓ **Lecture**. Scope `video.list` (`/v2/video/list/`) pour métadonnées, vues, likes. | ❌ **Non**. L'API officielle de publication ne propose aucun endpoint `DELETE`. | **1. Scan API officielle** ou Archive GDPR.<br>**2. Moteur de session In-App** (`POST /api/item/delete/`). | Totalement fonctionnel via l'application. |
| **🔁 Republications (Reposts)** | ❌ **Inexistante**. Aucun scope officiel pour les republications. | ❌ **Non**. | **1. Ingestion Archive GDPR** (`Share History`).<br>**2. Moteur de session In-App** (`POST /node/share/item/repost/delete/`). | Totalement fonctionnel via l'application. |
| **⭐ Favoris (Enregistrements)** | ❌ **Inexistante**. Aucun scope officiel pour les collections/favoris. | ❌ **Non**. | **1. Ingestion Archive GDPR** (`Favorite Videos`).<br>**2. Moteur de session In-App** (`POST /api/item/collect/?action=0`). | Totalement fonctionnel via l'application. |

---

## 2. Analyse des Mécanismes de Protection TikTok

TikTok protège ses serveurs contre l'automatisation agressive via plusieurs technologies :

### A. Signatures Cryptographiques Web (`msToken`, `X-Bogus`, `_signature`)
- Les requêtes HTTP brutes envoyées sans environnement de navigateur authentique sont interceptées par le pare-feu ByteDance (WAF) et retournent `HTTP 403` ou `{ "status_code": 10101, "status_msg": "verify" }`.
- **Solution mise en place dans TikTok Cleaner** : L'authentification et l'exécution s'appuient sur un contexte web encapsulé (`WKWebView` natif sans quitter l'application). Les cookies et le jeton CSRF (`tt_csrf_token`) sont extraits directement dans le **Keychain iOS**, permettant des requêtes conformes au modèle de sécurité de TikTok.

### B. Limiteur de Fréquence Anti-Spam (Rate Limiting)
- TikTok applique un blocage temporaire (HTTP 429 ou `status_code: 10202`) lorsqu'un compte exécute plus de 20 à 30 actions de suppression par minute.
- **Solution mise en place dans TikTok Cleaner** :
  - `TikTokRateLimiter` introduit un délai adaptatif configurable (par défaut ~3.0s avec gigue aléatoire de ±1.5s pour reproduire fidèlement un comportement humain).
  - Après une salve de 25 suppressions consécutives, une pause de sécurité automatique de 15 secondes est insérée.
  - En cas de signalement `429`, un backoff exponentiel s'enclenche automatiquement.

### C. Détection de Session et Captcha
- Si un CAPTCHA survient, le `CircuitBreaker` de l'application interrompt la file d'attente pour éviter que le compte de l'utilisateur ne soit restreint par TikTok.
- L'utilisateur est invité à débloquer le captcha directement dans l'interface in-app, puis le nettoyage peut reprendre à l'élément exact où il s'était arrêté.

---

## 3. L'Approche Triple Source Adoptée par TikTok Cleaner

Pour garantir une expérience 100% fonctionnelle, l'application propose trois modes complémentaires :

1. **Session In-App Directe (Keychain Sécurisé)** :
   L'utilisateur s'authentifie une seule fois au sein de l'application via un composant natif. Les identifiants sont chiffrés dans le Keychain. L'application exécute les suppressions directement depuis l'iPhone vers les serveurs TikTok.
2. **Import d'Archive Officielle GDPR (Zéro Risque)** :
   TikTok met à disposition légale l'historique complet de compte (Paramètres > Télécharger vos données > JSON). TikTok Cleaner lit ce fichier instantanément en local, charge des milliers d'éléments sans la moindre requête réseau, et permet leur sélection.
3. **Mode Démonstration Haute Fidélité** :
   Permet d'évaluer le tableau de bord, le scan animé, le filtrage par date, la file d'attente résiliente, la pause/reprise et le bilan d'erreurs avec un jeu de données réaliste (1 284 likes, 42 vidéos, 316 reposts, 892 favoris).
