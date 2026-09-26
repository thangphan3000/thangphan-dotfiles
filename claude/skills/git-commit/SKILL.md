---
name: git-commit
description: Create Git commits using the Conventional Commits format after inspecting the working tree. Use when the user asks to commit, prepare a commit message, or follow a git commit convention.
---

# Git Conventional Commit

Use this skill when the user wants a commit or commit message that follows Conventional Commits.

## Commit Format

Use this message shape:

```text
<type>(<scope>): <summary>

<body>

<footer>
```

The `scope`, `body`, and `footer` are optional. Keep the summary imperative, present tense, lowercase unless a proper noun requires capitalization, and no trailing period.

Common types:

```text
feat: user-visible feature
fix: bug fix
docs: documentation only
style: formatting only, no behavior change
refactor: code change without feature or bug fix
test: tests only
chore: maintenance, tooling, dependencies
build: build system or dependency change
ci: CI configuration
perf: performance improvement
revert: revert a previous commit
```

Use `!` for breaking changes:

```text
feat(auth)!: require JWT private key env var
```

Add `BREAKING CHANGE:` in the footer when the change breaks existing usage.

## Workflow

Before committing, inspect the repository state:

```bash
git status --short
git diff --stat
git diff
```

If staged changes already exist, inspect them separately:

```bash
git diff --cached --stat
git diff --cached
```

Do not revert, overwrite, or discard user changes unless the user explicitly asks. If unrelated changes are present, leave them unstaged and commit only the files that belong to the requested change.

Prefer staging explicit paths:

```bash
git add path/to/file
```

Avoid broad staging commands like `git add .` when unrelated files may exist.

The user has pre-authorized ordinary staging and committing for this skill. Do
not ask for conversational approval before running explicit `git add` or
`git commit` commands. Run them directly after inspecting the working tree and
choosing the intended paths.

After staging, review what will be committed:

```bash
git diff --cached --stat
git diff --cached
```

Then commit:

```bash
git commit -m "<type>(<scope>): <summary>"
```

For multi-line commits:

```bash
git commit -m "<type>(<scope>): <summary>" -m "<body>" -m "<footer>"
```

When the active session instructs you to append attribution lines (for example a Claude Code attribution reminder), include them in the commit message via an additional `-m` argument or a HEREDOC, keeping them below the body and footer.

## Choosing The Message

Choose the narrowest type that matches the staged diff:

```text
docs: README, guides, comments that do not affect runtime behavior
feat: new endpoint, new user-visible behavior, new supported workflow
fix: correction to broken behavior
refactor: implementation restructuring with same behavior
chore: repository maintenance or config cleanup
```

Use a scope when it improves clarity, such as:

```text
auth
oauth
jwt
jwks
docs
config
```

Examples:

```text
feat(oauth): add client credentials token endpoint
feat(jwt): issue RS256 access tokens
docs(oauth): add endpoint testing commands
fix(jwks): derive public key from configured private key
chore(config): require JWT private key environment variable
```

## Final Response

After committing, report:

```text
commit hash
commit subject
files committed
```

If no commit was created, explain exactly why and what remains.
