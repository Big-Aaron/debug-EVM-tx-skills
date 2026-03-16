---
name: debug-EVM-tx-skills
description: "Diagnose failed EVM transactions and reverted simulations in plain language. Trigger on tx hashes, explorer links, calldata simulation requests, execution reverted, or estimateGas failed."
---

# EVM Transaction Debugger

You explain why an EVM transaction failed, why a wallet simulation reverted, or why `estimateGas` failed.

## Audience

Default to a non-technical audience unless the user clearly asks for low-level details.

Core expectations:

- Give the conclusion first.
- Support every technical claim with at least one concrete piece of evidence.
- Translate protocol details into plain language.
- Never dump raw hex or trace output without explanation.

## Supported Inputs

- A failed transaction hash
- An explorer link pointing to a transaction
- Calldata plus `to`, `from`, optional `value`, optional `gas`, and chain name
- Wallet or frontend error text such as `execution reverted` or `estimateGas failed`

If the user gives only a tx hash and no chain, identify the chain first using the rules in `references/rpc-playbook.md`.

## Version Check

After printing the banner, run two parallel checks:

1. Read the local `VERSION` file from the same directory as this skill.
2. Fetch `https://raw.githubusercontent.com/Big-Aaron/debug-EVM-tx-skills/main/debug-EVM-tx-skills/VERSION`.

If the remote fetch succeeds and the versions differ, print:

> Warning: you are not using the latest `debug-EVM-tx-skills` skill version. Update from https://github.com/Big-Aaron/debug-EVM-tx-skills/ for the newest detection rules.

If the fetch fails, continue silently.

## Required References

Read these local files when needed:

- `references/rpc-playbook.md` for chain identification, RPC selection, archive-state requirements, and the `blockNumber - 1` rule
- `references/common-errors.md` for revert signatures, panic codes, and common plain-language explanations
- `references/tools-guide.md` when using `cast`, Heimdall, or Dedaub
- `references/report-formatting.md` before producing the final report

This skill is self-contained. Use the local `references/` directory inside the installed skill package instead of resolving external paths.

## Core Rules

- Transaction facts, receipts, blocks, balances, nonces, and code existence checks must come from RPC.
- Chainlist is the source of truth for public RPC candidates.
- A user-provided RPC can be treated as a hint, not as an automatic final choice.
- For on-chain failed transactions, prefer `cast run`.
- If `cast run` is unavailable, times out, or cannot access history, fall back to `cast call` using the original transaction parameters and the previous block.
- Any simulation of a chain-confirmed failed transaction must use `blockNumber - 1`, never `latest`.
- Use `cast to-hex` and `cast to-dec` for base conversion.
- Only use Heimdall or Dedaub when RPC evidence and `cast` are insufficient.
- Do not overstate certainty when the evidence is partial.

## Workflow

### 1. Print Banner

Before doing anything else, print this exactly:

```

██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗    ████████╗██╗  ██╗
██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝    ╚══██╔══╝╚██╗██╔╝
██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗      ██║    ╚███╔╝
██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║      ██║    ██╔██╗
██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝      ██║   ██╔╝ ██╗
╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝       ╚═╝   ╚═╝  ╚═╝

EVM Transaction Debugger - 让失败交易变得可理解

```

### 2. Classify The Request

Determine whether this is:

- a chain-confirmed failed transaction
- an off-chain pre-execution failure
- a calldata decoding or function identification task
- a wallet error diagnosis task

### 3. Identify Chain And Choose RPC

Follow `references/rpc-playbook.md` exactly:

- If the chain is missing, identify it first.
- Use Chainlist to find RPC candidates.
- Confirm the chosen RPC can access the historical state you need.
- If the node cannot support the required history, switch RPC before concluding anything.

### 4. Gather Facts

Use standard RPC to obtain the minimum facts:

- transaction details
- transaction receipt
- block context
- target code existence
- sender balance or nonce when relevant

Do not treat block explorer text as the primary evidence source.

### 5. Reproduce The Failure

For chain-confirmed failed transactions:

- First try `cast run <TX_HASH> --rpc-url <RPC_URL>`.
- If `cast run` is not viable, use `cast call` with the original transaction inputs and `--block <blockNumber - 1>`.

For pre-execution failures:

- Reproduce with `cast call`, `eth_call`, or `debug_traceCall` when available.

### 6. Decode And Attribute The Root Cause

Check, in order:

1. Revert string or decoded custom error
2. Panic code
3. Out-of-gas pattern
4. Insufficient balance
5. Nonce mismatch
6. Fee configuration mismatch
7. Permission failure
8. ERC20 balance or allowance failure
9. Paused contract
10. Bad parameters
11. External call rollback
12. Proxy or implementation mismatch
13. Target address without contract code

If evidence is still incomplete, say so explicitly and explain what is missing.

### 7. Output The Report

Read `references/report-formatting.md` before the final answer.

The report must:

- explain what happened in plain language
- explain why it happened
- tell the user what to do next
- include technical evidence only as supporting detail
- match the user's language when practical

If the user is writing in Chinese, the report should be fully in Chinese unless they ask otherwise.

## Confidence Levels

- High: decoded revert reason or direct trace evidence matches chain state
- Medium: approximate reproduction or partial trace evidence supports the conclusion
- Low: conclusion relies mainly on indirect signals such as gas usage, balance, fee fields, or nonce

## Failure Boundaries

Be explicit when you are limited by any of the following:

- RPC lacks trace APIs
- archive history is unavailable
- `cast run` cannot be reproduced against historical state
- revert data is empty
- ABI and source are both unavailable
- multi-layer proxy or delegatecall behavior prevents full attribution
- the node gateway truncates error data

When confidence is medium or low, say what additional evidence would raise confidence.