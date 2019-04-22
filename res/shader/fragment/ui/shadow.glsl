#include fragment
#include math

uniform float radius;
uniform float padding;
uniform float alpha;
uniform float innerAlpha;
uniform vec2 size;

float roundBox(vec2 p, vec2 s, float b) {
  return length(max(vec2(0.0, 0.0), abs(p) - (s - 2.0 * vec2(b, b)))) - b;
}

void main() {
  vec2 p = size * (2.0 * uv - vec2(1.0));
  float d = roundBox(p, size + vec2(radius) - 2.0 * padding, radius);
  float a = (d < 0.0) ? innerAlpha : alpha;
  vec3 c = vec3(0.01);
  a *= exp(-pow2(0.015 * max(0.0, d)));
  gl_FragColor = vec4(c, a);
}
