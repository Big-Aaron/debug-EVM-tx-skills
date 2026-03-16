---
name: tools-guide
description: Reference for using Foundry (cast), Heimdall, and Dedaub to debug EVM transactions. Covers command syntax, common patterns, and output interpretation.
---

# Tools Reference

## 1. Foundry — cast

`cast` is the primary tool for interacting with EVM chains. It wraps JSON RPC calls with a convenient CLI.

### Transaction Inspection

```bash
# Fetch transaction details (returns JSON)
cast tx <TX_HASH> --rpc-url <RPC_URL> --json

# Fetch transaction receipt (returns JSON)
cast receipt <TX_HASH> --rpc-url <RPC_URL> --json

# Key fields in tx JSON:
# - hash, from, to, value, input (calldata), gas, gasPrice, nonce, blockNumber
# - type (0=legacy, 2=EIP-1559), maxFeePerGas, maxPriorityFeePerGas

# Key fields in receipt JSON:
# - status (0x0=failed, 0x1=success), gasUsed, effectiveGasPrice
# - logs (event logs), contractAddress (if contract creation)
```

### Transaction Replay & Simulation

```bash
# Replay a failed tx to get revert reason (use the same block)
cast call <TO> <CALLDATA> \
  --from <FROM> \
  --value <VALUE> \
  --gas-limit <GAS_LIMIT> \
  --rpc-url <RPC_URL> \
  --block <BLOCK_NUMBER> \
  2>&1

# Simulate a new call
cast call <TO> "functionName(type1,type2)(returnType)" <arg1> <arg2> \
  --from <FROM> \
  --rpc-url <RPC_URL> \
  2>&1

# Example: check ERC20 balance
cast call <TOKEN> "balanceOf(address)(uint256)" <ADDRESS> --rpc-url <RPC_URL>

# Example: check ERC20 allowance
cast call <TOKEN> "allowance(address,address)(uint256)" <OWNER> <SPENDER> --rpc-url <RPC_URL>
```

### Full Execution Trace

```bash
# Run a transaction with full trace (requires archive node)
cast run <TX_HASH> --rpc-url <RPC_URL> 2>&1

# This shows:
# - Every internal call (CALL, DELEGATECALL, STATICCALL, CREATE)
# - Storage reads/writes (SLOAD, SSTORE)
# - The exact point where the revert occurs
# - Gas usage per operation

# Note: Not all RPC providers support debug_traceTransaction
# Providers that support it: Alchemy, QuickNode, Infura (paid plans)
# Public RPCs usually do NOT support it
```

### Calldata Decoding

```bash
# Decode using 4byte.directory (online lookup)
cast 4byte-decode <CALLDATA>

# Decode a function selector
cast 4byte <SELECTOR>
# Example: cast 4byte 0xa9059cbb → "transfer(address,uint256)"

# Decode error data
cast 4byte <ERROR_SELECTOR>

# ABI-decode specific types
cast abi-decode "functionName(type1,type2)" <DATA>
cast abi-decode "Error(string)" <DATA_WITHOUT_SELECTOR>
cast abi-decode "Panic(uint256)" <DATA_WITHOUT_SELECTOR>

# Get contract interface from Etherscan (verified contracts only)
cast interface <CONTRACT_ADDRESS> --chain <CHAIN_NAME>
# CHAIN_NAME: mainnet, polygon, arbitrum, optimism, base, bsc, etc.
```

### Balance & State Queries

```bash
# ETH balance (in wei)
cast balance <ADDRESS> --rpc-url <RPC_URL>
cast balance <ADDRESS> --rpc-url <RPC_URL> --block <BLOCK_NUMBER>

# ETH balance (in ether)
cast balance <ADDRESS> --rpc-url <RPC_URL> --ether

# Contract code (to check if address is a contract)
cast code <ADDRESS> --rpc-url <RPC_URL>
# Returns "0x" if not a contract

# Storage slot read
cast storage <ADDRESS> <SLOT> --rpc-url <RPC_URL>
```

### Unit Conversions

```bash
# Wei to Ether
cast from-wei <WEI_AMOUNT>
cast from-wei <WEI_AMOUNT> gwei  # to gwei

# Ether to Wei
cast to-wei <ETHER_AMOUNT>

# Hex to Decimal
cast to-dec <HEX>

# Decimal to Hex
cast to-hex <DECIMAL>

# Parse ERC20 amount with decimals
cast from-wei <AMOUNT> --unit <DECIMALS>
# Example for USDC (6 decimals): cast to-unit <AMOUNT> 6
```

### Block Queries

```bash
# Get latest block number
cast block-number --rpc-url <RPC_URL>

# Get block timestamp
cast block <BLOCK_NUMBER> --rpc-url <RPC_URL> --json | jq .timestamp
cast age <BLOCK_NUMBER> --rpc-url <RPC_URL>
```

## 2. Heimdall

Heimdall is used for decoding calldata and decompiling bytecode when contract source is not available.

### Calldata Decoding

```bash
# Decode calldata with contract context (fetches ABI from chain)
heimdall decode <CALLDATA> --rpc-url <RPC_URL> --target <CONTRACT_ADDRESS>

# Decode calldata without contract context (signature lookup only)
heimdall decode <CALLDATA>

# Output includes:
# - Function name (if resolvable)
# - Parameter names and types
# - Decoded values
```

### Bytecode Decompilation

```bash
# Decompile a contract from chain
heimdall decompile <CONTRACT_ADDRESS> --rpc-url <RPC_URL>

# Decompile from local bytecode file
heimdall decompile <BYTECODE_FILE>

# Output: Solidity-like pseudocode showing contract logic
# Useful for understanding what unverified contracts do
```

### Disassembly

```bash
# Disassemble bytecode to opcodes
heimdall disassemble <CONTRACT_ADDRESS> --rpc-url <RPC_URL>
```

## 3. Dedaub

Dedaub provides high-quality contract decompilation through a web interface.

### Usage Flow

1. Get the contract bytecode:
```bash
cast code <CONTRACT_ADDRESS> --rpc-url <RPC_URL>
```

2. Go to https://app.dedaub.com/decompile

3. Paste the bytecode (without `0x` prefix or with, both work)

4. Click "Decompile" — Dedaub will produce:
   - Solidity-like source code
   - Function signatures
   - Storage layout
   - Control flow graph

### When to Use Dedaub vs Heimdall

- **Heimdall**: Fast, CLI-based, good for quick decoding and simple contracts
- **Dedaub**: Higher quality decompilation, better for complex contracts with many functions, provides visual control flow. Use when Heimdall output is hard to read.

## 4. Raw JSON RPC (via curl)

When cast is not available or for specific RPC calls:

```bash
# Generic RPC call pattern
curl -s -X POST <RPC_URL> \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"<METHOD>","params":[<PARAMS>],"id":1}' | jq

# eth_call — simulate transaction
curl -s -X POST <RPC_URL> \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "method":"eth_call",
    "params":[{
      "from":"<FROM>",
      "to":"<TO>",
      "data":"<CALLDATA>",
      "value":"<VALUE_HEX>",
      "gas":"<GAS_HEX>"
    }, "<BLOCK_HEX>"],
    "id":1
  }' | jq

# eth_getTransactionByHash
curl -s -X POST <RPC_URL> \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["<TX_HASH>"],"id":1}' | jq

# eth_getTransactionReceipt
curl -s -X POST <RPC_URL> \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["<TX_HASH>"],"id":1}' | jq

# eth_getCode — check if address is contract
curl -s -X POST <RPC_URL> \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getCode","params":["<ADDRESS>","latest"],"id":1}' | jq

# debug_traceTransaction — full trace (archive node required)
curl -s -X POST <RPC_URL> \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "method":"debug_traceTransaction",
    "params":["<TX_HASH>", {"tracer":"callTracer"}],
    "id":1
  }' | jq
```

## 5. Common Debugging Patterns

### Pattern: "Why did my swap fail?"
```bash
# 1. Get tx details
cast tx <HASH> --rpc-url <RPC> --json
# 2. Decode the swap calldata
cast 4byte-decode <CALLDATA>
# 3. Replay to get revert reason
cast call <ROUTER> <CALLDATA> --from <USER> --value <VALUE> --block <BLOCK> --rpc-url <RPC> 2>&1
# 4. Check token balance
cast call <TOKEN> "balanceOf(address)(uint256)" <USER> --rpc-url <RPC> --block <BLOCK>
# 5. Check token allowance
cast call <TOKEN> "allowance(address,address)(uint256)" <USER> <ROUTER> --rpc-url <RPC> --block <BLOCK>
```

### Pattern: "Why did my token transfer fail?"
```bash
# 1. Check sender balance
cast call <TOKEN> "balanceOf(address)(uint256)" <SENDER> --rpc-url <RPC> --block <BLOCK>
# 2. Check if token is paused
cast call <TOKEN> "paused()(bool)" --rpc-url <RPC> --block <BLOCK>
# 3. Check for blacklist
cast call <TOKEN> "isBlacklisted(address)(bool)" <SENDER> --rpc-url <RPC> --block <BLOCK> 2>/dev/null
```

### Pattern: "Why did my DeFi operation fail?"
```bash
# 1. Replay for revert reason
cast call <PROTOCOL> <CALLDATA> --from <USER> --block <BLOCK> --rpc-url <RPC> 2>&1
# 2. Check health factor (Aave)
cast call <POOL> "getUserAccountData(address)(uint256,uint256,uint256,uint256,uint256,uint256)" <USER> --rpc-url <RPC> --block <BLOCK>
# 3. Full trace if revert reason unclear
cast run <HASH> --rpc-url <RPC> 2>&1
```
