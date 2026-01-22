# Polices Poppins

Ce dossier contient les fichiers de polices Poppins utilisés localement dans l'application.

## Téléchargement des polices

### Option 1 : Script PowerShell (Windows)
Exécutez le script `download_fonts.ps1` à la racine du projet :
```powershell
.\download_fonts.ps1
```

### Option 2 : Téléchargement manuel
Téléchargez les fichiers suivants depuis Google Fonts et placez-les dans ce dossier :

1. **Poppins-Regular.ttf** (weight: 400)
   - URL: https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf

2. **Poppins-Medium.ttf** (weight: 500)
   - URL: https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf

3. **Poppins-SemiBold.ttf** (weight: 600)
   - URL: https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf

4. **Poppins-Bold.ttf** (weight: 700)
   - URL: https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf

### Option 3 : Google Fonts Helper
Vous pouvez également utiliser l'outil Google Fonts Helper :
https://google-webfonts-helper.herokuapp.com/fonts/poppins

Sélectionnez les variantes : Regular (400), Medium (500), SemiBold (600), Bold (700)

## Fichiers requis

Assurez-vous d'avoir ces 4 fichiers dans ce dossier :
- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

Une fois les fichiers téléchargés, exécutez `flutter pub get` pour que Flutter reconnaisse les nouvelles polices.
