#include fragment

uniform vec2 size;
uniform vec4 color;

const float kRadius = 8.0;

void main() {
  vec2 realSize = size - vec2(64.0);
  vec2 uvp = (2.0 * uv - vec2(1.0));

  float r = min(kRadius, min(realSize.x, realSize.y));
  float dist = length(max(vec2(0.0), size * abs(uvp) - (realSize - r))) - r;
  float alpha = 0.0;
  alpha += 0.6 * exp(-0.5 * max(0.0, dist));
  alpha += 0.4 * exp(-pow(0.3 * max(0.0, dist), 0.75));
  gl_FragColor = alpha * color.w * vec4(2.0 * color.xyz, 1.0);
}
