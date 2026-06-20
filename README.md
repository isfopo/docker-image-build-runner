# docker-build-remote

Build and publish Docker images from PyPI packages via GitHub Actions.

This template repository automates building Docker images for any Python package on PyPI. It uses build arguments — `TARGET` (the PyPI package name) and `ENTRY` (the module entry point) — making it fully generic and reusable.

Based on [ankisyncserver-docker](https://git.zehka.net/zehka/ankisyncserver-docker).

## How It Works

1. A GitHub Actions workflow triggers daily at 00:00 UTC on a schedule.
2. It fetches the latest version of the target package from the PyPI JSON API.
3. It builds the Docker image using `TARGET` and `ENTRY` as build arguments.
4. It pushes the image to Docker Hub with two tags: `latest` and `v<version>`.

## Setup

### 1. Create a deployment environment

Go to **Settings → Environments** and create an environment. All secrets and variables must be set there. Make sure the `environment` key in the workflow matches the name you choose.

### 2. Add environment secrets

In your environment, add:

| Secret | Description |
|--------|-------------|
| `DOCKER_USER` | Your Docker Hub username |
| `DOCKER_PW` | Your Docker Hub access token or password |

These are used for login and to construct the image tag — the username becomes the namespace in the Docker Hub image name.

### 4. Set environment variables

In your environment, add:

| Variable | Description | Example |
|----------|-------------|---------|
| `TARGET` | PyPI package to install | `anki` |
| `ENTRY` | Python module entry point to run | `syncserver` |

The Dockerfile requires `TARGET` and `ENTRY` as build arguments with no defaults — they must always be provided.

The image name is derived automatically as `<DOCKER_USER>/<TARGET>-<ENTRY>` (e.g. `cryptkiddie2/anki-syncserver`). No separate `IMAGE_NAME` variable is needed.

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

Copy the example files and fill in your values:

```bash
cp .env.example .env
cp .env.secrets.example .env.secrets
```

Edit `.env` with your build variables:
```bash
TARGET=anki
ENTRY=syncserver
```

Edit `.env.secrets` with your Docker Hub credentials:
```bash
DOCKER_USER=your_dockerhub_username
DOCKER_PW=your_dockerhub_token
```

> **Important:** `.env.secrets` is listed in `.gitignore` — never commit your credentials.

### Run

```bash
act --var-file .env --secret-file .env.secrets -j build
```

> **Note:** Since the workflow only runs on a schedule, `act` must target the `build` job directly.

## Building Locally with Docker

```bash
docker build --build-arg TARGET=anki --build-arg ENTRY=syncserver -t anki-sync .
```

Then run:
```bash
docker run -v anki_data:/data anki-sync
```

## Built Images

Images are pushed to Docker Hub automatically on each daily build:

- `<DOCKER_USER>/<TARGET>-<ENTRY>:latest` — always the latest build
- `<DOCKER_USER>/<TARGET>-<ENTRY>:v<version>` — pinned to the PyPI version
