#include fragment
#include math

uniform vec4 color;

const float scale = 1.0;

void main() {
  vec2 uvp = 2.0 * uv - vec2(1.0, 1.0);
  float r = scale * length(uvp);
  float alpha = 0.0;
  alpha += exp(-258.0 * max(0.0, r - 0.01));
  alpha += 0.1 * exp(-pow(8.0 * r, 0.75));
  vec3 c = 2.0 * color.xyz;
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
