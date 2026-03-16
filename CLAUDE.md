# CLAUDE.md

Instructions for Claude when contributing to this repository.

## What This Repo Is

A single-skill repository for `debug-EVM-tx-skills`, a Claude Code skill that helps non-technical users understand why their on-chain transactions failed or why off-chain pre-execution simulations reverted.

## Structure

```
debug-EVM-tx-skills/       # Installable skill package
CONTRIBUTING.md
SECURITY.md
CODE_OF_CONDUCT.md
LICENSE
CLAUDE.md                  # This file
README.md                  # Repository entry point
```

## Rules

- One skill, one purpose.
- `debug-EVM-tx-skills/SKILL.md` is the runtime entrypoint.
- The skill package is self-contained; keep supporting references inside `debug-EVM-tx-skills/references/`.
- Target audience is non-technical users — all output must be in plain language.
- Minimize external tool dependencies — prefer JSON RPC via curl or cast.
- Only use Foundry (cast), Heimdall, and Dedaub as external tools.
- Never expose raw hex data without explanation.
- No secrets, API keys, or personal data.
