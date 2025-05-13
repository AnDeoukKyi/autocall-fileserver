#!/bin/bash


WORKDIR="$HOME/autocall-fileserver"

cd "$WORKDIR" || exit 1


if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate

uvicorn server:app --host 0.0.0.0 --port 7211
