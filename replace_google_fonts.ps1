# Script pour remplacer GoogleFonts.poppins() par FontHelper.poppins() dans tous les fichiers

$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object { 
    $content = Get-Content $_.FullName -Raw
    $content -match "GoogleFonts"
}

Write-Host "Trouve $($files.Count) fichiers a modifier..." -ForegroundColor Cyan

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $modified = $false
    
    # Remplacer GoogleFonts.poppins().fontFamily par FontHelper.poppinsFontFamily
    if ($content -match "GoogleFonts\.poppins\(\)\.fontFamily") {
        $content = $content -replace "GoogleFonts\.poppins\(\)\.fontFamily", "FontHelper.poppinsFontFamily"
        $modified = $true
    }
    
    # Remplacer GoogleFonts.poppins( par FontHelper.poppins(
    if ($content -match "GoogleFonts\.poppins\(") {
        $content = $content -replace "GoogleFonts\.poppins\(", "FontHelper.poppins("
        $modified = $true
    }
    
    # Remplacer l'import google_fonts par font_helper (seulement si GoogleFonts n'est plus utilisé)
    if ($content -match "import\s+['\`"]package:google_fonts/google_fonts\.dart['\`"];") {
        # Vérifier si GoogleFonts est encore utilisé ailleurs dans le fichier
        if ($content -notmatch "GoogleFonts\.") {
            $content = $content -replace "import\s+['\`"]package:google_fonts/google_fonts\.dart['\`"];", "import 'package:saarciflex_app/core/utils/font_helper.dart';"
            $modified = $true
        } else {
            # Ajouter l'import font_helper en plus si GoogleFonts est encore utilisé
            if ($content -notmatch "import.*font_helper") {
                $content = $content -replace "(import\s+['\`"]package:google_fonts/google_fonts\.dart['\`"];)", "`$1`nimport 'package:saarciflex_app/core/utils/font_helper.dart';"
                $modified = $true
            }
        }
    }
    
    # Si le fichier a été modifié, l'écrire
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "[OK] Modifie: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Host "`nRemplacement termine!" -ForegroundColor Green
