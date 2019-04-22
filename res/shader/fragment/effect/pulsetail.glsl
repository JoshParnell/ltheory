#include fragment
#include math

uniform vec3 axis;
uniform vec3 color;
uniform float alpha;

void main() {
  float u = uv.x;
  float v = uv.y;
  float a = 0.0;
  v = 1.0 + v;

  float iv = 1.0 - v;
  u = max(0.0, abs(u) - 0.010);
  v = saturate(v);
  a += 1.5 * exp(-sqrt(128.0 * u)) * v;
  a *= exp(-8.0 * iv);
  a *= 1.0 - exp(-pow2(32.0 * iv));
  a *= 4.0;
  vec3 c = color;
  c *= c / avg(c);
  gl_FragColor = vec4(a * alpha * c, 1.0);
  FRAGMENT_CORRECT_DEPTH;
}
