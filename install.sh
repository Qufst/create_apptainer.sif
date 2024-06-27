#!/bin/sh

set -eu

# Téléchargement de Micromamba
RELEASE_URL=https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64

mkdir -p /root/.local/bin/
wget -qO /root/.local/bin/micromamba ${RELEASE_URL}
chmod a+x /root/.local/bin/micromamba

# Initialiser Micromamba (désactivé car non interactif)
# /root/.local/bin/micromamba shell init -s bash -p /root/micromamba

# Configurer conda-forge
/root/.local/bin/micromamba config append channels conda-forge
/root/.local/bin/micromamba config append channels nodefaults
/root/.local/bin/micromamba config set channel_priority strict
