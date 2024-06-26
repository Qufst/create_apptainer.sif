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
mkdir -p ${HOME}/.local/bin/micromamba

wget -qO ${HOME}/.local/bin/micromamba ${RELEASE_URL}

ls -a ${HOME}/.local/bin/micromamba

chmod +x ${HOME}/.local/bin/micromamba
# Initializing shell
case "$INIT_YES" in
  y|Y|yes)
    case $(${HOME}/.local/bin/micromamba --version) in
      1.*|0.*)
        shell_arg=-s
        prefix_arg=-p
        ;;
      *)
        shell_arg=--shell
        prefix_arg=--root-prefix
        ;;
    esac
    ${HOME}/.local/bin/micromamba shell init $shell_arg "$shell" $prefix_arg "$PREFIX_LOCATION"

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
    ${HOME}/.local/bin/micromamba config append channels conda-forge
    ${HOME}/.local/bin/micromamba config append channels nodefaults
    ${HOME}/.local/bin/micromamba config set channel_priority strict
    ;;
esac