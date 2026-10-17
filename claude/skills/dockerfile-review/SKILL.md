---
name: dockerfile-review
description: Review a Dockerfile against Docker's official build best practices (https://docs.docker.com/build/building/best-practices/). Audits for multi-stage usage, base image choice, pinning, cache ordering, .dockerignore, apt-get patterns, USER non-root, COPY vs ADD, ENTRYPOINT/CMD form, WORKDIR, LABEL, EXPOSE, ENV secrecy, and more. Use this skill when the user says "review my Dockerfile", "audit this Dockerfile", "check Dockerfile best practices", "/dockerfile-review", or passes a path to a Dockerfile and asks for feedback.
---

# Dockerfile review

Audit a Dockerfile against the official Docker build best practices and report concrete, cited findings.

## How to invoke

- If the user passed a path (e.g. `/dockerfile-review path/to/Dockerfile`), use that.
- Else look for `./Dockerfile` in the current working directory.
- Else look for any `Dockerfile*` under cwd (max depth 3); if more than one, list them and ask which to review.
- Else ask the user for the path.

Also read `.dockerignore` (same directory as the Dockerfile) if present. Its absence is itself a finding.

## Procedure

1. Read the target Dockerfile and `.dockerignore` (if any).
2. Load the rules catalog at `references/best-practices.md` - it is the authority.
3. Walk the Dockerfile top-to-bottom. For each rule in the catalog, check whether the file violates it.
4. Group multiple hits of the same rule into one finding (do not list the same rule twice).
5. Produce the report using the template below.

## Report template

Use this exact Markdown shape:

```
## Dockerfile review: <path>

**Summary:** <N findings - X critical, Y warning, Z nit>

### Findings

#### 1. <short title>  [severity]
- **Rule:** <best-practice name from references/best-practices.md>
- **Where:** `Dockerfile:<line>` - `<offending line, trimmed>`
- **Why it matters:** <one sentence>
- **Fix:**
  ```dockerfile
  <corrected snippet>
  ```

#### 2. ...

### What looks good
- <positive observation 1>
- <positive observation 2>
```

Keep "What looks good" to 2-4 bullets so praise doesn't drown findings. If there are zero findings, say so plainly: `**Summary:** no findings - this Dockerfile follows the official best practices.`

## Severity rubric

- **critical** - security or correctness. Examples: running as root (no `USER`), `ADD` of a remote URL without checksum, `apt-get install` not combined with `apt-get update` in the same `RUN`, missing `set -o pipefail` on a piped `RUN`, secrets baked into `ENV` layers, no `.dockerignore` in a repo that likely has secrets (`.env`, keys).
- **warning** - size, maintainability, cache behavior. Examples: unpinned base tag (`FROM node:latest` or no tag), no multi-stage when compiled artifacts are produced, missing `--no-install-recommends`, missing `rm -rf /var/lib/apt/lists/*`, shell-form `CMD`/`ENTRYPOINT`, `COPY . .` before dependency files (busts cache), using `ADD` where `COPY` would do.
- **nit** - style. Examples: unsorted multi-line package list, `RUN cd foo && ...` instead of `WORKDIR`, missing `LABEL` metadata, missing `EXPOSE` for a service, relative `WORKDIR`.

## Rules against noise

- Do not invent rules outside what is in `references/best-practices.md`. If something feels wrong but isn't in the catalog, skip it.
- Do not flag more than one instance of the same rule - fold them into one finding and reference each line.
- Do not rewrite the whole Dockerfile. Each finding's **Fix** block shows only the lines that change.
- Do not add preamble ("Here is the review...") or trailing summary. Report, then stop.
- If the Dockerfile is clean, say so - no padding with fake nits.
