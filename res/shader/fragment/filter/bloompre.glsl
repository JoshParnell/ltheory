#include fragment
#include math
#include color

uniform sampler2D src;

void main() {
  vec3 c = texture2D(src, uv).xyz;
  float a = lum(c);
  // c *= (1.0 - exp(-lum(c))) / lum(c);
  gl_FragColor = vec4(c, a);
}
