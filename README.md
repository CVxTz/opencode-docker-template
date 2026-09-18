# opencode-docker-template

A Docker-based template for running [opencode](https://opencode.ai) against any project, with the agent container matched to your host user so files created inside the container stay owned by you.

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

2. Adjust `AGENTS.md` to fit your project's conventions.

## Usage

Run from the project root.

Terminal UI (interactive):

```sh
docker compose -f .opencode/docker-compose.yml run --rm opencode
```

Web UI (then open http://localhost:5174):

```sh
docker compose -f .opencode/docker-compose.yml up opencode-web
```

Set `OPENCODE_WEB_PORT` to use a different host port if 5174 is taken.