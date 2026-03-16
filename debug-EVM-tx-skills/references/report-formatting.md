---
name: report-formatting
description: Output format template for the debug-EVM-tx-skills skill. Defines how to present transaction failure analysis to non-technical users.
---

# Report Format

Present findings in the following structure. The entire report must be understandable by someone with no blockchain development experience. If the user communicates in Chinese, write the entire report in Chinese.

---

## Template

```markdown
# 🔍 交易诊断报告 / Transaction Diagnosis

## 交易概览 / Transaction Overview

| 项目        | 详情                       |
| ----------- | -------------------------- |
| 交易哈希    | `0x...`                    |
| 链          | Ethereum / Polygon / ...   |
| 状态        | ❌ 失败 / ✅ 成功          |
| 发送方      | `0x...`                    |
| 接收方/合约 | `0x...` (合约名称，如已知) |
| 发送金额    | X ETH (¥Y / $Z，如可获取)  |
| Gas 消耗    | X / Y (已用/上限)          |

## 📝 交易意图

用一两句话，用日常语言解释这笔交易试图做什么。

例如：

- "这笔交易试图在 Uniswap 上将 1 ETH 兑换为 USDC"
- "这笔交易试图向地址 0x... 转账 100 USDT"
- "这笔交易试图在 Aave 上存入 5000 USDC 作为抵押品"

## ❌ 失败原因

用简单的类比解释为什么交易失败。不使用技术术语。

例如：

- "交易失败是因为你的钱包中没有足够的 USDT 来完成这次兑换。就好像你想用人民币买东西，但钱包里的钱不够。"
- "交易失败是因为你没有授权 Uniswap 使用你的代币。就像你要从银行转账，但还没有设置转账权限。"
- "交易失败是因为设置的滑点容忍度太低。在你提交交易到交易被执行的这段时间里，价格变化超过了你允许的范围。"

## 💡 建议操作

提供具体的、可操作的建议。每一步都要清晰明了。

1. **第一步**：具体操作说明
2. **第二步**：具体操作说明
3. ...

## 🔧 技术详情（高级用户）

<details>
<summary>点击展开技术详情</summary>

### 调用信息

- **函数**: `functionName(param1, param2, ...)`
- **参数**:
  - `param1`: value1 (说明)
  - `param2`: value2 (说明)

### 回滚原因

- **错误类型**: Error(string) / Panic(uint256) / CustomError / 空
- **原始数据**: `0x...`
- **解码结果**: "具体错误信息"

### Gas 分析

- **Gas 上限**: X
- **Gas 已用**: Y (占比 Z%)
- **Gas 价格**: X Gwei

### 执行追踪（如有）

关键的内部调用路径和失败点。

</details>
```

## Formatting Rules

1. **Language**: Match the user's language. Default to Chinese if user communicates in Chinese.
2. **No raw hex in main sections**: All hex values (addresses, calldata, selectors) should only appear in the technical details section. In main sections, use human-readable names.
3. **Analogies**: Use everyday analogies to explain blockchain concepts:
  - Allowance/Approval -> "授权" / "就像银行转账权限"
  - Gas -> "手续费" / "就像汽车需要汽油才能跑"
  - Slippage -> "滑点" / "就像市场价格的波动"
  - Revert -> "回滚" / "交易被取消，需要重新处理"
  - Smart Contract -> "智能合约" / "链上的自动化程序"
  - Token Balance -> "代币余额" / "你在这个代币上的存款"
4. **Actionable suggestions**: Every suggestion must be something the user can actually do. Don't suggest "check the contract source code" — instead suggest specific wallet actions.
5. **Addresses**: When possible, label addresses with known names (Uniswap Router, USDT, WETH, etc.).
6. **Amounts**: Convert wei to human-readable units (ETH, GWEI). For token amounts, respect the token's decimals.
