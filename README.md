# debug-EVM-tx-skills

这是一个面向 Claude Code 的 EVM 失败交易诊断 skill 仓库，运行时 skill 名称为 `debug-tx`，用来帮助用户用通俗语言理解以下问题：

- 链上交易为什么失败
- 钱包模拟为什么报 `execution reverted` 或 `estimateGas failed`
- calldata 实际在调用什么
- revert reason、panic code、custom error 分别意味着什么

这个仓库参考 Claude Code 官方 skills 文档的组织方式整理：

- 根目录 `README.md` 作为对外入口
- 根目录 `SKILL.md` 只保留仓库概览
- `.claude/skills/debug-tx/` 作为实际安装和运行时使用的 skill 目录
- 根目录 `references/` 作为文档单一来源
- `.claude/skills/debug-tx/references/` 作为安装包内的同步副本

下面涉及仓库路径的示例统一使用当前仓库目录名 `debug-EVM-tx-skills`；实际 skill 目录和调用命令仍然保持为 `debug-tx`。

## 仓库结构

```text
debug-EVM-tx-skills/
├── .claude/
│   └── skills/
│       └── debug-tx/
│           └── SKILL.md
├── CLAUDE.md
├── README.md
├── SKILL.md
├── VERSION
└── references/
	├── common-errors.md
	├── report-formatting.md
	├── setup-and-install.md
	└── tools-guide.md
```

## 适用场景

- 输入一笔失败交易的 hash，要求解释失败原因
- 输入一段 `to` + `data` + `from`，要求定位模拟失败原因
- 输入钱包或前端报错，要求判断是余额、授权、滑点、Gas 还是权限问题
- 输入浏览器链接，要求先识别链，再继续分析

## 依赖要求

### 必需

- Claude Code
- Foundry stable 版本

### 推荐

- Heimdall
- Dedaub 账号或可访问其网页版

## Foundry 安装要求

这个 skill 依赖 `cast` 做 RPC 读取、交易重放和本地模拟，因此要求用户安装 **Foundry stable**，不要默认使用 nightly。

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup --install stable
cast --version
```

如果本机已经装过 Foundry，也建议显式切到 stable：

```bash
foundryup --install stable
```

## 从 GitHub 下载并安装到本地

推荐先克隆仓库，再把其中的 skill 目录复制到 Claude Code 的个人 skills 目录。

```bash
git clone <YOUR_GITHUB_REPO_URL>
cd debug-EVM-tx-skills

mkdir -p ~/.claude/skills
cp -R ./.claude/skills/debug-tx ~/.claude/skills/debug-tx
```

安装完成后，在任意项目目录启动 Claude Code，直接调用：

```text
/debug-tx 0x1234...abcd on ethereum
```

也可以先问：

```text
What skills are available?
```

如果你想只在当前项目内使用，而不是全局安装，则复制到当前项目的 `.claude/skills/`：

```bash
mkdir -p ./.claude/skills
cp -R ./.claude/skills/debug-tx ./.claude/skills/debug-tx
```

更详细的本地安装、更新和验证步骤见 [references/setup-and-install.md](./references/setup-and-install.md)。

## 快速使用

### 调试链上失败交易

```text
/debug-tx 0x1234...abcd on ethereum
/debug-tx https://etherscan.io/tx/0x1234...abcd
```

### 调试链下预执行失败

```text
/debug-tx calldata 0xa9059cbb... to 0xdAC17F958D2ee523a2206206994597C13D831ec7 from 0x... on ethereum
```

## 工作方式

1. 先识别输入类型：tx hash、浏览器链接，或 calldata 模拟
2. 先确认链，再从 Chainlist 选择 RPC
3. 通过 RPC 获取交易、回执和区块上下文
4. 优先用 `cast run` 重放链上失败交易
5. 必要时用 `cast call` 在 `blockNumber - 1` 上做本地模拟
6. 把 revert reason 和底层错误翻译成非技术用户能理解的话

## 支持链

Ethereum、Polygon、Arbitrum、Optimism、Base、BSC、Avalanche、Gnosis、Fantom、zkSync、Linea、Scroll、Blast、Mantle、Celo。

只要用户能提供链名并且 Chainlist 上有可用 RPC，也可以扩展到其他 EVM 链。

## 参考资料

- [SKILL.md](./SKILL.md): 仓库级概览与维护约定
- [references/setup-and-install.md](./references/setup-and-install.md): 本地安装、升级与验证步骤
- [references/tools-guide.md](./references/tools-guide.md): Foundry、Heimdall、Dedaub 使用说明
- [references/rpc-playbook.md](./references/rpc-playbook.md): RPC 选择与调试流程手册
- [references/common-errors.md](./references/common-errors.md): 常见 revert reason 与 plain-language 解释
- [references/report-formatting.md](./references/report-formatting.md): 输出格式模板

## 维护说明

为了减少重复维护，仓库现在采用单一来源约定：

1. `.claude/skills/debug-tx/SKILL.md` 是运行时入口
2. 根目录 `references/` 是详细文档源文件
3. `.claude/skills/debug-tx/references/` 通过 `scripts/sync-skill-assets.sh` 从根目录 `references/` 同步

如果你修改了根目录 `references/`，发布前执行：

```bash
./scripts/sync-skill-assets.sh
```

## 发布到 GitHub 前建议

1. 把仓库地址替换到安装示例中的 `<YOUR_GITHUB_REPO_URL>`。
2. 如果改过根目录 `references/`，执行一次 `./scripts/sync-skill-assets.sh`。
3. 确认 `foundryup --install stable` 仍然是你希望用户遵循的安装要求。
4. 推送后，按安装步骤在一台干净环境里实际验证一次。
