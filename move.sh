#!/bin/bash

# Ce script permet de migrer tout les docker-compose vers leurs propre repertoires

# Parcourir tous les fichiers .yaml dans le répertoire courant
for fichier in *.yaml; do
    # Vérifier si des fichiers .yaml existent (éviter une erreur si aucun fichier)
    if [ ! -e "$fichier" ]; then
        echo "Aucun fichier .yaml trouvé."
        exit 1
    fi

    # Récupérer le nom sans l'extension .yaml
    nom="${fichier%.yaml}"

    # Créer un dossier avec ce nom (si il n'existe pas déjà)
    mkdir -p "$nom"

    # Déplacer le fichier dans le dossier créé
    mv "$fichier" "$nom/"

    echo "Fichier $fichier déplacé dans le dossier $nom/"
done
