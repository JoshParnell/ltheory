#include fragment

uniform float radius;
uniform vec2 size;
uniform vec4 color;

const float k = sqrt(3.0) / 2.0;

void main() {
  vec2 uvp = uv - 0.5;
  uvp = abs(size * uvp);
  float alpha = 0.0;
  float d = max(uvp.x * k + 0.5 * uvp.y, uvp.y) - radius;
  d = max(0.0, d);
  alpha += 0.5 * exp(-max(0.0, d - 0.5));
  alpha += 0.3 * exp(-pow(0.2 * d, 0.75));
  vec3 c = 2.0 * color.xyz;
  gl_FragColor = alpha * color.w * vec4(c.xyz, 1.0);
}
