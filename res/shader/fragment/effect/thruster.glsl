#include fragment
#include gamma
#include math
#include noise

uniform float alpha;
uniform float time;
uniform vec3 color;

void main() {
  float u = uv.x;
  float v = saturate(uv.y);
  float uw = max(0.0, abs(u) - 0.25 * sqrt(v));
  float a = exp(-12.0 * uw) + 0.25 * exp(-12.0 * sqrt(uw));
  a *= (1.0 - exp(-pow2(16.0 * v))) * exp(-10.0 * v);
  a *= 1.0 + 4.0 * exp(-12.0 * v);
  float variation = pow2(fSmoothNoise(vec2(uv.x, 20.0 * v - 10.0 * time), 2, 1.6));
  a *= mix(1.0, 1.5, variation);
  // a *= 1.0 - getFoginess(length(position - eye));
  a *= 2.0;
  gl_FragColor = vec4(alpha * a * color, 1.0);
  FRAGMENT_CORRECT_DEPTH;
}
