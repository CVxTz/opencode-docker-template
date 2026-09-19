# AGENTS.md

Guidance for AI coding agents working in this repository.

## Python

- Use `pathlib` for all file and path handling — no string path concatenation.
- Use a logger instead of `print` for any diagnostics.
- Follow SOLID principles, but keep the code flat and readable; prefer clarity over abstraction.
- Put all imports at the top of the file.
- Do not add obvious, self-explanatory comments. Write docstrings that explain non-obvious choices and the main logic.
- Use uv and pyproject.toml
- create a script folder where you define an easy to run workflows for the main execution paths. keep them readable. make them runnable from anywhere.
- If torch is a dependency install the one that supports cuda.
- Use python 3.12
- Use a mono repo structure where you have modules folder and each subfolder should have its own pyproject.toml and be installed by the root pyproject.toml
- Use Dependency injection when possible and avoid tight coupling between modules.
- Always update the readme with commands on how to run.
- Never use sys.path.append