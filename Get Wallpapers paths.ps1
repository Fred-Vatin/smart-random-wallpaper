Set-Location $PSScriptRoot

# Initialisation de la variable $Output
$Output = '$Wallpapers = @()' + [Environment]::NewLine

# Chemin du dossier Wallpapers dans le répertoire courant (pwd)
$wallpapersPath = Join-Path -Path (Get-Location) -ChildPath 'wallpapers'

# Vérifier si le dossier Wallpapers existe
if (Test-Path -Path $wallpapersPath -PathType Container) {
  # Parcourir chaque dossier enfant de Wallpapers (non récursif)
  Get-ChildItem -Path $wallpapersPath -Directory | ForEach-Object {
    $CurrentFolder = $_.Name
    # Chemin du fichier LivelyInfo.json dans le dossier courant
    $jsonFile = Join-Path -Path $_.FullName -ChildPath 'LivelyInfo.json'

    # Vérifier si le fichier LivelyInfo.json existe
    if (Test-Path -Path $jsonFile -PathType Leaf) {
      try {
        # Lire le contenu du fichier JSON
        $jsonContent = Get-Content -Path $jsonFile -Raw | ConvertFrom-Json
        # Extraire la propriété Title
        $Title = $jsonContent.Title

        # Vérifier si Title existe et n'est pas vide
        if ($Title) {
          # Ajouter le texte formaté à $Output
          $Output += "`$Wallpapers += New-Object -TypeName psobject -Property @{" + [Environment]::NewLine
          $Output += "    'Folder' = '$CurrentFolder'" + [Environment]::NewLine
          $Output += "    'Title' = '$Title'" + [Environment]::NewLine
          $Output += "}" + [Environment]::NewLine
        }
      }
      catch {
        Write-Warning "Erreur lors de la lecture du fichier `"LivelyInfo.json`" dans $CurrentFolder : $_"
      }
    }
  }
}
else {
  Write-Warning "Le dossier `"wallpapers`" n'existe pas dans le répertoire courant."
  exit
}

# Afficher $Output dans la console
Write-Output $Output

# Écrire $Output dans le fichier Wallpapers.txt dans le répertoire courant
$Output | Out-File -FilePath (Join-Path -Path (Get-Location) -ChildPath 'Wallpapers list.txt') -Encoding UTF8
