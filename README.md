# agy-menubar

[English](README.md) | [简体中文](README_zh.md)

[![macOS](https://img.shields.io/badge/platform-macOS-black?logo=apple&style=flat-square)](https://apple.com)
[![Python 3](https://img.shields.io/badge/python-3.9+-blue?style=flat-square&logo=python)](https://python.org)
[![Dependencies](https://img.shields.io/badge/dependencies-0-success?style=flat-square)](https://github.com/kuhung/agy-menubar)
[![License: MIT](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)

Native macOS menu bar context window and token usage monitor for Google Antigravity.

---

## Preview

<p align="center">
  <img src="assets/demo.gif" alt="agy-menubar demo" width="680" />
</p>

<details>
<summary><b>Click to expand text menu layout</b></summary>

```text
macOS Menu Bar:
[◎ 104.2k]  Tue Oct 19 14:50

Dropdown Menu:
┌──────────────────────────────────────────────┐
│ AI Model Quota Limits                        │
│ [■□□□□□□□□□□□]  10.4% (104,242 / 1M)        │
│ ──────────────────────────────────────────── │
│ Prompt Cache    102,005  (97.8%)             │
│ Turn Input      2,237                        │
│ Headroom Left   895,758  (89.6%)             │
│ Active Model    Gemini Flash                 │
│ ──────────────────────────────────────────── │
│ Switch Conversation                   ▶      │
│   ✓ Auto-track latest active session         │
│     AI Model Quota Limits                    │
│     Multi-language Design                    │
│ ──────────────────────────────────────────── │
│ Copy Conversation ID                      ⌘C │
│ Reveal Logs in Finder                     ⌘O │
│ Refresh Now                               ⌘R │
│ Language / 语言                       ▶      │
│   ✓ System Default (Auto)                    │
│     简体中文                                 │
│     English                                  │
│ ──────────────────────────────────────────── │
│ Quit                                      ⌘Q │
└──────────────────────────────────────────────┘
```

</details>

---

## Why agy-menubar

During extended coding sessions or agent tasks in Antigravity, the interface does not show current token consumption or remaining context headroom. Long conversations can degrade or slow down before the user notices that running `/compact` is necessary.

`agy-menubar` stays in the macOS status bar, reads local session records, and presents token usage and cache ratios directly in the menu bar.

---

## Features

- **Dynamic Progress Ring**: Draws an 18×18 vector arc via CoreGraphics directly in the menu bar, transitioning from green to orange and red based on context saturation.
- **Detailed Token Breakdown**: Displays prompt cache volume, turn input, previous output, remaining headroom, and total steps.
- **Bilingual Interface**: Automatically matches macOS system language, allows switching between English and Simplified Chinese at runtime, and accepts `--lang {auto,zh,en}` from the command line.
- **Session Auto-Tracking**: Automatically follows the most recent active conversation, or lets you pin a specific conversation from the submenu.
- **Shortcuts**: Includes keyboard shortcuts to copy conversation IDs, reveal logs in Finder, refresh, and quit.
- **Local Read-Only Access**: Reads the local SQLite database and transcript files without network calls or state modifications.
- **LaunchAgent Support**: Configures a user-level launchd daemon for background operation with minimal CPU and memory usage.

---

## Quick Install

Run this command in Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/kuhung/agy-menubar/main/install.sh | bash
```

The installer performs the following:
1. Verifies the macOS environment and Python 3;
2. Copies the executable to `~/.local/bin/agy-menubar`;
3. Configures and starts `~/Library/LaunchAgents/com.kuhung.agy-menubar.plist`.

The status item appears in your menu bar immediately after installation.

---

## Manual Installation

Clone the repository and run the install script:

```bash
git clone https://github.com/kuhung/agy-menubar.git
cd agy-menubar
./install.sh
```

Run directly in the foreground for testing:

```bash
./bin/agy-menubar
```

Specify interface language:

```bash
./bin/agy-menubar --lang en
./bin/agy-menubar --lang zh
```

---

## Keyboard Shortcuts

When the menu is open, the following keys are available:

| Shortcut | Action |
|---|---|
| `⌘C` | Copy active conversation ID to clipboard |
| `⌘O` | Reveal log folder in Finder |
| `⌘R` | Re-read local records and refresh |
| `⌘Q` | Quit application |

---

## Uninstallation

Run the uninstaller via curl:

```bash
curl -fsSL https://raw.githubusercontent.com/kuhung/agy-menubar/main/uninstall.sh | bash
```

This stops the LaunchAgent service, removes the plist file, and deletes the binary.

---

## How It Works

```text
┌─────────────────────────────────┐
│     Antigravity Local Runtime   │
│  ~/.gemini/antigravity/         │
└───────┬─────────────────┬───────┘
        │ Read Active     │ Extract Token
        │ Session         │ Metrics
        ▼                 ▼
 ┌───────────────┐ ┌──────────────────┐
 │ SQLite WAL DB │ │ transcript.jsonl │
 └───────┬───────┘ └───────┬──────────┘
         │                 │
         └────────┬────────┘
                  ▼
   ┌────────────────────────────────┐
   │  Python + PyObjC Bridge        │
   │  (kCFRunLoopCommonModes, 1.5s) │
   └───────────────┬────────────────┘
                   │ CoreGraphics Vector Arc
                   ▼
     Menu Bar Status Item & Metrics
```

- **Session Detection**: Connects to `~/.gemini/antigravity/conversation_summaries.db` in read-only WAL mode, sorted by modification timestamp.
- **Transcript Parsing**: Inspects `transcript.jsonl` to extract input tokens, prompt cache tokens, and output tokens.
- **Stat Cache**: Compares file `mtime` and `size` to bypass parsing when idle.
- **Run Loop Integration**: Uses `kCFRunLoopCommonModes` so updates continue while menus are open or windows are dragged.

---

## License

[MIT License](LICENSE) © 2026 [kuhung](https://github.com/kuhung)
