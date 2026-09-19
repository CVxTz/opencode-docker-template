# opencode-docker-template

A Docker-based template for running [opencode](https://opencode.ai) against any project. Zero UID/GID configuration: the container detects the host owner of your workspace at startup and matches it, so files the agent creates stay owned by you — whatever your UID is.

## Setup

Configure the provider in `.opencode/config.json`:

   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "model": "fireworks-ai/accounts/fireworks/models/glm-5p3-flash",
     "small_model": "fireworks-ai/accounts/fireworks/models/glm-5p3-flash",
     "disabled_providers": ["nebius"],
     "provider": {
       "fireworks-ai": {
         "options": {
           "apiKey": "fw_XXXXX"
         }
       }
     }
   }
   ```

Adjust `AGENTS.md` to fit your project's conventions.

## Usage

No UID/GID setup is needed — the entrypoint reads the workspace owner from the bind mount itself. Run from anywhere with the Makefile targets:

```sh
make run    # Terminal UI (interactive)
make web    # Web UI, then open http://localhost:5174
make build  # Rebuild the image
make stop   # Tear down containers
make clean  # Tear down and remove the venv volume
```

Set `OPENCODE_WEB_PORT` to use a different host port if 5174 is taken:

```sh
OPENCODE_WEB_PORT=8080 make web
```

Or use docker compose directly from the repo root:

```sh
docker compose -f .opencode/docker-compose.yml run --rm opencode
docker compose -f .opencode/docker-compose.yml up opencode-web
```

### How it works

- The container starts as root, and the entrypoint runs `stat` on the bind-mounted `/workspace` to discover the host user's UID/GID (bind mounts preserve ownership).
- It retargets the internal `agent` user to that UID/GID, fixes only the small home dir and the `.venv` volume, then drops privileges — never a recursive `chown` of your project.
- If the workspace is owned by root (CI checkouts, Docker Desktop on macOS), the agent runs as root, which is the only user that can write there.
