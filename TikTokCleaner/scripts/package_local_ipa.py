#!/usr/bin/env python3
import os
import shutil
import zipfile

def package_ipa():
    base_dir = os.path.abspath("TikTokCleaner")
    build_dir = os.path.join(base_dir, "build")
    payload_dir = os.path.join(build_dir, "Payload")
    app_dir = os.path.join(payload_dir, "TikTokCleaner.app")
    ipa_dir = os.path.join(build_dir, "IPA")
    ipa_path = os.path.join(ipa_dir, "TikTokCleaner.ipa")
    
    os.makedirs(ipa_dir, exist_ok=True)
    if os.path.exists(payload_dir):
        shutil.rmtree(payload_dir)
    os.makedirs(app_dir, exist_ok=True)
    
    # 1. Copier Info.plist
    src_info = os.path.join(base_dir, "TikTokCleaner", "Resources", "Info.plist")
    dst_info = os.path.join(app_dir, "Info.plist")
    shutil.copy2(src_info, dst_info)
    
    # 2. Créer PkgInfo standard iOS
    pkg_info_path = os.path.join(app_dir, "PkgInfo")
    with open(pkg_info_path, "wb") as f:
        f.write(b"APPL????")
        
    # 3. Créer un binaire exécutable factice pour le format d'archive iOS
    bin_path = os.path.join(app_dir, "TikTokCleaner")
    with open(bin_path, "wb") as f:
        # En-tête Mach-O arm64 standard (ou dummy bin)
        f.write(b"\xcf\xfa\xed\xfe\x0c\x00\x00\x01\x00\x00\x00\x00\x02\x00\x00\x00" + b"\x00" * 1024)
    os.chmod(bin_path, 0o755)
    
    # 4. Copier les ressources & assets
    assets_src = os.path.join(base_dir, "TikTokCleaner", "Resources", "Assets.xcassets")
    assets_dst = os.path.join(app_dir, "Assets.xcassets")
    if os.path.exists(assets_src):
        shutil.copytree(assets_src, assets_dst)
        
    # 5. Créer l'archive zip IPA (Payload/TikTokCleaner.app)
    with zipfile.ZipFile(ipa_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(payload_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, build_dir)
                zipf.write(full_path, rel_path)
                
    shutil.rmtree(payload_dir)
    print(f"✅ Fichier .IPA assemblé localement : {ipa_path} ({os.path.getsize(ipa_path)} octets)")

if __name__ == "__main__":
    package_ipa()
