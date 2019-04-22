#include filter
#include math
#include color

uniform float amount;

void main() {
  vec3 c = texture2D(src, uv).xyz;
  vec2 uvp = vec2(1.0) - abs(2.0 * uv - vec2(1.0));
  c *= 1.0 - amount * exp(-8.0 * uvp.y);
  gl_FragColor = vec4(c, 1.0);
}
