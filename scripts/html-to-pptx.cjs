/**
 * html-to-pptx.cjs — 将 PNG 截图组装为 PPTX
 *
 * 用法: node html-to-pptx.cjs <png-dir> <output.pptx> [--ratio 16:9] [--quality 92|png]
 *
 * 逐页读取 PNG，按顺序嵌入 PPTX，每张图片铺满整页。
 * --ratio 控制幻灯片尺寸，需与 render.sh 的截图宽高比一致。
 * --quality 控制图片压缩质量，默认 JPEG 92。
 */

const PptxGenJS = require('pptxgenjs');
const fs = require('fs');
const path = require('path');

// 解析参数
const args = process.argv.slice(2);
const pngDir = args[0];
const outputPath = args[1];

let quality = 92;
let usePng = false;
let ratio = '16:9';

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--ratio' && args[i + 1]) {
    ratio = args[i + 1];
    i++;
  } else if (args[i] === '--quality' && args[i + 1]) {
    const val = args[i + 1];
    if (val.toLowerCase() === 'png') {
      usePng = true;
    } else {
      quality = Math.max(1, Math.min(100, parseInt(val) || 92));
    }
    i++;
  }
}

if (!pngDir || !outputPath) {
  console.error('用法: node html-to-pptx.cjs <png-dir> <output.pptx> [--ratio 16:9] [--quality 92|png]');
  process.exit(1);
}

// 根据宽高比计算幻灯片尺寸（英寸）
const RATIO_MAP = {
  '16:9': { w: 10, h: 5.625 },
  '4:3':  { w: 10, h: 7.5 },
  '3:4':  { w: 7.5, h: 10 },
  '1:1':  { w: 10, h: 10 },
};
const dim = RATIO_MAP[ratio] || RATIO_MAP['16:9'];
const SLIDE_W = dim.w;
const SLIDE_H = dim.h;

// 读取目录下所有 PNG，按文件名中的数字自然排序
const pngFiles = fs.readdirSync(pngDir)
  .filter(f => f.toLowerCase().endsWith('.png'))
  .sort((a, b) => {
    const na = parseInt((a.match(/\d+/) || [])[0] || '0');
    const nb = parseInt((b.match(/\d+/) || [])[0] || '0');
    return na - nb;
  });

if (pngFiles.length === 0) {
  console.error('错误: 目录中没有找到 PNG 文件');
  process.exit(1);
}

const fmt = usePng ? 'PNG' : `JPEG (quality: ${quality})`;
console.log(`  正在组装 ${pngFiles.length} 页 [${fmt}] [${ratio}]...`);

const pptx = new PptxGenJS();
pptx.defineLayout({ name: 'CUSTOM', width: SLIDE_W, height: SLIDE_H });
pptx.layout = 'CUSTOM';

for (const file of pngFiles) {
  const filePath = path.resolve(pngDir, file);
  const imgData = fs.readFileSync(filePath);
  const base64 = Buffer.from(imgData).toString('base64');

  const slide = pptx.addSlide();

  if (usePng) {
    slide.addImage({
      data: `image/png;base64,${base64}`,
      x: 0, y: 0, w: SLIDE_W, h: SLIDE_H,
    });
  } else {
    slide.addImage({
      data: `image/jpeg;base64,${base64}`,
      x: 0, y: 0, w: SLIDE_W, h: SLIDE_H,
    });
  }

  console.log(`    第 ${pngFiles.indexOf(file) + 1}/${pngFiles.length} 页: ${file}`);
}

(async () => {
  try {
    await pptx.writeFile({ fileName: outputPath });
    console.log(`  PPTX 已保存: ${outputPath}`);

    const stats = fs.statSync(outputPath);
    const sizeMB = (stats.size / 1024 / 1024).toFixed(1);
    console.log(`  文件大小: ${sizeMB} MB`);
  } catch (err) {
    console.error(`  错误: PPTX 写入失败 — ${err.message}`);
    process.exit(1);
  }
})();
