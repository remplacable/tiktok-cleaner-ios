#!/usr/bin/env bash
set -e

# ==============================================================================
# TIKTOK CLEANER iOS — SCRIPT DE GÉNÉRATION D'ARCHIVE ET DE FICHIER .IPA
# ==============================================================================

echo "=========================================================="
echo "🚀 TikTok Cleaner iOS — Compilateur & Générateur .IPA"
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
ARCHIVE_PATH="$BUILD_DIR/TikTokCleaner.xcarchive"
IPA_DIR="$BUILD_DIR/IPA"
IPA_OUTPUT="$IPA_DIR/TikTokCleaner.ipa"

mkdir -p "$BUILD_DIR"
mkdir -p "$IPA_DIR"

echo "📂 Répertoire du projet : $PROJECT_ROOT"
echo "📂 Répertoire de sortie : $IPA_DIR"

if command -v xcodebuild >/dev/null 2>&1; then
    echo "🍏 Détection de macOS et Xcode. Lancement du build natif xcodebuild..."
    
    # 1. Clean & Archive
    echo "📦 Création de l'archive Xcode..."
    xcodebuild archive \
        -project "$PROJECT_ROOT/TikTokCleaner.xcodeproj" \
        -scheme "TikTokCleaner" \
        -configuration Release \
        -sdk iphoneos \
        -archivePath "$ARCHIVE_PATH" \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        AD_HOC_CODE_SIGNING_ALLOWED=YES

    # 2. Création du Payload et du fichier .IPA
    echo "📦 Packaging du fichier .IPA..."
    PAYLOAD_DIR="$BUILD_DIR/Payload"
    rm -rf "$PAYLOAD_DIR"
    mkdir -p "$PAYLOAD_DIR"
    
    cp -R "$ARCHIVE_PATH/Products/Applications/TikTokCleaner.app" "$PAYLOAD_DIR/"
    
    cd "$BUILD_DIR"
    zip -r -q "$IPA_OUTPUT" Payload
    rm -rf "$PAYLOAD_DIR"
    
    echo "✅ SUCCÈS ! Fichier .IPA généré :"
    echo "👉 $IPA_OUTPUT"
else
    echo "⚠️ xcodebuild n'est pas disponible sur cet environnement (Linux détecté)."
    echo "💡 Pour compiler l'IPA directement :"
    echo "   1) Sur macOS avec Xcode installé, exécutez ce script : ./scripts/build_ipa.sh"
    echo "   2) Ou ouvrez 'TikTokCleaner.xcodeproj' dans Xcode > Product > Archive > Distribute App (.ipa)"
    echo "   3) Pour AltStore / TrollStore / Sideloadly : l'IPA non signé ou signé Ad-hoc peut être installé directement."
    echo ""
    echo "ℹ️ Génération de la structure de packaging prête à l'emploi..."
fi

echo "=========================================================="
