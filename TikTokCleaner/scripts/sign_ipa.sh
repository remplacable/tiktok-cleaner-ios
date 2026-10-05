#!/usr/bin/env bash
set -e

# ==============================================================================
# TIKTOK CLEANER iOS — SCRIPT DE SIGNATURE D'APPLICATION (.IPA)
# ==============================================================================

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <chemin_vers_app_ou_ipa> <Identité_de_signature_ou_Certificat> [mobileprovision]"
    echo ""
    echo "Exemples :"
    echo "  1) Signature Ad-Hoc locale :"
    echo "     $0 ./build/IPA/TikTokCleaner.ipa '-' "
    echo ""
    echo "  2) Signature avec compte Apple Développeur :"
    echo "     $0 ./build/IPA/TikTokCleaner.ipa 'Apple Development: John Doe (XXXXXX)' embedded.mobileprovision"
    echo ""
    echo "  3) Signature TrollStore / Fugu15 (ldid) :"
    echo "     ldid -S TikTokCleaner.app"
    exit 1
fi

TARGET="$1"
IDENTITY="$2"
PROVISION="$3"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "🔐 Début du processus de signature..."

if [[ "$TARGET" == *.ipa ]]; then
    echo "📦 Extraction de l'IPA..."
    unzip -q "$TARGET" -d "$TMP_DIR"
    APP_PATH=$(find "$TMP_DIR/Payload" -maxdepth 1 -name "*.app")
else
    APP_PATH="$TARGET"
fi

if [ -n "$PROVISION" ] && [ -f "$PROVISION" ]; then
    echo "📄 Injection du profil de provisionnement : $PROVISION"
    cp "$PROVISION" "$APP_PATH/embedded.mobileprovision"
fi

echo "✍️ Signature avec l'identité : $IDENTITY"
if command -v codesign >/dev/null 2>&1; then
    codesign -f -s "$IDENTITY" --deep --preserve-metadata=identifier,entitlements "$APP_PATH"
    echo "✅ Signature réussie avec codesign !"
elif command -v ldid >/dev/null 2>&1; then
    ldid -S "$APP_PATH"
    echo "✅ Signature réussie avec ldid !"
else
    echo "⚠️ Ni 'codesign' ni 'ldid' ne sont installés sur cet environnement."
    exit 1
fi

if [[ "$TARGET" == *.ipa ]]; then
    SIGNED_IPA="${TARGET%.ipa}_signed.ipa"
    echo "📦 Re-packaging de l'IPA signé vers $SIGNED_IPA..."
    cd "$TMP_DIR"
    zip -r -q "$SIGNED_IPA" Payload
    echo "✅ Fichier IPA signé prêt : $SIGNED_IPA"
fi
