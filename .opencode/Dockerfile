FROM python:3.12-slim

# Install system dependencies needed for OpenCode and building Python packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Install uv (astral's fast python dependency manager) system-wide so the
# non-root runtime user can use it. Copying from the official image is the
# documented method — unlike `curl ... | sh`, a failed pull fails the build
# instead of silently skipping the install (pipeline exit codes are lost).
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install OpenCode CLI system-wide (relocate from the root $HOME default)
RUN curl -fsSL https://opencode.ai/install | bash \
    && mv /root/.opencode/bin/opencode /usr/local/bin/opencode

# The web command runs `open(localhostUrl)` to launch a browser, which inside a
# container resolves to xdg-open (not installed) and dumps a spawn error in the
# logs. Shim it with a no-op so startup logs stay clean.
RUN printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/xdg-open && chmod +x /usr/local/bin/xdg-open

# Placeholder non-root user. No UID/GID build args: the entrypoint retargets
# this user at runtime to match the host owner of the bind-mounted /workspace.
RUN groupadd --gid 10001 agent \
    && useradd --uid 10001 --gid 10001 --create-home --shell /bin/bash agent

ENV HOME=/home/agent
ENV PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Set up the working directory inside the container.
# /workspace/.venv is pre-created with the runtime user's ownership so the
# "opencode-venv" named volume that masks it inherits the same owner.
# The config dir is pre-created for the agent's XDG paths.
WORKDIR /workspace
RUN mkdir -p /workspace/.venv /home/agent/.config/opencode \
    && chown -R agent:agent /workspace /home/agent

# Copy and prepare the startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run the entrypoint by default (starts as root to detect the workspace owner,
# then drops to a matching non-root user)
ENTRYPOINT ["/entrypoint.sh"]
