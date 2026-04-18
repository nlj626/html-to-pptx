# html-to-pptx

将 [html-ppt](https://github.com/lewislulu/html-ppt-skill) 生成的 HTML 演示文稿一键转换为 PPTX 文件。

## 工作原理

1. **headless Chrome 截图**：利用 Chrome 的 `#/N` 深度链接，逐页将 HTML 渲染为 PNG 图片
2. **pptxgenjs 组装**：将 PNG 图片按顺序嵌入 PPTX，每张图片铺满整页

因为是截图方式，PPTX 会 100% 还原 HTML 的视觉效果，包括字体、颜色、布局、渐变、动画等。

> **注意**：输出的 PPTX 中每页是一张图片，不可编辑文字。适合需要分享给只接受 PPTX 格式的场景。

## 安装

### 依赖

- **Google Chrome**（macOS 默认路径 `/Applications/Google Chrome.app`）
- **Node.js** >= 18
- **pptxgenjs**：`npm install -g pptxgenjs`

### 作为 Claude Code Skill 安装

```bash
# 方法 1：通过 skills CLI（推荐）
npx skills add picaro/html-to-pptx

# 方法 2：手动
mkdir -p ~/.claude/skills
git clone https://github.com/picaro/html-to-pptx ~/.claude/skills/html-to-pptx
```

安装后，在 Claude Code 中说"导出 PPTX"即可自动触发。

## 使用方式

### 命令行

```bash
bash scripts/html-to-pptx.sh <html-file> [N|all] [--ratio 16:9|4:3|3:4|1:1] [--quality N|png]
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `<html-file>` | html-ppt 生成的 HTML 文件路径 | 必填 |
| `N` | 指定转换的页数 | `all`（自动检测） |
| `--ratio` | 幻灯片宽高比 | `16:9` |
| `--quality` | JPEG 压缩质量（1-100），或 `png` 强制无损 | `92` |

### 示例

```bash
# 自动检测页数，默认 16:9
bash scripts/html-to-pptx.sh my-deck/index.html

# 指定 8 页
bash scripts/html-to-pptx.sh my-deck/index.html 8

# 4:3 宽高比
bash scripts/html-to-pptx.sh my-deck/index.html all --ratio 4:3

# 更小的文件（JPEG 质量 80）
bash scripts/html-to-pptx.sh my-deck/index.html all -- --quality 80

# 无损 PNG 格式
bash scripts/html-to-pptx.sh my-deck/index.html all -- --quality png
```

### 作为 Claude Code Skill 使用

安装后，在对话中说：

- "导出 PPTX"
- "把这个 HTML 转成 PPT"
- "convert to pptx"

## 与 html-ppt 的关系

本项目是 [html-ppt](https://github.com/lewislulu/html-ppt-skill) 的配套工具，将 html-ppt 生成的 HTML 演示文稿转换为通用 PPTX 格式，方便分享给不支持 HTML 的场景。

html-ppt 使用 MIT 协议，本项目同样使用 MIT 协议，完全兼容。

## 项目结构

```
html-to-pptx/
├── SKILL.md              # Claude Code Skill 描述文件
├── LICENSE              # MIT 许可证
├── README.md            # 本文件
├── .gitignore
└── scripts/
    ├── html-to-pptx.sh    # 主入口：截图 + 组装
    ├── html-to-pptx.cjs    # PPTX 组装（pptxgenjs）
    └── render.sh          # headless Chrome 截图
```

## 依赖说明

| 依赖 | 用途 | 安装 |
|------|------|------|
| Google Chrome | headless 截图 | 系统自带 |
| Node.js >= 18 | 运行 pptxgenjs | [nodejs.org](https://nodejs.org) |
| pptxgenjs | PPTX 文件生成 | `npm install -g pptxgenjs` |

## License

MIT © 2026 picaro
