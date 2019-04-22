#include fragment
#include color
#include math

uniform vec3 color;
uniform float alpha;

void main() {
  float r = length(uv);
  float a = 0.0;
  a += exp(-sqrt(256.0 * r));
  a += exp(-sqrt(128.0 * r));
  a *= 4.0;
  vec3 c = color;
  c *= c / avg(c);
  gl_FragColor = vec4(a * alpha * c, 1.0);
  FRAGMENT_CORRECT_DEPTH;
}
