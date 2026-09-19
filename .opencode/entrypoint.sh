#!/bin/bash
set -e

# The bind mount preserves host ownership, so stat-ing /workspace reveals the
# host user's UID/GID without any configuration — no HOST_UID/HOST_GID needed.
WS_UID=$(stat -c '%u' /workspace)
WS_GID=$(stat -c '%g' /workspace)

# A root-owned workspace (CI checkouts, Docker Desktop on macOS where
# ownership is virtualized) is only writable by root, so stay root.
if [ "$WS_UID" = "0" ]; then
    echo "[opencode-entrypoint] Workspace owned by root — running as root."
    exec opencode "$@"
fi

echo "[opencode-entrypoint] Detected workspace owner: UID=$WS_UID GID=$WS_GID"

# Reuse an existing group with the target GID if there is one (avoids
# collisions with system groups like 'users'), otherwise retarget 'agent'.
GROUP_NAME="$(getent group "$WS_GID" | cut -d: -f1)"
if [ -z "$GROUP_NAME" ]; then
    groupmod -o -g "$WS_GID" agent
    GROUP_NAME="agent"
fi

# Retarget the runtime user to match the workspace owner, then fix ownership
# of the small home/XDG dirs. The workspace itself is never chown-ed: the
# agent's UID now equals its owner, so every file is already writable.
usermod -o -u "$WS_UID" -g "$GROUP_NAME" agent
chown -R "$WS_UID:$WS_GID" /home/agent

# The venv named volume keeps the ownership of whichever UID created it; fix
# it only when that no longer matches (cheaper than rebuilding the venv).
if [ -d /workspace/.venv ]; then
    VENV_UID=$(stat -c '%u' /workspace/.venv)
    if [ "$VENV_UID" != "$WS_UID" ]; then
        chown -R "$WS_UID:$WS_GID" /workspace/.venv
    fi
fi

cd /workspace

# Sync dependencies as the agent user so generated files aren't owned by root.
if [ -f pyproject.toml ]; then
    echo "[opencode-entrypoint] Found pyproject.toml. Syncing dependencies with uv..."
    gosu agent uv sync
else
    echo "[opencode-entrypoint] No pyproject.toml found. Skipping dependency installation."
fi

# Drop privileges and hand over to opencode.
exec gosu agent opencode "$@"
