param(
    [Parameter(HelpMessage = "Profondeur de recherche récursive (défaut: 1)")]
    [int]$Depth = 1
)

# Définir l'extension des fichiers YAML à traiter
$files = Get-ChildItem -Path "." -Recurse -Depth $Depth -Include "*.yaml", "*.yml" -File

foreach ($file in $files) {
    Write-Host "Traitement de : $($file.FullName)" -ForegroundColor Cyan
    
    # Lecture du contenu du fichier
    $content = Get-Content $file.FullName
    $newContent = New-Object System.Collections.Generic.List[string]
    
    $i = 0
    while ($i -lt $content.Count) {
        $line = $content[$i]
        
        # Détection d'un service (ex: "  semaphore:")
        if ($line -match '^\s{2}(\w+):') {
            $serviceName = $matches[1]
            $newContent.Add($line)
            $i++
            continue
        }

        # Détection de la section environment
        if ($line -match '^\s{4}environment:') {
            $envLines = New-Object System.Collections.Generic.List[string]
            $indentation = ""
            $i++
            
            # Récupération des variables tant qu'elles sont indentées
            while ($i -lt $content.Count -and $content[$i] -match '^\s{6,}(.*)') {
                $rawVar = $matches[1].Trim("- ")
                # Nettoyage si la variable est sous format KEY: VALUE
                $cleanVar = $rawVar -replace ':\s+', '='
                $envLines.Add($cleanVar)
                $i++
            }
            
            if ($envLines.Count -gt 0) {
                # Création du fichier .env
                $envFileName = "$($serviceName).env"
                $envFilePath = Join-Path $file.DirectoryName $envFileName
                $envLines | Out-File -FilePath $envFilePath -Encoding utf8
                
                # Ajout de la référence env_file dans le YAML
                $newContent.Add("    env_file:")
                $newContent.Add("      - ./$envFileName")
                Write-Host "  -> Créé : $envFileName" -ForegroundColor Green
            }
        } else {
            $newContent.Add($line)
            $i++
        }
    }
    
    # Sauvegarde du nouveau fichier YAML
    $newContent | Out-File -FilePath $file.FullName -Encoding utf8
}

Write-Host "Migration terminée !" -ForegroundColor Yellow