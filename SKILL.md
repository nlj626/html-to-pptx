---
name: html-to-pptx
description: "将 html-ppt 演示文稿一键转换为 PPTX。触发词：导出 PPTX、转成 PPT、HTML 变 PPTX、convert to pptx、导出给同事、PPTX 导出。当用户有一份 html-ppt 生成的 HTML 演示文稿（index.html），想要转换为 .pptx 格式时使用。也适用于用户说'把这个 HTML 发给同事'、'他们只接受 PPT'等场景。"
---

# html-to-pptx — HTML 演示文稿转 PPTX

将 html-ppt 生成的 HTML 演示文稿一键转换为 .pptx 文件。

## Agent 使用指南

当用户说"导出 PPTX"、"转成 PPT"、"HTML 变 PPTX"或类似的话时：

1. **确认 HTML 文件路径** — 通常在 `~/.claude/skills/html-ppt/examples/<deck-name>/index.html`，或用户指定的路径
2. **运行转换命令**：
   ```bash
   bash ~/.claude/skills/html-to-pptx/scripts/html-to-pptx.sh <html文件路径>
   ```
3. **报告结果** — 告诉用户 PPTX 文件的路径和大小
4. **可选参数**：
   - `--ratio 4:3` — 指定宽高比（支持 16:9、4:3、3:4、1:1）
   - `-- --quality 80` — 指定 JPEG 质量（1-100，默认 92）
   - `-- --quality png` — 强制 PNG 格式（无损但文件较大）

## 工作原理

1. **headless Chrome 截图**：逐页将 HTML 渲染为 PNG 图片（支持 `#/N` 深度链接）
2. **pptxgenjs 组装**：将图片按顺序嵌入 PPTX，每张铺满整页

因为是截图方式，PPTX 会 **100% 还原 HTML 的视觉效果**，包括字体、颜色、布局、渐变等。

## 命令参考

```bash
# 自动检测页数
bash scripts/html-to-pptx.sh /path/to/deck/index.html

# 指定页数
bash scripts/html-to-pptx.sh /path/to/deck/index.html 8

# 4:3 宽高比
bash scripts/html-to-pptx.sh /path/to/deck/index.html all --ratio 4:3

# 指定 JPEG 质量（更小文件）
bash scripts/html-to-pptx.sh /path/to/deck/index.html all -- --quality 80

# 无损 PNG 格式
bash scripts/html-to-pptx.sh /path/to/deck/index.html all -- --quality png
```

输出文件与 HTML 同目录，文件名相同但扩展名为 `.pptx`。

## 依赖

- **Google Chrome**：macOS 默认路径 `/Applications/Google Chrome.app`
- **pptxgenjs**：`npm install -g pptxgenjs`

## 注意事项

- 输出的 PPTX 中每页是一张图片，**不可编辑文字**（但视觉效果完美还原）
- 如果需要可编辑文字的 PPTX，应使用 pptx skill 从头创建
- 适合场景：需要将 html-ppt 作品分享给只接受 PPTX 格式的同事/客户
