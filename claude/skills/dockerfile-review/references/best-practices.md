# Dockerfile best practices catalog

Source: https://docs.docker.com/build/building/best-practices/

Each rule: name, severity hint, detection heuristic, fix pattern. The review skill treats this file as authoritative - add rules here, not in SKILL.md.

---

## Image construction

### Use multi-stage builds
**Severity:** warning
**Detect:** exactly one `FROM`, and the Dockerfile compiles/builds something (presence of `go build`, `npm run build`, `mvn package`, `pip install` of build-only deps, gcc/make, etc.) with those build tools still in the final image.
**Fix pattern:**
```dockerfile
FROM golang:1.23 AS build
WORKDIR /src
COPY . .
RUN go build -o /out/app ./cmd/app

FROM gcr.io/distroless/base-debian12
COPY --from=build /out/app /app
ENTRYPOINT ["/app"]
```

### Create reusable stages
**Severity:** nit
**Detect:** two or more derived images (same project) repeat the same setup (`apt-get`, `WORKDIR`, env) in each stage.
**Fix pattern:** define `FROM <img> AS base` with the shared setup, then `FROM base AS api` / `FROM base AS worker`.

### Choose the right base image
**Severity:** warning
**Detect:** base image is a large general-purpose distro (`ubuntu`, `debian`) in the final stage when a slim/alpine/distroless would do; or an unverified publisher.
**Fix pattern:** prefer `-slim`, `alpine`, or `distroless` for the final stage; keep the heavier image only for the build stage.

---

## Freshness and reproducibility

### Rebuild images often
**Severity:** informational (not a Dockerfile finding - mention once if the project has no CI rebuild).
**Detect:** no CI workflow that builds the image on a schedule or on dependency updates.
**Fix pattern:** `docker build --pull --no-cache -t img .` in CI, scheduled weekly.

### Pin base image versions
**Severity:** warning (critical if production image has `:latest`)
**Detect:** `FROM foo` with no tag, `FROM foo:latest`, or a floating tag like `FROM node:20` (no minor/patch, no digest).
**Fix pattern:**
```dockerfile
FROM node:20.11.1-slim@sha256:<digest>
```
Pin by digest for strongest guarantee; otherwise pin to a full `MAJOR.MINOR.PATCH` tag.

---

## Lean, focused images

### Exclude files with .dockerignore
**Severity:** critical if the repo likely contains secrets (`.env`, `.git`, `*.pem`, `id_rsa`); warning otherwise.
**Detect:** no `.dockerignore` next to the Dockerfile, or `.dockerignore` doesn't exclude `.git`, `.env`, `node_modules`, `__pycache__`, `.vscode`, etc.
**Fix pattern:**
```
.git
.env
.env.*
node_modules
__pycache__
*.pem
.vscode
```

### Create ephemeral containers
**Severity:** nit
**Detect:** heavy per-start setup scripts, long `ENTRYPOINT` wrappers that mutate state, container state assumed between restarts.
**Fix pattern:** move setup into the image build; keep runtime startup to launching the process.

### Don't install unnecessary packages
**Severity:** warning
**Detect:** `apt-get install` of `vim`, `curl` (if not used at runtime), `git` (if build-only but kept in final stage), `build-essential` in the final image.
**Fix pattern:** install build deps only in the build stage; use `--no-install-recommends`; strip editors/debug tools from runtime image.

### Decouple applications
**Severity:** nit
**Detect:** one image runs app + database, or app + cache, or multiple unrelated services (via supervisord, s6, custom scripts).
**Fix pattern:** one concern per container; use compose for multi-service local setups.

---

## Build efficiency

### Sort multi-line arguments
**Severity:** nit
**Detect:** multi-line `apt-get install` / `pip install` / `apk add` where the package list is not alphabetized, or backslashes without a leading space.
**Fix pattern:**
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      jq \
    && rm -rf /var/lib/apt/lists/*
```

### Leverage build cache
**Severity:** warning
**Detect:** `COPY . .` (or `COPY . /app`) appears before dependency installation. This busts the cache on every source change.
**Fix pattern:**
```dockerfile
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
```
Same for `requirements.txt`, `go.mod`/`go.sum`, `Gemfile`, `pom.xml`, etc.

### Build and test images in CI
**Severity:** informational
**Detect:** no CI workflow builds the image.
**Fix pattern:** GitHub Actions / GitLab CI job that runs `docker build` on every PR, tags, and runs smoke tests.

---

## Instruction-level rules

### FROM: current official image
**Severity:** warning
**Detect:** unofficial/random registry image used as base without reason.
**Fix pattern:** prefer Docker Official Images, Verified Publisher, or Docker-Sponsored Open Source.

### LABEL: metadata
**Severity:** nit
**Detect:** no `LABEL` for maintainer / source / version / license.
**Fix pattern:**
```dockerfile
LABEL org.opencontainers.image.source="https://github.com/me/app"
LABEL org.opencontainers.image.licenses="MIT"
```

### RUN: readability (long commands)
**Severity:** nit
**Detect:** long `RUN` lines with `&&` and no line breaks.
**Fix pattern:** split with `\` at the end of each logical step, or use a here-document (`RUN <<EOF ... EOF`).

### RUN apt-get: update + install in one layer
**Severity:** critical
**Detect:** `apt-get update` in one `RUN` and `apt-get install` in a later `RUN` (stale cache); OR `apt-get install` without `rm -rf /var/lib/apt/lists/*` cleanup; OR missing `--no-install-recommends`.
**Fix pattern:**
```dockerfile
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
 && rm -rf /var/lib/apt/lists/*
```

### RUN with pipes: set -o pipefail
**Severity:** critical
**Detect:** `RUN ... | ...` without a leading `set -o pipefail &&`. The default shell (`/bin/sh` = `dash` on Debian) silently swallows mid-pipeline failures.
**Fix pattern:**
```dockerfile
RUN set -o pipefail && wget -O- https://example.com/x.tar.gz | tar -xzC /opt
```
Or switch shell: `SHELL ["/bin/bash", "-o", "pipefail", "-c"]`.

### CMD: exec form
**Severity:** warning
**Detect:** `CMD foo bar` (shell form) instead of `CMD ["foo", "bar"]` (exec form). Shell form forks `/bin/sh -c`, which swallows signals.
**Fix pattern:** `CMD ["node", "server.js"]`.

### EXPOSE: declare the port
**Severity:** nit
**Detect:** service image with no `EXPOSE`.
**Fix pattern:** `EXPOSE 8080`.

### ENV: secrets in a single RUN
**Severity:** critical
**Detect:** `ENV API_KEY=...` with a real secret, or `ENV` of a credential that persists in a layer.
**Fix pattern:** pass secrets at runtime (`--secret`, env from orchestrator) OR use within one `RUN`:
```dockerfile
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc npm ci
```

### ADD vs COPY
**Severity:** warning (critical if `ADD <url>` without checksum)
**Detect:** `ADD` used for local files (should be `COPY`), or `ADD <url>` without a `--checksum=sha256:...`.
**Fix pattern:**
- Local files: `COPY src/ /app/`
- Remote: `ADD --checksum=sha256:<hex> https://example.com/x.tar.gz /opt/`

### ENTRYPOINT + exec in wrapper scripts
**Severity:** warning
**Detect:** entrypoint shell script runs the app as a child process (not with `exec`), so the app isn't PID 1 and signals aren't forwarded.
**Fix pattern:** last line of the entrypoint script: `exec "$@"` (or `exec /app/server`).

### VOLUME: declare mutable paths
**Severity:** nit
**Detect:** database/stateful image with no `VOLUME` for its data directory.
**Fix pattern:** `VOLUME ["/var/lib/postgresql/data"]`.

### USER: non-root
**Severity:** critical
**Detect:** no `USER` directive, so the container runs as root; or `USER root` at the end.
**Fix pattern:**
```dockerfile
RUN groupadd --system --gid 1001 app \
 && useradd  --system --uid 1001 --gid app app
USER app
```
Or use a numeric UID: `USER 1001:1001`.

### WORKDIR: absolute paths
**Severity:** nit
**Detect:** `RUN cd /app && ...` instead of `WORKDIR /app`; or relative `WORKDIR app`.
**Fix pattern:** `WORKDIR /app`.

### ONBUILD: careful with child builds
**Severity:** nit
**Detect:** `ONBUILD ADD` / `ONBUILD COPY` of resources that a child build may not have.
**Fix pattern:** keep `ONBUILD` images on a separate tag, document the required files, prefer explicit instructions in the child Dockerfile.
