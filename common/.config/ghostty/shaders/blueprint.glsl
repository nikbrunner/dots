// Blueprint grid. Theme-agnostic: derives its color from the terminal's own
// background, so it tracks light/dark without reading the palette (Ghostty
// exposes no palette uniform).

const float CELL      = 22.0; // minor cell size in px
const float MAJOR     = 5.0;  // heavy line every N cells
const float MINOR_W   = 1.0;
const float MAJOR_W   = 1.2;
const float DASH      = 5.0;  // dash period in px
const float DASH_DUTY = 0.55; // lit fraction of the dash period
const float TICK      = 3.5;  // crosshair arm length in px, at major joins

const float MINOR_A   = 0.22;
const float MAJOR_A   = 0.42;
const float TICK_A    = 0.55;
const float CONTRAST  = 0.22; // how far the grid pushes away from background

const float DRIFT_TAU = 0.28; // approach time constant; ~95% settled at 3x this
const float DRIFT_MAX = 55.0; // px of travel between opposite screen edges
const float SWAY      = 1.1;  // px of idle breathing
const float SWAY_RATE = 0.22;

const float PARALLAX_MAJOR = 0.35;  // major sheet drifts slower than the minor
const float FADE_RADIUS    = 380.0; // px, grid clears around the cursor
const float FADE_DEPTH     = 1.0;   // ink removed at the center of that circle

const float HOP_MIN  = 45.0;  // px of cursor travel below which paper ignores it
const float HOP_FULL = 220.0; // px at which a jump earns the full shift

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
    float d = abs(fract(coord / CELL) - 0.5) * CELL;
    return 1.0 - smoothstep(width * 0.5 - 0.5, width * 0.5 + 0.5, d);
}

float dashMask(float along) {
    return step(fract(along / DASH), DASH_DUTY);
}

bool isMajor(float coord) {
    float cell = floor(coord / CELL);
    return abs(fract(cell / MAJOR)) < 0.001;
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
    vec2 toJoin = abs(fract(pMajor / CELL) - 0.5) * CELL;
    float armX = (1.0 - smoothstep(TICK - 1.0, TICK + 1.0, toJoin.x)) * hMajor;
    float armY = (1.0 - smoothstep(TICK - 1.0, TICK + 1.0, toJoin.y)) * vMajor;
    float tick = max(armX * lineMask(pMajor.y, MAJOR_W),
                     armY * lineMask(pMajor.x, MAJOR_W));

    float ink = max(max(minor * MINOR_A, major * MAJOR_A), tick * TICK_A);

    // Clear the paper where the work is. Cursor xy is its top-left corner.
    vec2 cursorMid = iCurrentCursor.xy + vec2(iCurrentCursor.z, -iCurrentCursor.w) * 0.5;
    float toCursor = distance(fragCoord, cursorMid);
    ink *= 1.0 - FADE_DEPTH * (1.0 - smoothstep(0.0, FADE_RADIUS, toCursor));

    // Light background darkens, dark background lightens.
    vec3 target = vec3(1.0 - step(0.5, luminance(bg)));
    vec3 grid   = mix(bg, target, CONTRAST);

    fragColor = vec4(mix(src, grid, ink * (1.0 - textness)), 1.0);
}
