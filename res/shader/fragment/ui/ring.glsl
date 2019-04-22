#include fragment

uniform float radius;
uniform vec2 size;
uniform vec4 color;

void main() {
  vec2 uvp = uv - 0.5;
  float r = length(size * uvp);
  float alpha = 0.0;
  float d = abs(r - radius);
  alpha += 0.5 * exp(-max(0.0, d - 0.5));
  alpha += 0.4 * exp(-pow(0.2 * d, 0.75));
  vec3 c = 2.0 * color.xyz;
  gl_FragColor = alpha * color.w * vec4(c.xyz, 1.0);
}
