# docker-build-remote

Build and publish Docker images from PyPI packages via GitHub Actions.

This template repository automates building Docker images for any Python package on PyPI. It uses build arguments — `TARGET` (the PyPI package name) and `ENTRY` (the module entry point) — making it fully generic and reusable.

Based on [ankisyncserver-docker](https://git.zehka.net/zehka/ankisyncserver-docker).

## How It Works

1. A GitHub Actions workflow triggers on push to `main`, on a daily schedule, or manually via `workflow_dispatch`.
2. It fetches the latest version of the target package from the PyPI JSON API.
3. It builds the Docker image using `TARGET` and `ENTRY` as build arguments.
4. It pushes the image to Docker Hub with two tags: `latest` and `v<version>`.

## Setup

### 1. Fork this repository

### 2. Add repository secrets

Go to **Settings → Secrets and variables → Actions → Environment secrets** and add:

| Secret | Description |
|--------|-------------|
| `DOCKER_USER` | Your Docker Hub username |
| `DOCKER_PW` | Your Docker Hub access token or password |

These are only used for login — they don't appear in image tags.

### 3. Set repository variables

Go to **Settings → Secrets and variables → Actions → Environment variables** and add:

| Variable | Description | Example |
|----------|-------------|---------|
| `TARGET` | PyPI package to install | `anki` |
| `ENTRY` | Python module entry point to run | `syncserver` |
| `IMAGE_NAME` | Full Docker image name (user/repo) | `cryptkiddie2/docker-build-remote` |

The Dockerfile requires `TARGET` and `ENTRY` as build arguments with no defaults — they must always be provided.

`IMAGE_NAME` is used for the Docker Hub tags (e.g. `cryptkiddie2/docker-build-remote:latest`). Using a variable instead of a secret avoids masking issues in logs and works correctly with local tools like `act`.

### 4. (Optional) Override via manual run

When triggering **Run workflow** manually, you can override `TARGET` and `ENTRY` via the input fields. `IMAGE_NAME` always comes from the repository variable.

## Local Testing with `act`

[`act`](https://github.com/nektos/act) runs GitHub Actions locally using Docker.

### Install `act`

**macOS (Homebrew):**
```bash
brew install act
```

**Linux:**
```bash
curl -sL https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

**Windows (Scoop):**
```powershell
scoop install act
```

See the [act installation docs](https://github.com/nektos/act#installation) for other methods.

> **Apple Silicon note:** If you're on an M-series Mac, run with `--container-architecture linux/amd64` to avoid compatibility issues.

### Configure local environment

Create a `.env` file with your variables:
```bash
TARGET=anki
ENTRY=syncserver
IMAGE_NAME=youruser/yourimage
```

Create a `.env.secrets` file with your Docker Hub credentials:
```bash
DOCKER_USER=your_dockerhub_username
DOCKER_PW=your_dockerhub_token
```

> **Important:** `.env.secrets` is listed in `.gitignore` — never commit your credentials.

### Run

```bash
act --var-file .env --secret-file .env.secrets push
```

## Building Locally with Docker

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
      image: cryptkiddie2/docker-build-remote:latest
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

- `<IMAGE_NAME>:latest` — always the latest build
- `<IMAGE_NAME>:v<version>` — pinned to the PyPI version