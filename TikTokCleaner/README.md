# TikTok Cleaner iOS — Application Native V1

**TikTok Cleaner iOS** est une application native iOS moderne conçue sous **Swift / SwiftUI** permettant le nettoyage et la gestion massive des éléments d'un compte TikTok directement sur l'appareil.

---

## 🎯 Fonctionnalités Clés

- **❤️ Gestion & Suppression des Likes** : Retrait massif des likes passés.
- **🎬 Gestion des Vidéos publiées** : Sélection granulaire et suppression.
- **🔁 Annulation des Republications** : Retrait des vidéos republiées.
- **⭐ Nettoyage des Favoris** : Désarchivage des vidéos enregistrées.
- **⚡ Moteur de Traitement Résilient** :
  - File d'attente asynchrone avec pause, reprise et annulation en temps réel.
  - Limiteur de débit adaptatif anti-spam (gigue aléatoire, respect des pauses de sécurité TikTok).
  - Gestion détaillée des erreurs : diagnostic clair (cause racine, action recommandée, réessai).
  - Coupe-circuit de sécurité (`CircuitBreaker`) protégeant le compte contre les blocages préventifs.
- **🔒 Sécurité & Confidentialité** :
  - Stockage des identifiants et cookies exclusivement dans le **Keychain iOS**.
  - Zéro serveur intermédiaire : requêtes 100% locales iPhone ↔ TikTok.
  - Masquage automatique des secrets dans la console de logs développeur.
- **📂 Triple Source d'Analyse** :
  - Connexion in-app directe.
  - Importation d'archive officielle TikTok RGPD (JSON).
  - Mode Démonstration haute fidélité (1 284 likes, 42 vidéos, 316 reposts, 892 favoris).

---

## 📱 Structure du Projet

```text
TikTokCleaner
│
├── App/                  # Point d'entrée de l'application & Injection d'environnement
├── Models/               # Modèles de données (CleanableItem, CleanupCategory, CleanupError...)
├── Authentication/       # Authentification in-app sécurisée & Session
├── TikTokService/        # Endpoints, Client réseau & Limiteur de débit
├── ContentScanner/       # Scanner multi-catégorie & Décodeur JSON RGPD
├── LikeManager/          # Gestionnaire des Likes
├── PostManager/          # Gestionnaire des Publications
├── RepostManager/        # Gestionnaire des Republications
├── FavoritesManager/     # Gestionnaire des Favoris
├── CleanupEngine/        # Moteur d'exécution & Coupe-circuit de sécurité
├── TaskQueue/            # File d'attente séquentielle avec retry & backoff
├── ProgressManager/      # Suivi d'avancement & génération de bilans
├── SecureStorage/        # Gestionnaire Keychain iOS
├── Settings/             # Paramètres de simulation (Dry-Run) & cadences
├── Logging/              # Journalisation in-app avec assainissement des secrets
├── UI/                   # Interfaces SwiftUI (Thème sombre sobre, Dashboard, Scanner...)
├── Resources/            # Info.plist, Entitlements, Assets.xcassets
├── Tests/                # Tests unitaires et d'intégration XCTest
├── scripts/              # Scripts de génération .IPA et signature
└── Documentation/        # Guides d'architecture et limitations techniques
```

---

## 🚀 Génération du fichier .IPA

Pour générer l'archive et le fichier `.ipa` :

```bash
chmod +x scripts/build_ipa.sh
./scripts/build_ipa.sh
```

Le fichier compilé est placé dans `build/IPA/TikTokCleaner.ipa`.
Consultez [Documentation/BUILD_AND_SIGNING_GUIDE.md](file:///home/nzo/cybersecurite/appli_tiktok/TikTokCleaner/Documentation/BUILD_AND_SIGNING_GUIDE.md) pour les détails de signature et de déploiement (AltStore, TrollStore, Sideloadly, Xcode).
