---
name: common-errors
description: Database of common EVM revert reasons, panic codes, custom errors, and their plain-language explanations. Used to quickly identify root causes of transaction failures.
---

# Common EVM Error Database

## 1. Solidity Panic Codes (selector: 0x4e487b71)

| Code | Hex | Meaning | Plain Language |
|------|-----|---------|----------------|
| 0x00 | 0x00 | Generic compiler panic | 合约内部出现了异常错误 |
| 0x01 | 0x01 | Assert failure | 合约的内部检查失败了，通常是代码 bug |
| 0x11 | 0x11 | Arithmetic overflow/underflow | 数学计算溢出 — 数字太大或变成了负数 |
| 0x12 | 0x12 | Division by zero | 除以零错误 — 计算中出现了除以零 |
| 0x21 | 0x21 | Enum conversion error | 尝试使用了一个无效的选项值 |
| 0x22 | 0x22 | Storage encoding error | 合约存储数据编码错误 |
| 0x31 | 0x31 | Pop from empty array | 尝试从空列表中取出元素 |
| 0x32 | 0x32 | Array index out of bounds | 数组越界 — 尝试访问不存在的位置 |
| 0x41 | 0x41 | Too much memory allocated | 内存分配过多 — 操作太复杂 |
| 0x51 | 0x51 | Zero-initialized function pointer | 调用了一个未初始化的内部函数 |

## 2. Standard Revert Strings (selector: 0x08c379a0)

### OpenZeppelin ERC20

| Revert String | Plain Language | Suggestion |
|---------------|----------------|------------|
| `ERC20: transfer amount exceeds balance` | 你的代币余额不足，无法完成转账 | 检查你的代币余额，确保有足够的代币 |
| `ERC20: insufficient allowance` | 你没有授权足够的代币给这个合约使用 | 需要先授权（Approve）合约使用你的代币 |
| `ERC20: transfer to the zero address` | 不能将代币发送到空地址 | 检查接收地址是否正确 |
| `ERC20: transfer from the zero address` | 不能从空地址转出代币 | 内部错误，联系项目方 |
| `ERC20: approve to the zero address` | 不能授权给空地址 | 检查授权地址是否正确 |
| `ERC20: burn amount exceeds balance` | 销毁数量超过余额 | 你没有足够的代币可以销毁 |
| `ERC20: decreased allowance below zero` | 授权额度不能减少到零以下 | 当前授权额度已经很低了 |

### OpenZeppelin Access Control

| Revert String | Plain Language | Suggestion |
|---------------|----------------|------------|
| `Ownable: caller is not the owner` | 你不是合约的管理员，无法执行此操作 | 此功能仅限合约管理员使用 |
| `Ownable: new owner is the zero address` | 新的管理员地址无效 | 需要提供有效的地址 |
| `AccessControl: account ... is missing role ...` | 你的账户没有执行此操作的权限 | 需要相应的角色权限才能操作 |

### OpenZeppelin Security

| Revert String | Plain Language | Suggestion |
|---------------|----------------|------------|
| `Pausable: paused` | 合约当前已暂停，无法进行任何操作 | 等待项目方恢复合约后再试 |
| `Pausable: not paused` | 合约未暂停，此操作需要合约处于暂停状态 | 联系项目方 |
| `ReentrancyGuard: reentrant call` | 检测到重入调用，交易被阻止 | 通常是合约安全机制触发，不要在回调中再次调用同一合约 |

### OpenZeppelin ERC721/1155

| Revert String | Plain Language | Suggestion |
|---------------|----------------|------------|
| `ERC721: transfer caller is not owner nor approved` | 你不是这个 NFT 的拥有者，也没有被授权转移它 | 确认你拥有这个 NFT 并且没有授权给其他人 |
| `ERC721: token already minted` | 这个 NFT 已经被铸造过了 | 尝试铸造其他 ID |
| `ERC721: invalid token ID` | 这个 NFT ID 不存在 | 确认 NFT ID 是否正确 |
| `ERC1155: insufficient balance for transfer` | NFT/代币余额不足 | 检查你持有的数量 |

## 3. OpenZeppelin v5 Custom Errors (EIP-6093)

| Error Signature | Selector | Plain Language |
|-----------------|----------|----------------|
| `ERC20InsufficientBalance(address,uint256,uint256)` | 0xe450d38c | 代币余额不足 — 你有 X 但需要 Y |
| `ERC20InsufficientAllowance(address,uint256,uint256)` | 0xfb8f41b2 | 授权额度不足 — 已授权 X 但需要 Y |
| `ERC20InvalidSender(address)` | 0x96c6fd1e | 发送方地址无效 |
| `ERC20InvalidReceiver(address)` | 0xec442f05 | 接收方地址无效 |
| `ERC20InvalidApprover(address)` | 0xe602df05 | 授权方地址无效 |
| `ERC20InvalidSpender(address)` | 0x94280d62 | 被授权方地址无效 |
| `OwnableUnauthorizedAccount(address)` | 0x118cdaa7 | 你的账户没有管理员权限 |
| `OwnableInvalidOwner(address)` | 0x1e4fbdf7 | 提供的管理员地址无效 |
| `EnforcedPause()` | 0xd93c0665 | 合约已暂停 |
| `ExpectedPause()` | 0x8dfc202b | 合约未暂停，但操作需要暂停状态 |
| `FailedInnerCall()` | 0x1425ea42 | 内部合约调用失败 |
| `AddressInsufficientBalance(address)` | 0xcd786059 | ETH 余额不足 |
| `AddressEmptyCode(address)` | 0x9996b315 | 目标地址不是合约 |
| `MathOverflowedMulDiv()` | 0x227bc153 | 数学乘除运算溢出 |
| `SafeERC20FailedOperation(address)` | 0x5274afe7 | 代币操作失败（转账/授权/等） |

## 4. Uniswap Errors

### Uniswap V2
| Revert String | Plain Language | Suggestion |
|---------------|----------------|------------|
| `UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT` | 实际兑换到的代币数量低于你设定的最低值（滑点保护触发） | 增大滑点容忍度，或等价格稳定后再试 |
| `UniswapV2: INSUFFICIENT_INPUT_AMOUNT` | 输入代币数量不足 | 检查输入金额 |
| `UniswapV2: INSUFFICIENT_LIQUIDITY` | 流动性池中没有足够的代币来完成兑换 | 减少兑换金额，或换用其他流动性更好的池子 |
| `UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED` | 移除流动性时数量不足 | 检查 LP 代币余额 |
| `UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED` | 添加流动性时数量太小 | 增加添加的代币数量 |
| `UniswapV2: EXPIRED` | 交易截止时间已过 | 重新发起交易（设置更长的截止时间） |
| `UniswapV2: K` | 恒定乘积检查失败（流动性池异常） | 可能是代币本身有问题（收费代币），尝试增大滑点 |
| `UniswapV2: TRANSFER_FAILED` | 代币转账失败 | 代币合约可能有转账限制，检查是否是特殊代币 |
| `UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT` | 滑点保护：实际产出低于最低要求 | 增大滑点容忍度 |
| `UniswapV2Router: EXCESSIVE_INPUT_AMOUNT` | 所需输入超过你设定的最大值 | 增大输入上限或减少期望输出 |

### Uniswap V3
| Error | Plain Language | Suggestion |
|-------|----------------|------------|
| `Too little received` | 收到的代币太少，滑点保护触发 | 增大滑点容忍度 |
| `Too much requested` | 请求的代币太多 | 减少兑换金额 |
| `STF` | 安全转账失败（SafeTransferFrom Failed） | 检查代币余额和授权 |
| `TF` | 转账失败（Transfer Failed） | 代币转账失败，可能需要先授权 |
| `AS` | 已过期（Already Settled / Expired） | 交易过期，重新发起 |
| `LOK` | 池子被锁定（Locked） | 正在被其他操作占用，稍后再试 |
| `SPL` | 价格滑点限制（Slippage Price Limit） | 增大滑点容忍度 |
| `IIA` | 输入金额无效 | 检查输入金额是否大于 0 |
| `M0` | 铸造金额为 0 | 添加流动性的金额太小 |
| `Transaction too old` | 交易已过期 | 重新发起交易 |

### Uniswap Universal Router
| Error | Plain Language |
|-------|----------------|
| `V2_INVALID_PATH` | 兑换路径无效 |
| `V3_INVALID_SWAP` | V3 兑换参数无效 |
| `InvalidCommandType(uint256)` | 无效的命令类型 |
| `ExecutionFailed(uint256,bytes)` | 在第 N 步执行失败 |
| `LengthMismatch()` | 命令和输入参数数量不匹配 |
| `ETH_NOT_ACCEPTED` | 合约不接受 ETH |
| `DEADLINE_PASSED` | 交易截止时间已过 |
| `SLICE_OUT_OF_BOUNDS` | 参数解析越界 |

## 5. Aave Errors

| Error Code | Revert String | Plain Language |
|------------|---------------|----------------|
| 1 | `CALLER_NOT_POOL_ADMIN` | 你不是池子管理员 |
| 26 | `HEALTH_FACTOR_NOT_BELOW_THRESHOLD` | 健康因子未低于清算线，无法清算 |
| 27 | `COLLATERAL_CANNOT_BE_LIQUIDATED` | 该抵押品不能被清算 |
| 29 | `SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER` | 用户没有借入该代币 |
| 30 | `INCONSISTENT_FLASHLOAN_PARAMS` | 闪电贷参数不一致 |
| 35 | `HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD` | 操作后健康因子会低于清算线 | 减少借款金额或增加抵押品 |
| 36 | `COLLATERAL_CANNOT_COVER_NEW_BORROW` | 抵押品不足以支撑新的借款 |
| 38 | `BORROW_CAP_EXCEEDED` | 借款已达上限 |
| 39 | `SUPPLY_CAP_EXCEEDED` | 存款已达上限 |

## 6. Compound Errors

| Error | Plain Language |
|-------|----------------|
| `insufficient cash` | 协议中没有足够的资金可借 |
| `insufficient liquidity` | 流动性不足 |
| `insufficient shortfall` | 健康因子正常，无法清算 |
| `market not listed` | 这个市场未在 Compound 上线 |
| `borrow rate is absurdly high` | 借款利率异常高 |

## 7. Common DeFi / General Patterns

| Pattern | Plain Language | Suggestion |
|---------|----------------|------------|
| `ds-math-sub-underflow` | 减法下溢 — 试图用小数减大数 | 通常是余额不足导致 |
| `SafeMath: subtraction overflow` | 同上 | 通常是余额不足 |
| `SafeMath: division by zero` | 除以零 | 合约内部计算错误 |
| `TRANSFER_FAILED` | 代币转账失败 | 检查代币余额和授权 |
| `APPROVE_FAILED` | 代币授权失败 | 某些代币需要先将授权设为 0 再设新值 |
| `TransferHelper: TRANSFER_FROM_FAILED` | 转账失败（通常是授权不足或余额不足） | 先授权再操作 |
| `TransferHelper::safeTransferFrom: transferFrom failed` | 同上 | 先授权再操作 |
| `execution reverted` | 通用执行失败（无具体错误信息） | 需要进一步分析执行追踪 |
| `invalid opcode` | 遇到了无效的操作码 | 合约可能有 bug 或版本不兼容 |
| `out of gas` | Gas 耗尽 | 增加 Gas Limit |
| `stack too deep` | 栈太深 | 合约代码问题，联系开发者 |
| `max fee per gas less than block base fee` | 你设置的最大 Gas 费低于当前网络要求 | 提高 Gas 费设置 |
| `already known` | 交易已经在等待队列中 | 等待之前的交易完成 |
| `nonce too low` | 交易序号太低，可能已有同序号交易 | 使用正确的 nonce |
| `replacement transaction underpriced` | 替换交易的 Gas 费太低 | 提高 Gas 费（至少比原交易高 10%） |

## 8. Bridge & Cross-Chain Errors

| Pattern | Plain Language |
|---------|----------------|
| `NOT_ENOUGH_FUNDS` | 跨链桥中资金不足 |
| `INVALID_PROOF` | 跨链证明无效 |
| `MESSAGE_ALREADY_RELAYED` | 消息已经中继过了（重复操作） |
| `WITHDRAWAL_NOT_FINALIZED` | 提款尚未完成最终确认期 |

## 9. Common Custom Error Selectors (4byte)

These are frequently seen custom error selectors. If you encounter an unknown selector, use `cast 4byte <selector>` to look it up first. If that lookup returns no match, or fails because the 4byte service cannot be reached, and you have Heimdall installed plus enough calldata or contract context, retry with Heimdall before concluding the selector is unknown.

| Selector | Likely Error | Plain Language |
|----------|-------------|----------------|
| `0x` (empty) | plain revert() or out-of-gas | 合约回滚但没有给出原因 |
| `0x08c379a0` | Error(string) | 标准错误消息 |
| `0x4e487b71` | Panic(uint256) | Solidity 内部恐慌 |
| `0xb12d13eb` | `InvalidPath()` | 兑换路径无效 |
| `0x739dbe52` | `MintPaused()` | 铸造已暂停 |
| `0xbaa1eb22` | `BorrowPaused()` | 借款已暂停 |

## 10. Fee-on-Transfer Token Issues

Some tokens deduct a fee on transfer (e.g., SAFEMOON, SHIB variants, reflection tokens). This causes:
- `UniswapV2: K` — the constant product check fails because less tokens arrive than expected
- `TRANSFER_FROM_FAILED` — received amount doesn't match expected amount

**Suggestion**: For fee-on-transfer tokens, use `swapExactTokensForTokensSupportingFeeOnTransferTokens` instead of regular swap functions. In wallet interfaces, enable "expert mode" or increase slippage significantly.

## 11. Approval/Allowance Patterns

Some tokens (like USDT on Ethereum mainnet) require setting allowance to 0 before setting a new value:
- First `approve(spender, 0)`, then `approve(spender, amount)`
- Error: `SafeERC20: approve from non-zero to non-zero allowance`
- **Suggestion**: 先将授权额度设为 0，再设置新的授权额度
