#!/bin/bash

# Variables
ACCESS_TOKEN=$ZENODO_TOKEN # token zenodo
DEPOSITION_ID="13271931" # id du dépôt zenodo
IMAGE_PATH="image.sif" # nom de l'image à publier
PUBLICATION_DATE=$(date -I)  # La date de publication au format ISO (YYYY-MM-DD)
VERSION="v3" # Version à modifier pour faire +1 par rapport à ce qui éxiste

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

# Ajouter les métadonnées nécessaires (y compris la date de publication)
UPDATE_METADATA_RESPONSE=$(curl -s -X PUT \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  --data-binary @- \
  "${NEW_VERSION}?access_token=${ACCESS_TOKEN}" <<EOF
{
  "metadata": {
    "title": "Nouvelle version avec image Apptainer",
    "upload_type": "software",
    "description": "AutoPublication de l'environnement apptainer depuis github",
    "publication_date": "$PUBLICATION_DATE",
    "version": "$VERSION",
    "creators": [
      {
        "name": "Festor Quentin"
        "affiliation": "Université de Montpellier"
      }
    ]
  }
}
EOF
)

# Vérifier si la mise à jour des métadonnées a réussi
if [ $? -ne 0 ]; then
  echo "Échec de la mise à jour des métadonnées."
  exit 1
fi

# Télécharger l'image Apptainer vers le dépôt
UPLOAD_RESPONSE=$(curl --silent -o /dev/null -i -X POST \
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
