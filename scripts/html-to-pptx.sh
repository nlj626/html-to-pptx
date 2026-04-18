#!/usr/bin/env bash
# html-to-pptx — 将 html-ppt 演示文稿转换为 PPTX
#
# 用法：
#   html-to-pptx.sh <html-file> [N|all] [--ratio 4:3] [--quality 80|png]
#
# 参数顺序无关，--ratio 和 --quality 可放在任意位置
# 输出：与 HTML 同目录，文件名同 HTML 但扩展名为 .pptx

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FILE=""
COUNT="all"
RATIO="16:9"
QUALITY_ARGS=()

# 解析参数：第一个 .html 文件作为输入，其余按命名参数和位置参数处理
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ratio)
      RATIO="${2:?--ratio 需要一个值}"
      shift 2
      ;;
    --quality)
      QUALITY_ARGS+=("--quality" "${2:?--quality 需要一个值}")
      shift 2
      ;;
    *.html|*.htm)
      FILE="$1"
      shift
      ;;
    all)
      COUNT="all"
      shift
      ;;
    [0-9]*)
      COUNT="$1"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$FILE" ]]; then
  echo "用法: html-to-pptx.sh <html-file> [N|all] [--ratio 16:9|4:3|3:4|1:1] [--quality N|png]" >&2
  exit 1
fi
if [[ ! -f "$FILE" ]]; then
  echo "错误: 文件不存在 $FILE" >&2
  exit 1
fi

ABS="$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")"
STEM="$(basename "${FILE%.*}")"
DIR="$(dirname "$ABS")"
PPTX_OUT="${DIR}/${STEM}.pptx"

# 临时目录存放 PNG
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "━━━ html-to-pptx ━━━"
echo "  输入: $FILE"
echo "  宽高比: $RATIO"

# 步骤 1：渲染 PNG
echo "  [1/2] 渲染 PNG 截图..."
bash "$SCRIPT_DIR/render.sh" "$FILE" "$COUNT" "$TMP_DIR" "$RATIO"

PNG_COUNT="$(ls "$TMP_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$PNG_COUNT" -eq 0 ]]; then
  echo "  错误: 未生成任何 PNG 截图" >&2
  exit 1
fi
echo "  已渲染 $PNG_COUNT 页"

# 步骤 2：组装 PPTX（传入宽高比让 cjs 同步幻灯片尺寸）
echo "  [2/2] 组装 PPTX..."
NODE_PATH="$(npm root -g)" node "$SCRIPT_DIR/html-to-pptx.cjs" "$TMP_DIR" "$PPTX_OUT" --ratio "$RATIO" "${QUALITY_ARGS[@]+"${QUALITY_ARGS[@]}"}"

echo "━━━ 完成 ━━━"
