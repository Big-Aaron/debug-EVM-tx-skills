# debug-EVM-tx-skills

> Claude Code skill for explaining failed EVM transactions and reverted simulations in plain language.

[License: MIT](./LICENSE) · [Contributing](./CONTRIBUTING.md) · [Security](./SECURITY.md)

---

## Install & Run

AI CLI（Claude Code / Codex / Cursor chat 等）：

直接粘贴下面的提示词安装：

```text
Install skill https://github.com/Big-Aaron/debug-EVM-tx-skills/
```

安装后可直接这样调用：

```text
run debug-EVM-tx-skills on transaction 0x1234...abcd on ethereum
```

```text
run debug-EVM-tx-skills on calldata 0xa9059cbb... to 0xdAC17F958D2ee523a2206206994597C13D831ec7 from 0x... on base
```

```text
/debug-EVM-tx-skills https://etherscan.io/tx/0x1234...abcd
```

更新到最新版本时，直接粘贴：

```text
update the debug-EVM-tx-skills skill to latest version from https://github.com/Big-Aaron/debug-EVM-tx-skills/
```

如果你更喜欢手动安装到本地 Claude skills 目录，也可以直接复制仓库中的 [debug-EVM-tx-skills](./debug-EVM-tx-skills/) 目录。完整步骤见 [debug-EVM-tx-skills/references/setup-and-install.md](./debug-EVM-tx-skills/references/setup-and-install.md)。

---

## Skills

| Skill | Description |
| --- | --- |
| [debug-EVM-tx-skills](./debug-EVM-tx-skills/) | Diagnose failed EVM transactions, reverted wallet simulations, and `estimateGas` failures in plain language. |

---

## 这个 skill 解决什么问题

- 链上交易为什么失败
- 钱包为什么提示 `execution reverted` 或 `estimateGas failed`
- 一段 calldata 实际调用了什么函数
- revert reason、panic code、custom error 分别意味着什么
- 没有源码时还能定位到什么程度

## 工作方式

1. 识别输入类型：tx hash、浏览器链接、钱包报错，或 calldata 模拟。
2. 先确认链，再从 Chainlist 选择 RPC。
3. 通过 RPC 获取交易、回执和区块事实。
4. 链上失败交易默认使用 `cast run` 本地重放；如果交易在区块内顺序大于 30，则改为先用 JSON-RPC 取原交易参数。
5. 需要走 `cast call` 时，固定使用失败交易前一个区块，也就是 `blockNumber - 1`。
6. 把底层技术原因翻译成非技术用户能理解的结论和建议。

## 依赖要求

必需：

- Claude Code
- Foundry stable 版本

推荐：

- Heimdall
- Dedaub 网页版

Foundry 安装建议：

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup --install stable
cast --version
```

## 仓库布局

```text
debug-EVM-tx-skills/
├── .github/                   # Issue / PR 模板
├── debug-EVM-tx-skills/       # 可安装 skill 包
│   ├── SKILL.md
│   ├── VERSION
│   └── references/
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── SECURITY.md
├── CLAUDE.md
├── README.md
└── .gitignore
```

## 仓库说明

这个仓库现在按 [pashov/skills](https://github.com/pashov/skills) 的单-skill 公开仓库方式组织：

- 根目录保留 README、CLAUDE 和社区文件
- 实际 skill 包直接放在根目录下的同名目录里
- 引用资料随 skill 包一起发布，不再保留根目录 `references/`
- 不再保留仓库内 `.claude` 镜像或同步脚本

当前 skill 名称和目录名都使用 `debug-EVM-tx-skills`，不再使用旧的 `debug-tx` 名称。

## 参考资料

- [debug-EVM-tx-skills/SKILL.md](./debug-EVM-tx-skills/SKILL.md): 实际运行时 skill 说明
- [debug-EVM-tx-skills/references/setup-and-install.md](./debug-EVM-tx-skills/references/setup-and-install.md): 本地安装、升级与验证步骤
- [debug-EVM-tx-skills/references/rpc-playbook.md](./debug-EVM-tx-skills/references/rpc-playbook.md): RPC 选择与调试流程手册
- [debug-EVM-tx-skills/references/tools-guide.md](./debug-EVM-tx-skills/references/tools-guide.md): Foundry、Heimdall、Dedaub 使用说明
- [debug-EVM-tx-skills/references/common-errors.md](./debug-EVM-tx-skills/references/common-errors.md): 常见 revert reason 与 plain-language 解释
- [debug-EVM-tx-skills/references/report-formatting.md](./debug-EVM-tx-skills/references/report-formatting.md): 输出格式模板

---

## Contributing · Security · License

欢迎改进和修复。提交流程见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

安全问题请参考 [SECURITY.md](./SECURITY.md)。社区协作规范见 [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)。仓库采用 [MIT](./LICENSE) 许可。
