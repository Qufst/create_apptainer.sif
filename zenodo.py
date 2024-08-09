import requests
import json

# Remplacez par votre token d'accès Zenodo
headers = {"Content-Type": "application/json"}
params = {'access_token': ZENODO_TOKEN}

# Créer une nouvelle déposition vide
response = requests.post('https://zenodo.org/api/deposit/depositions',
                         params=params,
                         json={},
                         headers=headers)

if response.status_code == 201:
    print("Deposition created successfully")
else:
    print(f"Failed to create deposition: {response.status_code}")
    print(response.json())
    exit(1)

# Extraire l'ID de la déposition et l'URL du bucket
deposition_id = response.json()['13271931']
bucket_url = response.json()["links"]["bucket"]

# Télécharger le fichier sur la déposition créée
path = "./image.sif"
filename = "image.sif"

with open(path, "rb") as file:
    upload_response = requests.put(
        "%s/%s" % (bucket_url, filename),
        data=file,
        params=params,
    )

if upload_response.status_code == 200:
    print("File uploaded successfully")
else:
    print(f"Failed to upload file: {upload_response.status_code}")
    print(upload_response.json())
    exit(1)

# Ajouter des métadonnées à la déposition
metadata = {
    'metadata': {
        'title': 'Stockage for apptainer\'s pictures',
        'upload_type': 'Other',
        'description': 'Etude du stockage d\'environnements apptainer créés sur github pour la reproductibilité scientifique en statistiques.',
        'creators': [{'name': 'Festor Quentin', 'affiliation': 'Université de Montpellier'}],
        'keywords': ['Apptainer', 'Scientific reproducibility', 'Statistics']
    }
}

metadata_response = requests.put(
    'https://zenodo.org/api/deposit/depositions/%s' % deposition_id,
    params=params,
    data=json.dumps(metadata),
    headers=headers
)

if metadata_response.status_code == 200:
    print("Metadata added successfully")
else:
    print(f"Failed to add metadata: {metadata_response.status_code}")
    print(metadata_response.json())
    exit(1)

# Publier la déposition
publish_response = requests.post(
    'https://zenodo.org/api/deposit/depositions/%s/actions/publish' % deposition_id,
    params=params
)

if publish_response.status_code == 202:
    print("Deposition published successfully")
else:
    print(f"Failed to publish deposition: {publish_response.status_code}")
    print(publish_response.json())
    exit(1)
