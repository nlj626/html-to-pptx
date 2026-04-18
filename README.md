# html-to-pptx

将 [html-ppt](https://github.com/lewislulu/html-ppt-skill) 生成的 HTML 演示文稿一键转换为 PPTX 文件。

A companion tool for [html-ppt](https://github.com/lewislulu/html-ppt-skill) that converts HTML presentations to PPTX in one click.

## 工作原理 / How It Works

1. **headless Chrome 截图**：利用 Chrome 的 `#/N` 深度链接，逐页将 HTML 渲染为 PNG 图片
   **Headless Chrome screenshots**: Renders each slide to PNG via Chrome's `#/N` deep links
2. **pptxgenjs 组装**：将 PNG 图片按顺序嵌入 PPTX，每张图片铺满整页
   **pptxgenjs assembly**: Embeds PNG images into PPTX, each filling the entire slide

因为是截图方式，PPTX 会 **100% 还原 HTML 的视觉效果**，包括字体、颜色、布局、渐变等。
Since it uses screenshots, the PPTX **perfectly preserves the HTML visual output**, including fonts, colors, layout, and gradients.

> **注意**：输出的 PPTX 中每页是一张图片，不可编辑文字。适合需要分享给只接受 PPTX 格式的场景。
>
> **Note**: Each slide in the output PPTX is an image — text is not editable. Ideal for sharing with audiences that only accept PPTX format.

## 安装 / Installation

### 前置依赖 / Prerequisites

- **Google Chrome**（macOS 默认路径 `/Applications/Google Chrome.app`）
- **Node.js** >= 18
- **pptxgenjs**: `npm install -g pptxgenjs`

### 作为 Claude Code Skill 安装 / Install as Claude Code Skill

```bash
# 方法 1：通过 skills CLI（推荐）
# Method 1: via skills CLI (recommended)
npx skills add nlj626/html-to-pptx

# 方法 2：手动
# Method 2: manual
mkdir -p ~/.claude/skills
git clone https://github.com/nlj626/html-to-pptx ~/.claude/skills/html-to-pptx
```

安装后，在 Claude Code 中说"导出 PPTX"即可自动触发。
After installation, just say "导出 PPTX" or "export to PPTX" in Claude Code to trigger.

## 使用方式 / Usage

### 命令行 / Command Line

```bash
bash scripts/html-to-pptx.sh <html-file> [N|all] [--ratio 16:9|4:3|3:4|1:1] [--quality N|png]
```

| 参数 / Param | 说明 / Description | 默认值 / Default |
|---|---|---|
| `<html-file>` | HTML 文件路径 / Path to HTML file | 必填 / Required |
| `N` | 指定转换的页数 / Number of slides | `all`（自动检测 / auto-detect） |
| `--ratio` | 幻灯片宽高比 / Slide aspect ratio | `16:9` |
| `--quality` | JPEG 质量（1-100），或 `png` 无损 / JPEG quality (1-100), or `png` for lossless | `92` |

### 示例 / Examples

```bash
# 自动检测页数，默认 16:9 / Auto-detect slides, default 16:9
bash scripts/html-to-pptx.sh my-deck/index.html

# 指定 8 页 / Specify 8 slides
bash scripts/html-to-pptx.sh my-deck/index.html 8

# 4:3 宽高比 / 4:3 aspect ratio
bash scripts/html-to-pptx.sh my-deck/index.html all --ratio 4:3

# 更小的文件（JPEG 质量 80）/ Smaller file (JPEG quality 80)
bash scripts/html-to-pptx.sh my-deck/index.html all -- --quality 80

# 无损 PNG 格式 / Lossless PNG
bash scripts/html-to-pptx.sh my-deck/index.html all -- --quality png
```

### 作为 Claude Code Skill 使用 / Use as Claude Code Skill

安装后，在对话中说：
After installation, say any of these in your conversation:

- "导出 PPTX" / "export to PPTX"
- "把这个 HTML 转成 PPT" / "convert HTML to PPT"

## 与 html-ppt 的关系 / Relationship with html-ppt

本项目是 [html-ppt](https://github.com/lewislulu/html-ppt-skill) 的配套工具，将 HTML 演示文稿转换为通用 PPTX 格式，方便分享给不支持 HTML 的场景。

This is a companion tool for [html-ppt](https://github.com/lewislulu/html-ppt-skill). It converts HTML presentations to the widely-supported PPTX format for sharing in scenarios where HTML is not accepted.

html-ppt 使用 MIT 协议，本项目同样使用 MIT 协议，完全兼容。
Both projects use the MIT License and are fully compatible.

## 项目结构 / Project Structure

```
html-to-pptx/
├── SKILL.md              # Claude Code Skill descriptor
├── LICENSE              # MIT License
├── README.md            # This file / 本文件
├── .gitignore
└── scripts/
    ├── html-to-pptx.sh    # Main entry: screenshot + assemble / 主入口：截图 + 组装
    ├── html-to-pptx.cjs    # PPTX assembly (pptxgenjs) / PPTX 组装
    └── render.sh          # Headless Chrome screenshot / headless Chrome 截图
```

## 依赖说明 / Dependencies

| 依赖 / Dependency | 用途 / Purpose | 安装 / Install |
|---|---|---|
| Google Chrome | headless 截图 / screenshots | 系统自带 / System |
| Node.js >= 18 | 运行 pptxgenjs / run pptxgenjs | [nodejs.org](https://nodejs.org) |
| pptxgenjs | PPTX 文件生成 / PPTX generation | `npm install -g pptxgenjs` |

## License

MIT © 2026 picaro
