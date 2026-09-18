#!/bin/bash
set -e

# If a pyproject.toml exists in the mounted project, install dependencies
if [ -f "pyproject.toml" ]; then
    echo "Found pyproject.toml. Syncing dependencies with uv..."
    uv sync
    # Activate virtual environment so opencode tools use the correct python context
    source .venv/bin/activate
else
    echo "No pyproject.toml found. Skipping dependency installation."
fi

# Pass all arguments to opencode (or just start opencode if no args are provided)
if [ $# -eq 0 ]; then
    exec opencode
else
    exec opencode "$@"
fi
