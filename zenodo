#!/bin/bash

# Variables
ACCESS_TOKEN=$ZENODO_TOKEN  # Variable d'environnement pour le token
DEPOSITION_ID="13271931"
IMAGE_PATH="image.sif"

# Créer une nouvelle version
NEW_VERSION_RESPONSE=$(curl -s -X POST "https://zenodo.org/api/deposit/depositions/${DEPOSITION_ID}/actions/newversion?access_token=${ACCESS_TOKEN}")

# Vérifier si la création de la nouvelle version a réussi
if [ -z "$NEW_VERSION_RESPONSE" ]; then
  echo "Échec de la création de la nouvelle version."
  exit 1
fi

# Extraire l'URL de la version brouillon et l'ID de dépôt de la nouvelle version
NEW_VERSION=$(echo $NEW_VERSION_RESPONSE | jq -r '.links.latest_draft')
NEW_DEPOSITION_ID=$(basename ${NEW_VERSION})

# Télécharger l'image Apptainer vers le dépôt
UPLOAD_RESPONSE=$(curl --progress-bar -o /dev/null -i -X POST \
  -F "file=@${IMAGE_PATH}" \
  "${NEW_VERSION}/files?access_token=${ACCESS_TOKEN}")

# Vérifier si l'upload a réussi
if [ $? -ne 0 ]; then
  echo "Échec du téléchargement de l'image."
  exit 1
fi

# Publier la nouvelle version
PUBLISH_RESPONSE=$(curl -s -X POST "${NEW_VERSION}/actions/publish?access_token=${ACCESS_TOKEN}")

# Vérifier si la publication a réussi
if [ $? -ne 0 ]; then
  echo "Échec de la publication de la nouvelle version."
  exit 1
fi

echo "Nouvelle version créée et publiée avec succès !"
