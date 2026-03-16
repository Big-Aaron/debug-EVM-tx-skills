# Setup And Install

这份文档说明如何把当前仓库作为 Claude Code skill 安装到本地，并验证是否安装成功。

## 1. 推荐方式：直接通过仓库 URL 安装

如果你使用的是支持 Claude skills 安装提示词的 AI CLI，可以直接粘贴：

```text
Install skill https://github.com/Big-Aaron/debug-EVM-tx-skills/
```

安装后，进入任意项目目录即可直接调用：

```text
run debug-tx on transaction 0x1234...abcd on ethereum
```

更新到最新版本时可以粘贴：

```text
update the debug-tx skill to latest version from https://github.com/Big-Aaron/debug-EVM-tx-skills/
```

## 2. 前置要求

### Claude Code

先安装 Claude Code。官方推荐方式见：

- macOS / Linux: `curl -fsSL https://claude.ai/install.sh | bash`
- Homebrew: `brew install --cask claude-code`

安装完成后，确认命令可用：

```bash
claude --version
```

### Foundry stable

当前 skill 强依赖 `cast`，因此必须安装 Foundry stable。

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup --install stable
cast --version
```

要求：

- 使用 stable，不使用 nightly 作为默认环境
- `cast` 命令必须在 shell 中直接可用

### Heimdall

Heimdall 不是每次都必须，但遇到未验证合约时很有帮助。可按官方仓库说明单独安装。

验证方式：

```bash
heimdall --help
```

### Dedaub

Dedaub 是网页工具，不需要本地安装。需要时访问：

```text
https://app.dedaub.com/decompile
```

## 3. 从 GitHub 下载仓库

```bash
git clone https://github.com/Big-Aaron/debug-EVM-tx-skills.git
cd debug-EVM-tx-skills
```

下面的命令示例统一假设你的本地仓库目录名是 `debug-EVM-tx-skills`。如果你克隆后的目录名不同，把 `cd` 后面的路径替换成你的实际目录即可。

## 4. 手动安装方式

### 方式 A：安装为个人 skill

这种方式会让它在所有项目里可用。

```bash
mkdir -p ~/.claude/skills
cp -R ./debug-tx ~/.claude/skills/
```

安装后目录应当类似：

```text
~/.claude/skills/debug-tx/
└── SKILL.md
```

### 方式 B：安装为项目内 skill

这种方式只在某一个目标项目可用。下面命令需要在目标项目目录里执行，而不是在当前 skill 仓库里执行。

```bash
cd /path/to/your-project
mkdir -p ./.claude/skills
cp -R /path/to/debug-EVM-tx-skills/debug-tx ./.claude/skills/
```

把 `/path/to/debug-EVM-tx-skills` 替换成你克隆下来的这个仓库的实际路径。

## 5. 验证安装是否成功

进入任意项目后启动 Claude Code，然后用以下任一方式验证。

### 方式 1：查看可用 skills

```text
What skills are available?
```

### 方式 2：直接调用 skill

```text
/debug-tx 0x1234...abcd on ethereum
```

如果 skill 已正确安装，Claude Code 应该能识别 `/debug-tx`。

## 6. 更新 skill

如果你从 GitHub 拉了新版本，重新复制一次 skill 目录即可：

```bash
git pull
rm -rf ~/.claude/skills/debug-tx
cp -R ./debug-tx ~/.claude/skills/
```

如果你不想使用删除再复制，也可以改用 `rsync`。

## 7. 发布者说明

如果你要把这个仓库推送到自己的 GitHub，建议发布前检查以下几点：

1. 根目录 `README.md` 中的 GitHub 仓库地址仍然正确。
2. 如果修改过根目录 `references/`，已经执行 `./scripts/sync-skill-assets.sh`。
3. `debug-tx/SKILL.md` 仍然是实际安装入口。
4. `VERSION` 已按语义化版本维护。
5. `references/` 中的链接没有失效。

## 7.1 文档单一来源

为了减少维护成本，仓库采用以下约定：

- 实际 skill 入口：`debug-tx/SKILL.md`
- 仓库概览：根目录 `SKILL.md`
- 详细文档源文件：根目录 `references/`
- 安装包副本：`debug-tx/references/`
- 本地验证镜像：`.claude/skills/debug-tx/`

当根目录 `references/`、根目录 `VERSION` 或 `debug-tx/SKILL.md` 更新后，执行：

```bash
./scripts/sync-skill-assets.sh
```

这样可以保证仓库内的可安装 skill 包和本地验证镜像都拿到最新 supporting files。

## 8. 常见问题

### `/debug-tx` 不显示

优先检查：

- `~/.claude/skills/debug-tx/SKILL.md` 是否真实存在
- 目录名是否是 `debug-tx`
- 文件名是否是 `SKILL.md`
- Claude Code 是否已经重启或重新进入项目

### `cast` 找不到

说明 Foundry 没装好，或者 shell PATH 没生效。重新执行：

```bash
foundryup --install stable
cast --version
```

### 安装后技能内容没更新

说明你可能只更新了仓库根目录，但没有重新复制 `debug-tx/`。重新同步并重新复制该目录即可。
