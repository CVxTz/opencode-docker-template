FROM python:3.12-slim

# Match the host user so files created in the bind-mounted /workspace
# are owned by the host user instead of root. Override at build time:
#   docker compose build --build-arg UID=$(id -u) --build-arg GID=$(id -g)
ARG UID=1000
ARG GID=1000

# Install system dependencies needed for OpenCode and building Python packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
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

# Create a non-root user matching the host uid/gid (files written to the
# bind-mounted workspace then belong to the host user, not root)
RUN if ! getent group "${GID}" >/dev/null; then groupadd --gid "${GID}" agent; fi \
    && if ! getent passwd "${UID}" >/dev/null; then useradd --uid "${UID}" --gid "${GID}" --create-home --shell /bin/bash agent; fi

ENV HOME=/home/agent
ENV PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Set up the working directory inside the container.
# /workspace/.venv is pre-created with the runtime user's ownership so the
# "opencode-venv" named volume that masks it inherits the same owner.
# The config dir is pre-created for the ~/.config/opencode bind mount.
WORKDIR /workspace
RUN mkdir -p /workspace/.venv /home/agent/.config/opencode \
    && chown -R "${UID}:${GID}" /workspace /home/agent \
    && git config --global --add safe.directory /workspace

# Copy and prepare the startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Drop root privileges for everything that runs at runtime
USER agent

# Run the entrypoint by default
ENTRYPOINT ["/entrypoint.sh"]
