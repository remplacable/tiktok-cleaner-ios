# Guide de Compilation, Génération .IPA & Signature

Ce guide explique comment compiler l'application **TikTok Cleaner iOS**, générer le fichier **.IPA** et le signer pour une installation directe sur iPhone ou iPad.

---

## 1. Prérequis & Environnement

- **macOS** 13.0 (Ventura) ou ultérieur (macOS Sonoma / Sequoia recommandé)
- **Xcode** 15.0+ avec SDK iOS 16.0+
- Outils de ligne de commande Xcode (`xcode-select --install`)
- Un compte Apple (gratuit ou Apple Developer Program)

---

## 2. Compilation & Génération Automatisée du fichier .IPA

Le projet intègre un script bash clé en main dans le dossier `scripts/` :

```bash
cd TikTokCleaner
chmod +x scripts/build_ipa.sh
./scripts/build_ipa.sh
```

Ce script effectue automatiquement :
1. La compilation de l'application en mode **Release** (`iphoneos`).
2. La création de l'archive Xcode `.xcarchive`.
3. Le packaging du dossier `Payload/` et la compression en fichier **`TikTokCleaner.ipa`** dans le dossier `build/IPA/`.

---

## 3. Méthode via l'Interface Graphique Xcode

1. Ouvrez `TikTokCleaner.xcodeproj` dans Xcode :
   ```bash
   open TikTokCleaner.xcodeproj
   ```
2. Dans le sélecteur de cible en haut, choisissez **Any iOS Device (arm64)** (ou votre iPhone connecté par câble).
3. Cliquez sur **Product > Archive**.
4. Une fois l'archive terminée dans la fenêtre *Organizer* :
   - Cliquez sur **Distribute App**.
   - Choisissez la méthode de distribution :
     - **Custom / Ad Hoc** (pour un IPA installable sur vos appareils enregistrés)
     - **Development** (pour vos appareils de test)
     - **App Store Connect / TestFlight** (pour une distribution bêta ou publique)
   - Validez les options et exportez le dossier contenant le fichier `.ipa`.

---

## 4. Signature du Fichier .IPA

### Option A — Avec le script `sign_ipa.sh` fourni
```bash
./scripts/sign_ipa.sh ./build/IPA/TikTokCleaner.ipa "Apple Development: Votre Nom (XXXXXXXXXX)" mon_profil.mobileprovision
```

### Option B — Installation Sideloading (Sans Mac ou avec compte gratuit)
Le fichier `.ipa` généré peut être installé directement sur votre iPhone via :
- **AltStore** (Windows / macOS) : Glissez-déposez le fichier `.ipa` dans AltServer ou ouvrez-le via le bouton `+` dans AltStore sur l'iPhone.
- **Sideloadly** (Windows / macOS) : Glissez le fichier `.ipa`, entrez votre Apple ID et cliquez sur **Start**.
- **TrollStore** (appareils compatibles iOS 14.0 à 17.0) : Installez directement sans limite de 7 jours ni besoin de re-signer.
- **Scarlet / Esign** : Installation directe sur l'appareil avec certificat d'entreprise ou DNS anti-révocation.

---

## 5. Exécution des Tests Automatisés

Le projet inclut une suite complète de tests unitaires et d'intégration validant le `CleanupEngine`, la `TaskQueue`, le `RateLimiter` et le `GDPRArchiveScanner` :

Dans Xcode :
- Raccourci : `Cmd + U`

En ligne de commande :
```bash
xcodebuild test \
    -project TikTokCleaner.xcodeproj \
    -scheme TikTokCleaner \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```
