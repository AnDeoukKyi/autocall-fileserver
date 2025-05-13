#!/bin/bash


WORKDIR="$HOME/autocall-fileserver"
REPO="https://github.com/AndeoukKyi/autocall-fileserver.git"


if [ ! -d "$WORKDIR" ]; then
  git clone "$REPO" "$WORKDIR"
fi

cd "$WORKDIR" || exit 1


if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate


pip install --upgrade pip
pip install -r requirements.txt