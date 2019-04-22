#include fragment
#include math
#include noise

uniform vec3 color;
uniform float alpha;
uniform vec2 size;
uniform float seed;

void main() {
  float u = uv.x;
  float v = uv.y;
  float a = 0.0;
  vec2 offset = seed * 137.0 + vec2(33.0);
  // u += 0.1 * (2.0 * fSmoothNoise(vec3(uv * size / 8.0 + offset, 4.0 * alpha), 8, 2.0 - alpha) - 1.0);
  u = max(0.0, abs(u) - 0.01);
  a += exp(-sqrt(256.0 * u));
  a += exp(-sqrt(128.0 * u));
  a += exp(-sqrt(64.0 * u));
  a += 0.5 * exp(-sqrt(32.0 * u));
  // a *= 1.0 + 4.0 * fSmoothNoise(uv * size / 8.0 + offset, 4, 2.0);
  a *= saturate(pow2(32.0 * v)) * pow8(1.0 - v);
  gl_FragColor = vec4(a * pow2(alpha) * pow2(color), 1.0);
}
