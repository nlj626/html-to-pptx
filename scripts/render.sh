#!/usr/bin/env bash
# html-to-pptx :: render.sh — headless Chrome screenshot(s)
#
# Usage:
#   render.sh <html-file> <N|all> <out-dir> [ratio]
#
# ratio: 16:9 (default), 4:3, 3:4, 1:1, 1920x1080, etc.
#
# Requires: Google Chrome at /Applications/Google Chrome.app (macOS).

set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [[ ! -x "$CHROME" ]]; then
  echo "error: Chrome not found at $CHROME" >&2
  exit 1
fi

FILE="${1:-}"
if [[ -z "$FILE" ]]; then
  echo "usage: render.sh <html> [N|all] [out-dir] [ratio]" >&2
  exit 1
fi
if [[ ! -f "$FILE" ]]; then
  echo "error: $FILE not found" >&2
  exit 1
fi

COUNT="${2:-1}"
OUT="${3:-}"
RATIO_FLAG="${4:-16:9}"

# 解析宽高比
parse_ratio() {
  local r="${1:-16:9}"
  case "$r" in
    16:9|1920x1080) echo "1920 1080" ;;
    4:3|1024x768)   echo "1024 768" ;;
    3:4|768x1024)   echo "768 1024" ;;
    1:1|1080x1080)  echo "1080 1080" ;;
    *) echo "warning: 不支持的宽高比 '$r'，使用默认 16:9" >&2; echo "1920 1080" ;;
  esac
}

read -r WIN_W WIN_H <<< "$(parse_ratio "$RATIO_FLAG")"

ABS="$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")"
STEM="$(basename "${FILE%.*}")"

# 精确统计页数：匹配 <section class="slide" 开标签
if [[ "$COUNT" == "all" ]]; then
  COUNT="$(grep -c '<section class="slide"\|<section class="slide ' "$FILE" || true)"
  [[ -z "$COUNT" || "$COUNT" -lt 1 ]] && COUNT=1
fi

if [[ -z "$OUT" ]]; then
  if [[ "$COUNT" -gt 1 ]]; then
    OUT="$(dirname "$FILE")/${STEM}-png"
    mkdir -p "$OUT"
  fi
fi

render_one() {
  local url="$1" target="$2"
  "$CHROME" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --no-sandbox \
    --virtual-time-budget=5000 \
    --window-size=${WIN_W},${WIN_H} \
    --screenshot="$target" \
    "$url" >/dev/null 2>&1
  # 直接检查输出文件，不依赖 $?（更健壮）
  if [[ -f "$target" && -s "$target" ]]; then
    echo "  ✔ $target"
  else
    echo "  ✘ $target (渲染失败)" >&2
    return 1
  fi
}

FAIL_COUNT=0

if [[ "$COUNT" == "1" ]]; then
  OUT_FILE="${OUT:-$(dirname "$FILE")/${STEM}.png}"
  render_one "file://$ABS" "$OUT_FILE" || FAIL_COUNT=$((FAIL_COUNT + 1))
else
  for i in $(seq 1 "$COUNT"); do
    render_one "file://$ABS#/$i" "$OUT/${STEM}_$(printf '%02d' "$i").png" || FAIL_COUNT=$((FAIL_COUNT + 1))
  done
fi

echo "done: rendered $COUNT slide(s) from $FILE"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "warning: $FAIL_COUNT page(s) failed to render" >&2
fi
