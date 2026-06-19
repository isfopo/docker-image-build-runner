# docker-build-remote

Build and publish Docker images from PyPI packages via GitHub Actions.

This template repository automates building Docker images for any Python package on PyPI. It uses two build arguments — `TARGET` (the PyPI package name) and `ENTRY` (the module entry point) — making it fully generic and reusable.

Based on [ankisyncserver-docker](https://git.zehka.net/zehka/ankisyncserver-docker).

## How It Works

1. A GitHub Actions workflow triggers on push to `main`, on a daily schedule, or manually via `workflow_dispatch`.
2. It fetches the latest version of the target package from the PyPI JSON API.
3. It builds the Docker image using `TARGET` and `ENTRY` as build arguments.
4. It pushes the image to Docker Hub with two tags: `latest` and `v<version>`.

## Setup

### 1. Fork this repository

### 2. Add repository secrets

Go to **Settings → Secrets and variables → Actions** and add to "Environment Secrets":

| Secret | Description |
|--------|-------------|
| `DOCKER_USER` | Your Docker Hub username |
| `DOCKER_PW` | Your Docker Hub access token or password |

The image will be published as `<DOCKER_USER>/<repository-name>`.

### 3. Configure build arguments

The Dockerfile requires two build arguments with no defaults:

| Arg | Description | Example |
|-----|-------------|---------|
| `TARGET` | PyPI package to install | `anki` |
| `ENTRY` | Python module entry point to run | `syncserver` |

These are passed via the workflow when triggering a manual run (see below).

### 4. Set repository variables for scheduled builds

Since scheduled and push-triggered runs don't accept `workflow_dispatch` inputs, you can set repository variables instead:

Go to **Settings → Secrets and variables → Actions → Variables** and add to "Environment Variables":

| Variable | Description | Example |
|----------|-------------|---------|
| `TARGET` | PyPI package name | `anki` |
| `ENTRY` | Module entry point | `syncserver` |

Then update the workflow env section to prefer these variables:

```yaml
env:
  TARGET: ${{ vars.TARGET }}
  ENTRY: ${{ vars.ENTRY }}
```

## Running a Manual Build

1. Go to **Actions → Build and Push Docker Image**.
2. Click **Run workflow**.
3. Fill in `TARGET` (e.g. `anki`) and `ENTRY` (e.g. `syncserver`).
4. Click **Run workflow**.

## Building Locally

```bash
docker build --build-arg TARGET=anki --build-arg ENTRY=syncserver -t anki-sync .
```

Then run:

```bash
docker run -v anki_data:/data anki-sync
```

## Docker Compose Example

See [`docker-compose.yml.example`](docker-compose.yml.example) for a ready-to-use compose file:

```yaml
services:
   ankisync:
      image: <DOCKER_USER>/docker-build-remote:latest
      environment:
         - SYNC_USER1=USERNAME:HASHED_PASSWORD
      volumes:
         - anki_data:/data

volumes:
  anki_data:
    driver: local
```

> Password hashing is enabled by default. Escape every `$` in hashed passwords as `$$` in docker-compose.

## Built Images

Images are pushed to Docker Hub automatically:

- `<DOCKER_USER>/<repo>:latest` — always the latest build
- `<DOCKER_USER>/<repo>:v<version>` — pinned to the PyPI version
