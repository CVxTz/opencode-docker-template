# AGENTS.md

Guidance for AI coding agents working in this repository.

## Python

- Use `pathlib` for all file and path handling — no string path concatenation.
- Use a logger instead of `print` for any diagnostics.
- Follow SOLID principles, but keep the code flat and readable; prefer clarity over abstraction.
- Put all imports at the top of the file.
- Do not add obvious, self-explanatory comments. Write docstrings that explain non-obvious choices and the main logic.
