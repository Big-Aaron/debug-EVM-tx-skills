# CLAUDE.md

Instructions for Claude when contributing to this skill.

## What This Skill Is

An EVM transaction failure debugger. It helps non-technical users understand why their on-chain transactions failed or why off-chain pre-execution simulations reverted.

## Structure

```
debug-EVM-tx-skills/
├── CLAUDE.md              # This file
├── SKILL.md               # Main orchestration & analysis logic
├── VERSION                # Semantic version
├── README.md              # User documentation
└── references/
    ├── common-errors.md   # Error signatures & revert reason database
    ├── tools-guide.md     # cast, heimdall, dedaub usage reference
    └── report-formatting.md  # Output format for non-technical users
```

## Rules

- Target audience is non-technical users — all output must be in plain language.
- Minimize external tool dependencies — prefer JSON RPC via curl or cast.
- Only use Foundry (cast), Heimdall, and Dedaub as external tools.
- Never expose raw hex data without explanation.
- No secrets, API keys, or personal data.
