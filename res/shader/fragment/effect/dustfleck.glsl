#include fragment
#include color
#include math

#autovar vec3 eye

uniform vec2 size;

void main() {
  float dist = length(pos - eye);
  float alpha = exp(-pow2(2.0 * uv.x));
  alpha *= 0.1;
  alpha *= 1.0 - exp(-8.0 * uv.y);
  alpha *= 1.0 - exp(-8.0 * (1.0 - uv.y));
  alpha *= 1.0 - pow4(1.0 - uv.y);
  alpha *= exp(-4.0 * max(0.0, dist / 1024.0 - 0.8));
  alpha *= 1.0 - exp(-16.0 * max(0.0, dist / 1024.0 - 0.1));
  vec3 c = 1.0 / mix(
    vec3(0.1, 0.5, 1.0),
    vec3(1.0, 0.5, 0.1),
    1.0 - uv.y);
  c = c / lum(c);
  c *= sqrt(c);
  gl_FragColor = vec4(c * alpha, 1.0);
}
