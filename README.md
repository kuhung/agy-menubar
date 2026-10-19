# agy-menubar

[![macOS](https://img.shields.io/badge/platform-macOS-black?logo=apple&style=flat-square)](https://apple.com)
[![Python 3](https://img.shields.io/badge/python-3.9+-blue?style=flat-square&logo=python)](https://python.org)
[![Zero Dependency](https://img.shields.io/badge/dependencies-0-success?style=flat-square)](https://github.com/kuhung/agy-menubar)
[![License: MIT](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)

> **A minimalist, zero-dependency macOS menu bar context & token monitor for Google Antigravity.**
>
> 专为 Google Antigravity 打造的原生 macOS 顶部状态栏上下文容量与 Token 监控工具。

---

## 📸 Preview / 效果预览

```text
Mac 顶部状态栏:
[◎ 104.2k]  Tue Oct 19 14:50

点击下拉菜单:
┌──────────────────────────────────────────────┐
│ AI Model Quota Limits                        │
│ [■□□□□□□□□□□□]  10.4% (104,242 / 1M)        │
│ ──────────────────────────────────────────── │
│ Prompt Cache    102,005  (97.8%)             │
│ New Turn Input  2,237                        │
│ Headroom Left   895,758  (89.6%)             │
│ Active Model    Gemini 3.8 Flash (High)      │
│ ──────────────────────────────────────────── │
│ 切换跟踪会话 (Switch Conversation)    ▶       │
│   ✓ 自动跟踪最新活跃会话                      │
│     AI Model Quota Limits                    │
│     跨平台发布选股文章                       │
│ ──────────────────────────────────────────── │
│ 复制会话 ID                               ⌘C │
│ 在 Finder 中打开日志                       ⌘O │
│ 立即刷新                                   ⌘R │
│ ──────────────────────────────────────────── │
│ 退出                                       ⌘Q │
└──────────────────────────────────────────────┘
```

---

## 💡 Why agy-menubar? / 为什么需要它？

在使用 Google Antigravity 进行长程编码或多轮智能体任务时，开发者常常面临以下困惑：
1. **官方 UI 缺少 Token 仪表盘**：当前对话消耗了多少 Token？距离 1,000,000 上下文上限还有多少？
2. **何时该压缩上下文**：不知道何时该输入 `/compact`，往往等模型变慢或报错时才察觉。
3. **缓存命中情况不明**：多轮长任务里，Prompt Cache 实际节省了多少计算？

`agy-menubar` 巧妙利用 Antigravity 本地落盘的只读状态库与运行日志，提供一个**零噪音、高颜值、常驻在 Mac 上边栏**的轻量指示器。

---

## ✨ Features / 核心特性

- 🟢 **Retina 原生动态微环**：基于 macOS CoreGraphics 矢量绘制 18×18 微型进度环，随 Token 比例显示绿/橙/红三段状态色。
- 📊 **精准明细分解**：毫秒级展示 Prompt Cache 命中量、增量 Token、剩余可用空间与模型规格。
- 🔄 **会话智能感知**：自动跟踪你当前正在键入的最活跃会话，也可在子菜单中手动锁定某一个固定会话。
- 🪶 **真正零依赖（Zero-Dependency）**：仅需 macOS 自带的 Python 3 与系统 Cocoa 原生 API（PyObjC），无需通过 Homebrew 下载庞大的第三方包或重型 Electron 壳子。
- 🔒 **100% 本地只读与隐私安全**：纯离线扫描本地 `~/.gemini/antigravity/` 数据，不发任何网络请求，不对底层做任何写操作。
- 🚀 **开机自启（LaunchAgent）**：配置标准的 macOS 用户守护进程，无感常驻，极低 CPU/内存开销。

---

## ⚡️ Quick Start / 一键安装

打开终端运行以下单行脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/kuhung/agy-menubar/main/install.sh | bash
```

安装脚本会自动完成：
1. 校验 macOS 与 Python 运行环境；
2. 安装可执行文件至 `~/.local/bin/agy-menubar`；
3. 配置并启动 `~/Library/LaunchAgents/com.kuhung.agy-menubar.plist` 开机自启服务。

> **安装后**：抬头看你的 Mac 顶部菜单栏，即可看到动态进度圈与实时 Token 数值。

---

## 🛠️ Manual Installation / 手动安装

如果你喜欢克隆代码：

```bash
git clone https://github.com/kuhung/agy-menubar.git
cd agy-menubar
./install.sh
```

直接前台运行测试：
```bash
./bin/agy-menubar
```

---

## ⌨️ Shortcuts / 快捷操作

在菜单栏点击图标后支持键盘快捷键：
- `⌘C`：一键复制当前会话 ID 到剪贴板。
- `⌘O`：在 Finder 中快速打开当前会话底层日志目录。
- `⌘R`：强制立即重新读取并刷新。
- `⌘Q`：安全退出。

---

## 🗑️ Uninstall / 卸载

如果你想卸载，只需在项目目录下运行卸载脚本，或直接在终端输入：

```bash
curl -fsSL https://raw.githubusercontent.com/kuhung/agy-menubar/main/uninstall.sh | bash
```

这会干净移除 LaunchAgent 服务配置并删除二进制文件，不留任何系统垃圾。

---

## 🏗️ Architecture / 底层原理

```text
┌─────────────────────────────────┐
│     Antigravity 本地运行时      │
│  ~/.gemini/antigravity/         │
└───────┬─────────────────┬───────┘
        │ ① 读取活跃会话   │ ② 提取 Token 指标
        ▼                 ▼
 ┌───────────────┐ ┌──────────────────┐
 │ SQLite WAL 库 │ │ transcript.jsonl │
 └───────┬───────┘ └───────┬──────────┘
         │                 │
         └────────┬────────┘
                  ▼ ③
  ┌────────────────────────────────┐
  │  Python + PyObjC 原生轻量代理  │
  │  (kCFRunLoopCommonModes, 1.5s) │
  └───────────────┬────────────────┘
                  │ ④ CoreGraphics 矢量绘制
                  ▼
   [ 动态微环图标 + 104k ] 顶部状态栏
```

- **活跃会话读取**：直连 `~/.gemini/antigravity/conversation_summaries.db`（SQLite WAL 只读模式），按 `last_modified_time` 快速排序。
- **Token 精确获取**：解析目标会话的 `.system_generated/logs/transcript.jsonl`，提取 `input_tokens`、`cache_read_tokens` 与 `output_tokens`。
- **UI 线程保活**：定时器挂在 `kCFRunLoopCommonModes`，保证拖拽窗口或展开菜单时保持平稳更新。

---

## 📄 License

[MIT License](LICENSE) © 2026 [kuhung](https://github.com/kuhung)
