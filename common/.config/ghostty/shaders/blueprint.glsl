// Blueprint grid. Theme-agnostic: derives its color from the terminal's own
// background, so it tracks light/dark without reading the palette (Ghostty
// exposes no palette uniform).

// ── The four knobs ──────────────────────────────────────────────────────────
// Everything below derives from these. Reach past them only to change what the
// sheet *is*, not how strong, how big, how lively, or how busy it looks.

const float INTENSITY = 0.35; // overall ink strength against the background
const float SCALE     = 1.0;  // minor cell as a multiple of one terminal row
const float MOTION    = 2.0;  // drift and sway multiplier; 0.0 pins the paper
const float DETAIL    = 1.0;  // decoration presence; 0.0 leaves a bare grid

// ── Derived ─────────────────────────────────────────────────────────────────

// The cursor is exactly one cell, so its height is the font size. Ghostty has
// no font-size uniform; this is the way to read it. Guarded because the cursor
// can report zero height while hidden.
float cellSize() {
    float row = clamp(iCurrentCursor.w, 8.0, 80.0);
    return row * SCALE;
}

const float MAJOR     = 6.0;  // heavy line every N cells
const float MINOR_W   = 1.0;
const float MAJOR_W   = 1.2;
const float DASH_DUTY = 0.55; // lit fraction of the dash period

const float CONTRAST  = INTENSITY;
const float MINOR_A   = 0.30;
const float MAJOR_A   = 0.42;
const float TICK_A    = 0.55;

const float DRIFT_TAU = 0.28;           // ~95% settled at 3x this
const float DRIFT_MAX = 55.0 * MOTION;  // px of travel between opposite edges
const float SWAY      = 1.1 * MOTION;   // px of idle breathing
const float SWAY_RATE = 0.22;

const float PARALLAX_MAJOR = 0.35; // major sheet drifts slower than the minor
const float PARALLAX_DECO  = 0.15; // deepest sheet, so it drifts the least

const float HOP_MIN  = 45.0;  // px of cursor travel below which paper ignores it
const float HOP_FULL = 220.0; // px at which a jump earns the full shift

const float EDGE_FADE  = 320.0; // px inset over which the grid falls off
const float EDGE_DEPTH = 1.0;   // ink removed at the window border

const float DECO_W          = 1.5; // heavier than the grid, so marks read drawn on
const float DECO_A          = 0.30 * DETAIL;
const float DECO_PROT_R_CELLS   = 5.0;   // protractor radius, in minor cells
const float DECO_SCALE_STEP_REL = 0.467; // ruler tick spacing, per minor cell
const float DECO_NUM        = 2.0; // px per bitmap pixel, so digits are 6x10

// Text covers a small fraction of a terminal, so a spread average is dominated
// by background. Gives us both the light/dark bit and the glyph-mask reference.
vec3 sampleBackground() {
    vec3 acc = vec3(0.0);
    for (int y = 0; y < 3; y++) {
        for (int x = 0; x < 3; x++) {
            vec2 uv = (vec2(float(x), float(y)) + 0.5) / 3.0;
            acc += texture(iChannel0, uv).rgb;
        }
    }
    return acc / 9.0;
}

float luminance(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

// Distance in px to the nearest gridline, per axis.
float lineMask(float coord, float width) {
    float cell = cellSize();
    float d = abs(fract(coord / cell) - 0.5) * cell;
    return 1.0 - smoothstep(width * 0.5 - 0.5, width * 0.5 + 0.5, d);
}

float dashMask(float along) {
    return step(fract(along / (cellSize() * 0.167)), DASH_DUTY);
}

bool isMajor(float coord) {
    float n = floor(coord / cellSize());
    return abs(fract(n / MAJOR)) < 0.001;
}

// Digits as 3x5 bitmaps, rows packed low bit first, three bits per row.
float digitBits(int d) {
    if (d == 0) return 31599.0; if (d == 1) return 18724.0;
    if (d == 2) return 31183.0; if (d == 3) return 31207.0;
    if (d == 4) return 23524.0; if (d == 5) return 29671.0;
    if (d == 6) return 29679.0; if (d == 7) return 31012.0;
    if (d == 8) return 31727.0; if (d == 9) return 31719.0;
    return 0.0;
}

// One digit in a 3x5 cell. `p` is relative to the glyph's lower-left corner.
float glyph(vec2 p, int d, float scale) {
    vec2 c = floor(p / scale);
    if (c.x < 0.0 || c.x > 2.0 || c.y < 0.0 || c.y > 4.0) return 0.0;
    float bit = (4.0 - c.y) * 3.0 + c.x;
    return mod(floor(digitBits(d) / pow(2.0, bit)), 2.0);
}

// A whole number, right-growing from `origin`.
float number(vec2 p, vec2 origin, int value, float scale) {
    float ink = 0.0;
    int v = value;
    int digits = (v >= 100) ? 3 : ((v >= 10) ? 2 : 1);
    for (int i = 0; i < 3; i++) {
        if (i >= digits) break;
        int place = (digits - 1 - i);
        int div = (place == 2) ? 100 : ((place == 1) ? 10 : 1);
        int d = (v / div) - (v / (div * 10)) * 10;
        vec2 off = vec2(float(i) * 4.0 * scale, 0.0);
        ink = max(ink, glyph(p - origin - off, d, scale));
    }
    return ink;
}

// Perpendicular distance to an infinite line, as a stroke.
float strokeLine(vec2 p, vec2 origin, float angle, float width) {
    vec2 dir = vec2(cos(angle), sin(angle));
    vec2 rel = p - origin;
    float d = abs(rel.x * dir.y - rel.y * dir.x);
    return 1.0 - smoothstep(width - 0.5, width + 0.5, d);
}

// A circle's outline, optionally only part of the way round.
float strokeArc(vec2 p, vec2 origin, float radius, float width,
                float fromAngle, float toAngle) {
    vec2 rel = p - origin;
    float d = abs(length(rel) - radius);
    float ring = 1.0 - smoothstep(width - 0.5, width + 0.5, d);
    float a = atan(rel.y, rel.x);
    return ring * step(fromAngle, a) * step(a, toAngle);
}

// A finite segment rather than an infinite line: ends where the stroke stops.
float strokeSegment(vec2 p, vec2 a, vec2 b, float width) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return 1.0 - smoothstep(width - 0.5, width + 0.5, length(pa - ba * h));
}

// A ruler edge: ticks perpendicular to `angle`, every `spacing`, every fifth
// one longer, running for `len` from the origin.
float strokeScale(vec2 p, vec2 origin, float angle, float len,
                  float spacing, float width) {
    vec2 dir = vec2(cos(angle), sin(angle));
    vec2 nrm = vec2(-dir.y, dir.x);
    vec2 rel = p - origin;
    float along = dot(rel, dir);
    float off   = dot(rel, nrm);
    if (along < 0.0 || along > len) return 0.0;

    float idx  = floor(along / spacing + 0.5);
    float snap = idx * spacing;
    float tall = (abs(fract(idx / 5.0)) < 0.001) ? 9.0 : 4.5;
    if (off < 0.0 || off > tall) return 0.0;

    return 1.0 - smoothstep(width - 0.5, width + 0.5, abs(along - snap));
}

// Radiating ticks around a centre, as on a protractor.
float strokeRadial(vec2 p, vec2 origin, float radius, float len,
                   float stepDeg, float width) {
    vec2 rel = p - origin;
    float r = length(rel);
    if (r < radius || r > radius + len) return 0.0;

    float deg = atan(rel.y, rel.x) * 57.29578;
    float snap = floor(deg / stepDeg + 0.5) * stepDeg;
    float arc = abs(deg - snap) * 0.01745 * r;
    return 1.0 - smoothstep(width - 0.5, width + 0.5, arc);
}

// Where the paper rests for a given cursor position. A fragment shader keeps no
// state between frames, so the offset is a function of position rather than a
// sum of past moves: it settles somewhere new and stays, and cannot run away.
vec2 restOffset(vec2 cursor) {
    vec2 centered = (cursor - iResolution.xy * 0.5) / iResolution.y;
    return -centered * DRIFT_MAX;
}

vec2 paperOffset() {
    vec2 from = restOffset(iPreviousCursor.xy);
    vec2 to   = restOffset(iCurrentCursor.xy);

    // Line-stepping restarts the clock on every keypress, which without this
    // reads as jitter: each press re-enters the steep part of the curve. Short
    // hops are damped toward the previous rest, so only real jumps move paper.
    float hop = distance(iCurrentCursor.xy, iPreviousCursor.xy);
    to = mix(from, to, smoothstep(HOP_MIN, HOP_FULL, hop));

    // Exponential approach rather than a fixed-length tween. An interrupting move
    // inherits whatever position the last one reached, so reversals stay smooth
    // instead of snapping back to the previous cursor's resting spot.
    float t = max(iTime - iTimeCursorChange, 0.0);
    vec2 drift = mix(from, to, 1.0 - exp(-t / DRIFT_TAU));

    // Never fully still, so it reads as hovering rather than parked.
    vec2 sway = vec2(sin(iTime * SWAY_RATE), cos(iTime * SWAY_RATE * 0.73)) * SWAY;

    return drift + sway;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv  = fragCoord / iResolution.xy;
    vec3 src = texture(iChannel0, uv).rgb;
    vec3 bg  = sampleBackground();

    // 0 at background, 1 on a glyph. Keeps the grid off the text.
    float textness = smoothstep(0.02, 0.20, distance(src, bg));

    // Two sheets at different heights. The majors lag, so the pair reads as
    // depth rather than one flat texture sliding.
    vec2 drift = paperOffset();
    vec2 pMinor = fragCoord + drift;
    vec2 pMajor = fragCoord + drift * PARALLAX_MAJOR;

    // Minor sheet: dashed, skipping the cells the major sheet owns.
    float vMinorLine = lineMask(pMinor.x, MINOR_W) * dashMask(pMinor.y)
                     * (isMajor(pMinor.x) ? 0.0 : 1.0);
    float hMinorLine = lineMask(pMinor.y, MINOR_W) * dashMask(pMinor.x)
                     * (isMajor(pMinor.y) ? 0.0 : 1.0);
    float minor = max(vMinorLine, hMinorLine);

    // Major sheet: solid, every MAJOR-th line in its own space.
    float vMajor = isMajor(pMajor.x) ? 1.0 : 0.0;
    float hMajor = isMajor(pMajor.y) ? 1.0 : 0.0;
    float vMajorLine = lineMask(pMajor.x, MAJOR_W) * vMajor;
    float hMajorLine = lineMask(pMajor.y, MAJOR_W) * hMajor;
    float major = max(vMajorLine, hMajorLine);

    // Crosshair ticks where major lines would cross.
    float cell = cellSize();
    float arm = cell * 0.117;
    vec2 toJoin = abs(fract(pMajor / cell) - 0.5) * cell;
    float armX = (1.0 - smoothstep(arm - 1.0, arm + 1.0, toJoin.x)) * hMajor;
    float armY = (1.0 - smoothstep(arm - 1.0, arm + 1.0, toJoin.y)) * vMajor;
    float tick = max(armX * lineMask(pMajor.y, MAJOR_W),
                     armY * lineMask(pMajor.x, MAJOR_W));

    // Decoration sheet: the deepest layer, so it drifts least.
    vec2 sheet = iResolution.xy;
    vec2 pDeco = fragCoord + drift * PARALLAX_DECO;
    float deco = 0.0;

    // Everything is set out from one corner, the way the mat's angle guides are.
    // Scattering marks at unrelated spots is what reads as random.
    vec2 origin = sheet * vec2(0.88, 0.86);

    // The angle fan: long guides radiating from that origin across the sheet.
    deco = max(deco, strokeLine(pDeco, origin, 3.4034, DECO_W)); // 195
    deco = max(deco, strokeLine(pDeco, origin, 3.6652, DECO_W)); // 210
    deco = max(deco, strokeLine(pDeco, origin, 3.9270, DECO_W)); // 225
    deco = max(deco, strokeLine(pDeco, origin, 4.1888, DECO_W)); // 240
    deco = max(deco, strokeLine(pDeco, origin, 4.4506, DECO_W)); // 255

    // Protractor at the origin: small and densely ticked, as on the real mat.
    float protR = cellSize() * DECO_PROT_R_CELLS;
    deco = max(deco, strokeArc(pDeco, origin, protR, DECO_W, -3.14159265, 0.0));
    deco = max(deco, strokeRadial(pDeco, origin, protR, 7.0, 5.0, DECO_W));
    deco = max(deco, strokeRadial(pDeco, origin, protR - 4.0, 4.0, 15.0, DECO_W));

    // Angle marks where two guides cross: small arcs spanning the wedge between
    // them, which is what makes a crossing look measured rather than incidental.
    vec2 cross1 = origin + vec2(cos(3.9270), sin(3.9270)) * sheet.y * 0.30;
    deco = max(deco, strokeArc(pDeco, cross1, 26.0, DECO_W, -3.6, -2.0));
    vec2 cross2 = origin + vec2(cos(3.6652), sin(3.6652)) * sheet.y * 0.52;
    deco = max(deco, strokeArc(pDeco, cross2, 20.0, DECO_W, -3.9, -2.4));

    // Ruler edges along the two axes through the origin.
    float scaleStep = cellSize() * DECO_SCALE_STEP_REL;
    float scaleLenH = sheet.x * 0.80;
    float scaleLenV = sheet.y * 0.78;
    deco = max(deco, strokeScale(pDeco, origin, 3.14159265, scaleLenH,
                                 scaleStep, DECO_W));
    deco = max(deco, strokeScale(pDeco, origin, -1.5708, scaleLenV,
                                 scaleStep, DECO_W));

    // Numbers against every fifth tick, where the scale runs long.
    float major5 = scaleStep * 5.0;
    vec2 relH = pDeco - origin;
    if (relH.y < -8.0 && relH.y > -(8.0 + 5.0 * DECO_NUM) && relH.x < 0.0
        && relH.x > -scaleLenH) {
        float idx = floor(-relH.x / major5 + 0.5);
        vec2 base = vec2(-idx * major5 + 3.0, -8.0 - 5.0 * DECO_NUM);
        deco = max(deco, number(relH, base, int(idx) * 5, DECO_NUM));
    }
    vec2 relV = pDeco - origin;
    if (relV.x < -8.0 && relV.x > -(8.0 + 12.0 * DECO_NUM) && relV.y < 0.0
        && relV.y > -scaleLenV) {
        float idx = floor(-relV.y / major5 + 0.5);
        vec2 base = vec2(-8.0 - 12.0 * DECO_NUM, -idx * major5 - 2.0 * DECO_NUM);
        deco = max(deco, number(relV, base, int(idx) * 5, DECO_NUM));
    }

    float ink = max(max(max(minor * MINOR_A, major * MAJOR_A), tick * TICK_A),
                    deco * DECO_A);

    // Let the sheet fall off toward the frame instead of being cut by it.
    vec2 toEdge = min(fragCoord, iResolution.xy - fragCoord);
    float edge = min(smoothstep(0.0, EDGE_FADE, toEdge.x),
                     smoothstep(0.0, EDGE_FADE, toEdge.y));
    ink *= mix(1.0 - EDGE_DEPTH, 1.0, edge);

    // Light background darkens, dark background lightens.
    vec3 target = vec3(1.0 - step(0.5, luminance(bg)));
    vec3 grid   = mix(bg, target, CONTRAST);

    fragColor = vec4(mix(src, grid, ink * (1.0 - textness)), 1.0);
}
