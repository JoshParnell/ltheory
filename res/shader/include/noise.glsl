#ifndef include_noise
#define include_noise

/* --- Primitive ------------------------------------------------------------ */

float noise(float x) {
  return fract(sin(x) * 4137.31315);
}

float noise(vec2 x) {
  return noise(x.x + noise(x.y));
}

float noise(vec3 x) {
  return noise(x.x + noise(x.yz));
}

float noise(vec4 x) {
  return noise(x.x + noise(x.yzw));
}

vec2 noise2(float t) {
  return fract(sin(t) * vec2(4372.137, 8371.377));
}

vec3 noise3(float t) {
  return fract(sin(t) * vec3(4372.137, 8371.377, 1890.643));
}

vec4 noise4(float t) {
  return fract(sin(t) * vec4(4372.137, 8371.377, 1890.643, 7777.017));
}

/* --- Value ---------------------------------------------------------------- */

float valueNoise(float x) {
  float f = floor(x), i = fract(x);
  return mix(noise(f), noise(f + 1.0), i);
}

float valueNoise(vec2 x) {
  vec2 f = floor(x), i = fract(x);
  return mix(mix(noise(f + vec2(0.0, 0.0)), noise(f + vec2(1.0, 0.0)), i.x),
             mix(noise(f + vec2(0.0, 1.0)), noise(f + vec2(1.0, 1.0)), i.x), i.y);
}

float valueNoise(vec3 x) {
  vec3 f = floor(x), i = fract(x);
  return mix(mix(mix(noise(f + vec3(0.0, 0.0, 0.0)), noise(f + vec3(1.0, 0.0, 0.0)), i.x),
                 mix(noise(f + vec3(0.0, 1.0, 0.0)), noise(f + vec3(1.0, 1.0, 0.0)), i.x), i.y),
             mix(mix(noise(f + vec3(0.0, 0.0, 1.0)), noise(f + vec3(1.0, 0.0, 1.0)), i.x),
                 mix(noise(f + vec3(0.0, 1.0, 1.0)), noise(f + vec3(1.0, 1.0, 1.0)), i.x), i.y), i.z);
}

float length2(vec2 p) {
  return dot(p, p);
}

/* --- Smooth Value (Cubic) ------------------------------------------------- */

float smoothNoise(float p) {
  float f = floor(p), i = fract(p);
  return mix(noise(f), noise(f + 1.0), i * i * (3.0 - 2.0*i));
}

float smoothNoise(vec2 p) {
  vec2 f = floor(p), i = fract(p);
  i = i * i * (3.0 - 2.0*i);
  return mix(mix(noise(f + vec2(0.0, 0.0)), noise(f + vec2(1.0, 0.0)), i.x),
             mix(noise(f + vec2(0.0, 1.0)), noise(f + vec2(1.0, 1.0)), i.x), i.y);
}

float smoothNoise(vec3 p) {
  vec3 f = floor(p), i = fract(p);
  i = i * i * (3.0 - 2.0*i);
  return mix(mix(mix(noise(f + vec3(0.0, 0.0, 0.0)), noise(f + vec3(1.0, 0.0, 0.0)), i.x),
                 mix(noise(f + vec3(0.0, 1.0, 0.0)), noise(f + vec3(1.0, 1.0, 0.0)), i.x), i.y),
             mix(mix(noise(f + vec3(0.0, 0.0, 1.0)), noise(f + vec3(1.0, 0.0, 1.0)), i.x),
                 mix(noise(f + vec3(0.0, 1.0, 1.0)), noise(f + vec3(1.0, 1.0, 1.0)), i.x), i.y), i.z);
}

/* --- Cell ----------------------------------------------------------------- */

float cellNoise(vec2 p, float s) {
  vec2 f = floor(p);
  float d = 1e30;
  for (int xo = -1; xo <= 1; xo++) {
  for (int yo = -1; yo <= 1; yo++) {
    vec2 np = f + vec2(int(xo), int(yo));
    np += noise2(noise(vec3(np, s)));
    d = min(d, length2(p - np));
  }}
  return sqrt(max(0.0, d));
}

float cellNoise(vec3 p, float s) {
  vec3 f = floor(p);
  float d = 1e30;
  for (int xo = -1; xo <= 1; xo++) {
  for (int yo = -1; yo <= 1; yo++) {
  for (int zo = -1; zo <= 1; zo++) {
    vec3 np = f + vec3(int(xo), int(yo), int(zo));
    np += noise3(noise(vec4(np, s)));
    d = min(d, dot(p - np, p - np));
  }}}
  return sqrt(d);
}

float distMH(vec2 a, vec2 b) {
  return abs(a.x - b.x) + abs(a.y - b.y);
}

vec2 cellNoiseMH(vec2 p, float s) {
  vec2 f = floor(p);
  float d = 1e30;
  float d2 = 1e30;
  for (int xo = -1; xo <= 1; xo++) {
  for (int yo = -1; yo <= 1; yo++) {
    vec2 np = f + vec2(int(xo), int(yo));
    np += noise2(noise(vec3(np, s)));
    float dist = distMH(p, np);
    if (dist < d) {
      d2 = d;
      d = dist;
    } else if (dist < d2) {
      d2 = dist;
    }
  }}
  return vec2(d, d2);
}

/* --- Fractal Cell --------------------------------------------------------- */

float fCellNoise(vec2 p, float s, int octaves, float lac) {
  float a = 0.0, tw = 0.0, w = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * cellNoise(p, s + float(i));
    tw += w;
    w /= lac;
    p *= 2.0;
  }
  return a / tw;
}

float fCellNoise(vec3 p, float s, int octaves, float lac) {
  p *= 0.5;
  float a = 0.0, tw = 0.0, w = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * cellNoise(p, s);
    tw += w;
    w /= lac;
    p *= 2.0;
  }
  return a / tw;
}

/* --- Fractal Cell (Ridged) ------------------------------------------------ */

float frCellNoise(vec2 p, float s, int octaves, float lac) {
  float a = 0.0, tw = 0.0, w = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * abs(2.0 * cellNoise(p, s) - 1.0);
    tw += w;
    w /= lac;
    p *= 2.0;
  }
  return a / tw;
}

float frCellNoise(vec3 p, float s, int octaves, float lac) {
  float a = 0.0, tw = 0.0, w = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * abs(2.0 * cellNoise(p, s) - 1.0);
    tw += w;
    w /= lac;
    p *= 2.0;
  }
  return a / tw;
}

/* --- Fractal Smooth ------------------------------------------------------- */

float fSmoothNoise(float p, int octaves, float lac) {
  float a = 0.0, tw = 0.0, w = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * smoothNoise(p);
    tw += w;
    p *= 2.0;
    w /= lac;
  }
  return a / tw;
}

float fSmoothNoise(vec2 p, int octaves, float lac) {
  float a = 0.0, tw = 0.0, w = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * smoothNoise(p);
    tw += w;
    p *= 2.0;
    w /= lac;
  }
  return a / tw;
}

float fSmoothNoise(vec3 p, int octaves, float lac) {
  float a = 0.0, tw = 0.0, w = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * smoothNoise(p);
    tw += w;
    p *= 2.0;
    w /= lac;
  }
  return a / tw;
}

#endif
