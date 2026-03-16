---
name: debug-EVM-tx-skills
description: "Repository overview for the debug-tx Claude Code skill. Covers the repo layout, single-source documentation rules, and how the runtime skill assets are maintained."
---

# debug-EVM-tx-skills Repository Overview

这个文件用于仓库级概览，不再逐段镜像安装版 skill 内容。

当前仓库目录示例统一使用 `debug-EVM-tx-skills`；实际运行时 skill 名称和调用命令保持为 `debug-tx`。

运行时的单一入口是 `.claude/skills/debug-tx/SKILL.md`。如果要修改实际给 Claude Code 使用的技能说明，优先编辑安装版目录，而不是当前文件。

## 单一来源约定

- 安装入口：`.claude/skills/debug-tx/SKILL.md`
- 仓库入口：`README.md`
- 文档源文件：`references/`
- 安装包内的 `references/`：由同步脚本从根目录 `references/` 复制生成

## 技能职责

这个仓库中的 `debug-tx` skill 用于定位 EVM 链上失败交易和链下预执行失败，面向非技术用户输出可理解的结论与下一步建议。

核心要求：

- 先识别链，再通过 Chainlist 选择 RPC
- 交易、回执、区块事实必须通过 RPC 获取
- 链上失败交易优先用 `cast run`
- 链上失败交易改用 `cast call` 时必须固定到 `blockNumber - 1`
- 十六进制与十进制转换统一使用 `cast to-hex` 和 `cast to-dec`
- 输出必须是通俗语言，避免直接抛给用户未解释的原始十六进制数据

## 维护方式

修改仓库时按下面顺序处理：

1. 修改 `.claude/skills/debug-tx/SKILL.md` 中的运行时说明
2. 修改根目录 `references/` 中的详细文档
3. 执行 `scripts/sync-skill-assets.sh`，把根目录 `references/` 同步到安装目录
4. 如果安装说明或仓库入口有变化，再更新 `README.md`

## 参考资料

- `README.md`：仓库说明、安装入口、GitHub 发布说明
- `.claude/skills/debug-tx/SKILL.md`：实际安装与运行时使用的 skill
- `references/tools-guide.md`：Foundry、Heimdall、Dedaub 与 RPC 操作说明
- `references/rpc-playbook.md`：RPC 选择、历史状态检查与链上/链下调试流程
- `references/common-errors.md`：常见错误签名与通俗解释
- `references/report-formatting.md`：输出格式模板
- `references/setup-and-install.md`：本地安装、升级与验证步骤

```bash
cast decode-error --sig "Panic(uint256)" <REVERT_DATA>
```

翻译 panic code：

- `0x01` → 断言失败（assert）
- `0x11` → 算术溢出或下溢
- `0x12` → 除以零
- `0x21` → 非法枚举转换
- `0x31` → 空数组 pop
- `0x32` → 数组索引越界
- `0x41` → 内存分配过大
- `0x51` → 调用未初始化的内部函数

3. **已知自定义错误**：

```bash
cast decode-error <REVERT_DATA>
```

如果需要补充模式匹配，再查 `references/common-errors.md` 中的常见错误数据库。

4. **无法解码的原始 revert data**：展示原始数据，说明无法直接解码。

5. **空 revert data（`0x`）**：可能是 `revert()` 无消息或 out-of-gas。

### 第四步：根因归因

**把根因归到用户能理解的有限类别，不要直接把 trace 全量丢给用户。**

归因分类（按检查顺序）：

#### 1. Gas 不足

`gasUsed` ≥ 95% of `gasLimit` 且 revert data 为空 → out-of-gas。

```bash
# 已在第二步获取 gasUsed 和 gasLimit
```

#### 2. 余额不足

```bash
cast balance <FROM> --rpc-url <RPC_URL> --block <BLOCK_NUMBER> --ether
```

对比 `value` + `gasUsed × gasPrice`。

#### 3. Nonce 问题

nonce 太低或太高 → 交易序号不匹配。

#### 4. 费用配置错误

EIP-1559 的 `maxFeePerGas` 低于区块 `baseFee`。

#### 5. 业务规则不满足

合约 `require` 检查失败 → 解码 revert string，查 `references/common-errors.md` 匹配常见错误模式。

#### 6. 权限不足

`Ownable: caller is not the owner`、`AccessControl` 错误 → 调用方没有权限。

#### 7. 代币相关

如果涉及 ERC20 操作：

```bash
# 检查余额
cast call <TOKEN> "balanceOf(address)(uint256)" <ADDRESS> --rpc-url <RPC_URL> --block <BLOCK>
# 检查授权
cast call <TOKEN> "allowance(address,address)(uint256)" <OWNER> <SPENDER> --rpc-url <RPC_URL> --block <BLOCK>
```

#### 8. 参数格式错误

输入参数不符合合约期望。

#### 9. 合约暂停

`Pausable: paused` → 合约已暂停。

#### 10. 外部调用联动回滚

内部调用的子合约失败导致整体回滚。从 trace 中定位失败的子调用。

#### 11. 代理合约问题

Proxy + implementation 不匹配或升级异常。

#### 12. 目标地址不是合约

`eth_getCode` 返回 `0x` → 目标地址没有合约代码。

如果以上均不能确定，尝试 `cast run` 获取完整执行追踪。如果 RPC 不支持 debug 接口，明确说明当前只能给出部分结论。

### 第五步：深度分析（仅在必要时）

**除非 JSON-RPC 证据不够，否则不要调用外部工具。**

#### `cast` 使用边界

只用于：

- `cast run` 重放链上失败交易
- `cast call` 做本地模拟
- 解码 revert data
- ABI 编解码辅助
- 十六进制与十进制转换

执行建议：

- 运行 `cast run` 时优先使用较长 timeout
- 不要因为默认超时过短而误判为无法重放
- 数值转换时优先使用 `cast to-hex <VALUE>` 和 `cast to-dec <VALUE>`

#### `heimdall` 使用边界

只用于：ABI 缺失时尝试 decode calldata、辅助识别函数 selector 和参数布局。

#### `dedaub` 使用边界

只用于：没有源码、没有 ABI、trace 也无法直接说明原因时。

```bash
# 获取字节码
cast code <CONTRACT_ADDRESS> --rpc-url <RPC_URL>
# Heimdall 反编译
heimdall decompile <CONTRACT_ADDRESS> --rpc-url <RPC_URL>
```

或建议用户访问 https://app.dedaub.com/decompile 上传字节码。

**反编译结果只能作为辅助证据，不应伪装成源码级确定结论。**

### 第六步：输出报告

读取 `references/report-formatting.md`。

按报告模板输出。核心原则：

- 所有解释必须是非技术用户能理解的
- 使用日常类比解释区块链概念
- 避免在主要说明中出现原始十六进制数据
- 提供可执行的具体建议
- 技术细节放在折叠区域中
- 如果用户使用中文，整个报告使用中文

## 失败边界

遇到以下情况要明确降级说明，**不要假装已经定位完成**：

- RPC 不支持 `debug_traceTransaction` 或 `trace_replayTransaction`
- `cast run` 所需历史状态无法从当前 RPC 完整获取
- 无法获得 ABI 且 revert data 为空
- 只能在近似状态重放，无法保证与链上原始执行完全一致
- 多层代理、多 `delegatecall` 导致根因只能部分确认
- 节点返回被网关裁剪过的错误信息
- 交易太旧、状态已被修剪

如果最终只能得到中低置信度结论，要明确指出还缺什么证据。

## 置信度规则

- **高**：直接拿到了可解码的 revert reason，且与链上状态吻合
- **中**：通过 `eth_call` 近似复现或只能从 trace 部分推断
- **低**：无 revert data、无 trace、只能从 gasUsed / 余额 / nonce 等间接推断

## 协作原则

- 优先给结论，不优先展示原始 trace
- 每个技术判断都尽量附一条证据
- 不要因为无法拿到源码就停止分析
- 不要默认用户知道 selector、slot、delegatecall、panic code 的含义
- 如果用户看起来是技术人员，可以在详细报告中提供更多技术细节

## 引用解析

本仓库固定使用以下路径，不再额外解析 `resolved_path`：

- `references/common-errors.md`
- `references/tools-guide.md`
- `references/report-formatting.md`

## Banner

在执行任何操作之前，先打印此 Banner：

```

██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗    ████████╗██╗  ██╗
██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝    ╚══██╔══╝╚██╗██╔╝
██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗      ██║    ╚███╔╝
██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║      ██║    ██╔██╗
██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝      ██║   ██╔╝ ██╗
╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝       ╚═╝   ╚═╝  ╚═╝

EVM Transaction Debugger — 让失败交易变得可理解

```
