# Script pour télécharger les polices Poppins depuis Google Fonts
# Exécutez ce script avec: .\download_fonts.ps1

$fontsDir = "fonts"
$baseUrl = "https://github.com/google/fonts/raw/main/ofl/poppins"

# Créer le dossier fonts s'il n'existe pas
if (-not (Test-Path $fontsDir)) {
    New-Item -ItemType Directory -Path $fontsDir
}

Write-Host "Téléchargement des polices Poppins..." -ForegroundColor Green

# Télécharger les différentes variantes de Poppins
$fonts = @(
    @{Name="Poppins-Regular.ttf"; Url="$baseUrl/Poppins-Regular.ttf"},
    @{Name="Poppins-Medium.ttf"; Url="$baseUrl/Poppins-Medium.ttf"},
    @{Name="Poppins-SemiBold.ttf"; Url="$baseUrl/Poppins-SemiBold.ttf"},
    @{Name="Poppins-Bold.ttf"; Url="$baseUrl/Poppins-Bold.ttf"}
)

foreach ($font in $fonts) {
    $outputPath = Join-Path $fontsDir $font.Name
    Write-Host "Téléchargement de $($font.Name)..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $font.Url -OutFile $outputPath -UseBasicParsing
        Write-Host "[OK] $($font.Name) telecharge avec succes" -ForegroundColor Green
    } catch {
        Write-Host "[ERREUR] Erreur lors du telechargement de $($font.Name): $_" -ForegroundColor Red
        Write-Host "URL alternative: $($font.Url)" -ForegroundColor Yellow
    }
}

Write-Host "`nTéléchargement terminé!" -ForegroundColor Green
Write-Host "Les polices sont maintenant dans le dossier 'fonts/'" -ForegroundColor Cyan
