#!/bin/sh

set -eu

# détéction du shell parent, je peux le modifier vu que le shell est constant ici
parent=$(ps -o comm $PPID |tail -1)
parent=${parent#-}  # remove the leading dash that login shells have
case "$parent" in
  # shells supported by `micromamba shell init`
  bash|fish|xonsh|zsh)
    shell=$parent
    ;;
  *)
    # use the login shell (basename of $SHELL) as a fallback
    shell=${SHELL##*/}
    ;;
esac

# cette partie est un peu inutile dans un workflows mais je la garde quand même
if [ -t 0 ] ; then
  printf "Micromamba binary folder? [~/.local/bin] "
  read BIN_FOLDER
  printf "Init shell ($shell)? [Y/n] "
  read INIT_YES
  printf "Configure conda-forge? [Y/n] "
  read CONDA_FORGE_YES
fi

# réponse automatiques oui
BIN_FOLDER="${BIN_FOLDER:-${HOME}/.local/bin}"
INIT_YES="${INIT_YES:-yes}"
CONDA_FORGE_YES="${CONDA_FORGE_YES:-yes}"

# définit le lieu de `micromamba shell init`
case "$INIT_YES" in
  y|Y|yes)
    if [ -t 0 ]; then
      printf "Prefix location? [~/micromamba] "
      read PREFIX_LOCATION
    fi
    ;;
esac
PREFIX_LOCATION="${PREFIX_LOCATION:-${HOME}/micromamba}"

# Téléchargement de l'url
RELEASE_URL=https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64

# Downloading artifact
ls -a
mkdir -p "${BIN_FOLDER}"
ls -a ${HOME}/.local/bin
if hash curl >/dev/null 2>&1; then
  curl "${RELEASE_URL}" -o "${BIN_FOLDER}/micromamba" -fsSL --compressed ${CURL_OPTS:-}
elif hash wget >/dev/null 2>&1; then
  wget ${WGET_OPTS:-} -qO "${BIN_FOLDER}/micromamba" "${RELEASE_URL}"
else
  echo "Neither curl nor wget was found" >&2
  exit 1
fi
chmod +x "${BIN_FOLDER}/micromamba"


# Initializing shell
case "$INIT_YES" in
  y|Y|yes)
    case $("${BIN_FOLDER}/micromamba" --version) in
      1.*|0.*)
        shell_arg=-s
        prefix_arg=-p
        ;;
      *)
        shell_arg=--shell
        prefix_arg=--root-prefix
        ;;
    esac
    "${BIN_FOLDER}/micromamba" shell init $shell_arg "$shell" $prefix_arg "$PREFIX_LOCATION"

    echo "Please restart your shell to activate micromamba or run the following:\n"
    echo "  source ~/.bashrc (or ~/.zshrc, ~/.xonshrc, ~/.config/fish/config.fish, ...)"
    ;;
  *)
    echo "You can initialize your shell later by running:"
    echo "  micromamba shell init"
    ;;
esac


# Initializing conda-forge
case "$CONDA_FORGE_YES" in
  y|Y|yes)
    "${BIN_FOLDER}/micromamba" config append channels conda-forge
    "${BIN_FOLDER}/micromamba" config append channels nodefaults
    "${BIN_FOLDER}/micromamba" config set channel_priority strict
    ;;
esac