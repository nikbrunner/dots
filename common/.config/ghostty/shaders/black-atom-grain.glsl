// Black Atom film grain for Ghostty
// Same grain as the Black Atom Industries website: soft blurred noise,
// re-rolled 12 times a second, soft-light on dark themes, multiply on light ones.
//
// Install (~/.config/ghostty/config):
//   custom-shader = ~/.config/ghostty/shaders/black-atom-grain.glsl
//   custom-shader-animation = true

// ---- settings ----
const float GRAIN      = 0.5;  // strength (website default .22)
const float GRAIN_SIZE = 0.65;   // grain size in points (website default .9)
const float FPS        = 10.0;  // how often the grain re-rolls
const float BLUR       = 1.35;   // softness of each grain, like the site's 0.9px blur
// dark themes: 0 = pure soft-light (strong on mid-tone colors, faint on near-black),
// 1 = flat grain with the same strength on every color
const float BALANCE    = 1.0;
// dark themes: how much weaker the grain gets on brighter backgrounds (0 = not at all)
const float TAME       = 0.6;
// 0 = detect from the background, 1 = always dark mode, 2 = always light mode
const int   MODE       = 0;

// frame is wrapped so the hash input stays small enough for float precision
float hash(vec2 p, float f) {
  vec3 q = fract(vec3(p, mod(f, 997.0)) * vec3(0.1031, 0.1030, 0.0973));
  q += dot(q, q.yxz + 33.33);
  return fract((q.x + q.y) * q.z);
}

// noise cell lookup with a small gaussian-ish blur over neighbours
float grainAt(vec2 px, float frame) {
  vec2 cell = floor(px);
  float sum = 0.0, wsum = 0.0;
  for (int x = -1; x <= 1; x++)
    for (int y = -1; y <= 1; y++) {
      vec2 o = vec2(x, y);
      vec2 c = cell + o;
      float d = length(c + 0.5 - px);
      float w = exp(-(d * d) / max(2.0 * BLUR * BLUR, 1e-3));
      sum += hash(c, frame) * w;
      wsum += w;
    }
  return sum / wsum;
}

vec3 softLight(vec3 cb, float cs) {
  vec3 d = mix(sqrt(cb), ((16.0 * cb - 12.0) * cb + 4.0) * cb, step(cb, vec3(0.25)));
  return cs <= 0.5 ? cb - (1.0 - 2.0 * cs) * cb * (1.0 - cb)
                   : cb + (2.0 * cs - 1.0) * (d - cb);
}

float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

bool isLight() {
  if (MODE == 1) return false;
  if (MODE == 2) return true;
  // sample the four corners, which are almost always background
  float l = luma(texture(iChannel0, vec2(0.004, 0.004)).rgb)
          + luma(texture(iChannel0, vec2(0.996, 0.004)).rgb)
          + luma(texture(iChannel0, vec2(0.004, 0.996)).rgb)
          + luma(texture(iChannel0, vec2(0.996, 0.996)).rgb);
  return l * 0.25 > 0.5;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  vec4 src = texture(iChannel0, uv);

  // 1 css px ≈ 2 device px on Retina; scale so the grain matches the website
  float scale = max(GRAIN_SIZE * 2.0, 0.5);
  float frame = floor(iTime * FPS);
  float n = grainAt(fragCoord / scale, frame);

  vec3 col;
  if (isLight()) {
    // light: darkening-only grain, half strength, multiply
    float lv = 1.0 - pow(n, 1.6) * (120.0 / 255.0);
    col = mix(src.rgb, src.rgb * lv, GRAIN * 0.5);
  } else {
    vec3 soft = softLight(src.rgb, n);
    vec3 even = src.rgb + (n - 0.5) * 0.3;
    float tame = 1.0 - TAME * smoothstep(0.08, 0.25, luma(src.rgb));
    col = mix(src.rgb, mix(soft, even, BALANCE), GRAIN * tame);
  }
  fragColor = vec4(col, src.a);
}
