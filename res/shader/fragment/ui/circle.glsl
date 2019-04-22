#include fragment
#include math

uniform vec4 color;
uniform vec2 size;
uniform float radius;

void main() {
  float r = length(size * (uv - 0.5));
  float d  = r / size.x;
  float dc = max(0.0, r - radius) / (size.x);
  float alpha = 0.0;
  alpha += 2.0 * exp(-pow2(64.0 * d));
  alpha += 1.0 * exp(-pow(32.0 * d, 0.75));
  vec3 c = 2.0 * color.xyz;
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
