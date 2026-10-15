// Records a web page as a looping animated WebP on a virtual clock. Usage: see ../references/browser.md.
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, statSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { parseArgs } from "node:util";

const { values } = parseArgs({
  options: {
    url: { type: "string" },
    out: { type: "string" },
    steps: { type: "string" },
    clip: { type: "string" },
    viewport: { type: "string", default: "1280x800" },
    scheme: { type: "string", default: "light" },
    fps: { type: "string", default: "50" },
    scale: { type: "string", default: "1" },
    quality: { type: "string", default: "lossless" }
  }
});
if (!values.url || !values.out || !values.steps) {
  console.error("Need --url, --out <file.webp>, and --steps <file.json>.");
  process.exit(1);
}

let chromium;
try {
  ({ chromium } = createRequire(join(process.cwd(), "package.json"))("playwright"));
} catch {
  console.error("playwright does not resolve from this directory. Run from a project that has it, or `npm i -D playwright`.");
  process.exit(1);
}

const steps = JSON.parse(readFileSync(values.steps, "utf8"));
const [width, height] = values.viewport.split("x").map(Number);
const dt = 1000 / Number(values.fps);
const origin = new URL(values.url).origin;
const backdrop = values.scheme === "dark" ? "#1a1a1a" : "#e6eaea";
const work = mkdtempSync(join(tmpdir(), "record-clip-"));
const browser = await chromium.launch();

try {
  const page = await browser.newPage({
    viewport: { width, height },
    deviceScaleFactor: Number(values.scale),
    colorScheme: values.scheme
  });
  await page.route(`${origin}/__record-clip.html`, route =>
    route.fulfill({
      contentType: "text/html",
      body: `<!doctype html><style>html,body{margin:0;height:100%;background:${backdrop};overflow:hidden}iframe{display:block;margin:0 auto;border:0;height:100%;width:${width}px}</style><iframe id="f" src="${values.url}"></iframe>`
    })
  );
  await page.goto(`${origin}/__record-clip.html`);
  const frame = await (await page.$("#f")).contentFrame();
  await frame.waitForLoadState("networkidle");
  await frame.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(800);

  let clip;
  if (values.clip) {
    const box = await frame.locator(values.clip).first().boundingBox();
    clip = { x: Math.max(0, box.x - 24), y: Math.max(0, box.y - 24), width: box.width + 48, height: box.height + 48 };
  }

  let t = 0;
  let count = 0;
  const shoot = async () => {
    await frame.evaluate(holdAnimations, t);
    await page.screenshot({ path: join(work, `f${String(count++).padStart(5, "0")}.png`), clip });
  };
  const advance = async (ms, each) => {
    const n = Math.max(1, Math.round(ms / dt));
    for (let i = 1; i <= n; i++) {
      t += dt;
      if (each) await each(i / n);
      await shoot();
    }
  };

  await shoot();
  for (const step of steps) {
    if (step.wait) await advance(step.wait);
    if (step.resize) {
      const [from, to, ms] = step.resize;
      await advance(ms, p => page.evaluate(w => (document.getElementById("f").style.width = `${w}px`), from + (to - from) * ease(p)));
    }
    if (step.click) await frame.locator(step.click).first().click();
    if (step.press) await page.keyboard.press(step.press);
  }

  const encode = values.quality === "lossless" ? ["-define", "webp:lossless=true"] : ["-quality", values.quality];
  execFileSync("magick", ["-delay", `1x${values.fps}`, "-loop", "0", join(work, "f*.png"), ...encode, "-define", "webp:method=4", values.out]);
  const kb = Math.round(statSync(values.out).size / 1024);
  console.log(`${values.out}: ${count} frames at ${values.fps} fps, ${(t / 1000).toFixed(2)}s, ${kb} KB`);
} finally {
  await browser.close();
  rmSync(work, { recursive: true, force: true });
}

// Runs in the page: pins every CSS animation and transition to the virtual clock, keeping the progress it had when first seen.
function holdAnimations(t) {
  const starts = (window.__recordClipStarts ??= new WeakMap());
  for (const a of document.getAnimations()) {
    if (!starts.has(a)) starts.set(a, t - (a.currentTime ?? 0));
    a.pause();
    a.currentTime = t - starts.get(a);
  }
}

function ease(p) {
  return p < 0.5 ? 4 * p * p * p : 1 - (-2 * p + 2) ** 3 / 2;
}
