# RPC Playbook

这份手册描述 `debug-EVM-tx-skills` skill 在执行时应遵循的最小依赖策略。

## 一、推荐能力分层

### Level 1：RPC 发现与基础节点能力

无论用户有没有给出 RPC，都必须先去 `https://chainlist.org/` 读取对应网络的 RPC 列表；需要机器可读列表时使用 `https://chainlist.org/rpcs.json`。

如果用户只给了 `tx hash` 而没有链信息：

- 先去 OKLink 浏览器查询这笔交易属于哪条链
- 如果能识别归属链，先把链告诉用户，再继续找 RPC
- 如果不能识别归属链，就提醒用户补充链名称、RPC 或浏览器链接
- OKLink 在这里仅用于识别链归属，不用于获取交易详情、交易回执或区块事实

如果需要处理十六进制和十进制转换：

- 使用 `cast to-hex <VALUE>` 把十进制转成十六进制
- 使用 `cast to-dec <VALUE>` 把十六进制转成十进制
- `blockNumber`、`chainId`、`value`、`gas`、`gasPrice` 等字段统一按这个规则处理

必须先确认：

- 这条链可用的 RPC 列表是什么
- 交易所在链是否与用户口述一致
- 当前 RPC 是否能访问失败交易所在区块的历史状态

交易详情采集总规则：

- 交易详情必须通过 `eth_getTransactionByHash` 获取
- 交易回执必须通过 `eth_getTransactionReceipt` 获取
- 区块和历史状态相关事实必须通过标准 RPC 获取
- 不要把区块浏览器页面、浏览器 API 或人工抄录值当成交易详情的主来源

RPC 选择总规则：

- 实际执行分析时使用的 RPC 必须来自 Chainlist 提供的候选列表
- 如果用户提供了某个 RPC，也只能把它当成候选信息，不能绕过 Chainlist 直接使用
- 历史状态检查失败时，必须回到 Chainlist 候选列表中更换 RPC，直到找到支持所需历史状态的节点或确认公开候选都不满足
- 对链上失败交易，历史状态检查应至少覆盖失败交易相关的前一个块，因为后续模拟固定使用 `blockNumber - 1`

### Level 2：任何标准 JSON-RPC 节点

必须尽量先用这些方法：

- `eth_getTransactionByHash`
- `eth_getTransactionReceipt`
- `eth_getBlockByNumber`
- `eth_call`
- `eth_estimateGas`
- `eth_getCode`
- `eth_getBalance`
- `eth_getTransactionCount`

这一级可以解决：

- 交易是否真的失败
- 目标地址是不是合约
- 余额、nonce、费用字段是否明显异常
- 很多显式 revert string 的失败

进入后续分析前的强制检查：

- 先用候选 RPC 读取失败交易相关历史区块的数据
- 如果历史读取报错、返回空结果、返回明显不完整的数据，按“不支持归档历史状态”处理
- 一旦判定当前 RPC 不支持所需历史状态，立即回到 Chainlist 更换 RPC，不要继续沿用该节点给出结论
- 交易详情和回执如果不是直接来自 RPC，应视为未完成事实采集，不能进入后续分析

### Level 3：`cast` 本地重放与本地模拟

优先方法：

- `cast run <TX_HASH> --rpc-url <RPC_URL>`
- `cast call <TO> <CALLDATA> --from <FROM> --value <VALUE> --gas-limit <GAS> --rpc-url <RPC_URL>`

这一级是当前 skill 的主路径：

- 链上失败交易优先用 `cast run`
- 链下预执行和本地模拟优先用 `cast call`
- 只要是在分析链上已失败交易而使用 `cast call`，`--block` 都必须固定为失败交易的 `blockNumber - 1`
- 结论优先依据完整执行追踪或直接返回的回滚数据

### Level 4：调试型 RPC 节点

优先方法：

- `debug_traceTransaction`
- `debug_traceCall`
- `trace_replayTransaction`
- `trace_call`

这一级可以解决：

- 哪一层调用先失败
- 是否是外部调用联动回滚
- 更完整的 revert data 和错误栈
- gas 在哪一层被耗尽

### Level 5：辅助工具

仅在前两级证据不足时启用：

- `cast`
- `heimdall`
- `dedaub`

## 二、链上失败交易标准流程

### 1. 事实确认

先确认：

- 交易是否存在
- 是否被打包
- receipt `status` 是否为 `0x0`
- `gasUsed` 是否逼近或等于 gas limit
- 目标地址是否有代码

### 2. 错误重放

优先：

- `cast run <TX_HASH> --rpc-url <RPC_URL>`

次选：

- `debug_traceTransaction(txHash)`
- `trace_replayTransaction(txHash, ["trace", "vmTrace", "stateDiff"])`

兜底：

- 用原始交易参数做 `eth_call`
- block tag 优先用失败交易前一个区块

使用 `cast run` 时补充规则：

- 如果失败交易在所在区块里的位置已经接近或超过 30 笔，直接跳过 `cast run`，改用 `cast call`
- 本地 fork 的区块高度必须与失败交易所在区块一致
- 不要默认用 latest，否则模拟状态可能已经偏离失败时上下文
- 如果当前 RPC 缺少 `cast run` 所需的历史状态，先换用 Chainlist 里的其他 RPC，再决定是否降级
- 执行 `cast run` 时应使用较长 timeout，尤其是在慢 RPC、深调用链或大交易场景下
- 如果 `cast run` 超时，读取原交易参数并降级到 `cast call`
- 降级时使用失败交易的 `blockNumber - 1` 作为 `cast call --block` 的高度
- 降级时至少保留这些原始参数：`to`、`input`、`from`、`value`、`gas`
- 分析时优先依据完整执行追踪，定位最深层的首个失败点
- 如果只能用前一个区块或近似状态，必须在报告里明确写出这是近似复现

### 3. 错误解释

按下面顺序输出：

1. 是否拿到了 revert data
2. 是否能解出字符串错误
3. 是否是 panic code
4. 是否能映射到自定义错误
5. 如果都不行，是否能从调用深度和最后失败位置给出高概率归因

## 三、链下预执行失败标准流程

### 1. 先看原始错误文本

优先识别：

- `execution reverted`
- `insufficient funds`
- `nonce too low`
- `replacement transaction underpriced`
- `intrinsic gas too low`
- `max fee per gas less than block base fee`

### 2. 再做上下文检查

检查：

- from 余额
- from nonce
- to 地址是否有代码
- value 是否大于余额
- data 是否为空但用户以为自己在调合约

### 3. 最后做调用复现

优先：

- `cast call`

次选：

- `debug_traceCall`
- `eth_call`

如果是估算 gas 失败：

- 用相同参数做 `cast call`
- 如果 `cast call` 也 revert，优先定性为业务逻辑回滚
- 如果 `cast call` 成功但 `estimateGas` 失败，提示节点估算策略或状态依赖问题

如果这一步来自链上失败交易的 `cast run` 超时降级：

- `cast call` 必须使用失败交易的原始参数
- `--block` 必须固定为失败交易区块号减一
- 执行前必须再次确认当前 RPC 能读取该高度的历史状态；否则先从 Chainlist 更换 RPC
- 输出时明确说明这是超时后的降级调研，不是完整链上重放

如果这一步来自“区块内交易位置接近或超过 30 笔”的直接分流：

- 同样使用失败交易的原始参数
- `--block` 同样固定为失败交易区块号减一
- 执行前同样要验证当前 RPC 的历史状态能力；不支持就更换 Chainlist 候选 RPC
- 输出时明确说明这是基于区块内交易位置的直接 `cast call` 调研路径，且使用的是失败交易前一个块，不是 latest

总规则：

- 只要当前分析对象是链上已失败交易，任何模拟交易步骤都必须使用失败交易的前一个块，不能沿用用户提供的其他 block tag，也不能默认 latest
- 只要当前 RPC 不支持所需历史状态，就必须重新从 Chainlist 读取并更换 RPC，不能把“不支持归档”的节点当成最终依据

## 四、推荐输出风格

对非技术用户，优先输出以下三段：

```text
发生了什么：
为什么会这样：
你现在该怎么处理：
```

如果需要附加证据，再补：

```text
技术证据：
局限性：
```

## 五、建议避免的设计错误

- 不要强依赖区块浏览器 API
- 不要默认本地必须有 ABI 仓库
- 不要把完整 trace 直接贴给用户
- 不要把反编译结果当成源码事实
- 不要在没有证据时直接下结论说“合约有 bug”

## 六、这个 skill 最适合回答的问题

- 这笔 EVM 交易为什么失败
- 钱包为什么提示 execution reverted
- 为什么 estimateGas 失败
- 这个 calldata 调用了什么函数，失败点大概在哪
- 没有源码时还能定位到什么程度
