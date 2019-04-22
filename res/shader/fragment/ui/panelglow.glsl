#include fragment
#include math

uniform float padding;
uniform vec2 size;
uniform vec4 color;

const float bevel = 8.0;

float dbox(vec2 p, vec2 s, float b) {
  return length(max(vec2(0.0, 0.0), abs(p) - (s - 2.0 * vec2(b, b)))) - b;
}

void main() {
  float x = size.x * (2.0 * uv.x - 1.0);
  float y = size.y * (2.0 * uv.y - 1.0);

  float d = dbox(vec2(x, y), size + bevel - 2.0 * padding, bevel);
  float k = exp(-max(0.0, d));
  float alpha = 1.0;
  alpha *= saturate(exp(-pow(0.2 * max(0.0, d), 0.75)) - k);

  vec3 c = 2.0 * color.xyz;
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
