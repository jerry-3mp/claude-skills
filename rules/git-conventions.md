# Git Conventions

## Why These Rules?

These conventions ensure:
- **Consistent commit history** — Searchable, readable, and maintainable
- **Automated tooling compatibility** — Conventional Commits enable changelog generation and semantic versioning
- **Clear intent** — Scope + description clarify what changed and why
- **Team consistency** — All contributors follow the same patterns

**Relationship to CLAUDE.md**: This rules file takes precedence. When both files define overlapping guidance, apply this file's standards first.

## Force Push Policy

**Force push is FORBIDDEN.** Never execute these commands:
- `git push --force`
- `git push --force-with-lease`
- `git push -f`

You may perform any local operations (rebase, filter-branch, amend, reset, etc.). The user will verify the local state and execute force push manually if needed.

## Commit Message Format

Follow **Conventional Commits 1.0.0** format:

```
<type>[optional scope]: <description>
```

### Requirements

- **Single-line only**: No multi-line descriptions or bullet points
- **Maximum 72 characters**: Use `/charcount` skill to verify length before committing
- **No trailers**: No `Co-Authored-By` or other multi-line footers

### Commit Types

- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code refactoring without feature/fix
- `perf` — Performance improvements
- `docs` — Documentation changes
- `test` — Test additions or modifications
- `style` — Code formatting, whitespace, semicolons (no logic change)
- `ci` — CI/CD pipeline, Actions, build scripts
- `chore` — Maintenance, dependencies, build system

### Scope Naming Convention

Scopes are optional but recommended. Use lowercase, hyphenated names matching the feature/component being changed:

- **Component refactoring**: Use the component name (`modals`, `dropdowns`, `charts`)
- **Feature areas**: Use the domain name (`campaigns`, `auth`, `analytics`)
- **Module/service**: Use the module name (`email`, `integrations`, `webhooks`)

### Length Verification

Use `/charcount` skill to verify message is under 72 characters:

```
/charcount refactor(analytics): align DashoardCard to rulebook
```

### Good Examples

```
feat(campaigns): add automated recipient assignment by group
fix(auth): handle expired SAML sessions gracefully
refactor(modals): align ModalComponent to rulebook
perf(tables): optimize row rendering with lazy loading
docs(api): update webhook payload examples
test(email): add parser coverage for quoted-printable
style(components): normalize indentation in previews
ci(actions): add parallel test execution workflow
chore(deps): upgrade Rails to 8.0.1
```

### Bad Examples

```
update stuff                                         # Too vague, no type/scope
refactor(modals): align ModalComponent rulebook per §1.2  # Over 72 chars
feat: add feature                                    # No scope, vague description
refactor(modals): align ModalComponent to rulebook
  - Update class name                               # Multi-line not allowed
```

## Safe Operations

Local operations (always allowed):
- `git add`, `git commit`, `git mv`
- `git status`, `git diff`, `git log`
- `git branch`, `git checkout`
- `git rebase`, `git filter-branch`, `git commit --amend`
- `git reset`

Remote operations:
- `git push` (without force flags) — allowed
- `git pull`, `git fetch` — allowed
- `git push --force*` — FORBIDDEN