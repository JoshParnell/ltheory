#include fragment
#include math
#include gamma
#include color

uniform sampler2D src;
uniform sampler2D srcBlur;

const float kBright = 0.15;
const float kDark   = 0.10;

void main() {
  vec3 c1 = texture2D(src, uv).xyz;
  vec4 cc2 = texture2D(srcBlur, uv);
  vec3 c2 = cc2.xyz;
  float c2w = cc2.w;
  c1 = max(c1, vec3(0.0));
  c2 = max(c2, vec3(0.0));
  float l1 = avg(c1);
  float l2 = avg(c2);

  vec3 c = c1;

  vec3 dark = sqrt(c1 * c2);
  vec3 f1 = (c2 / avg(c2)) * (1.0 - exp(-1.25 * avg(c2))) * exp(-4.0 * c1);
  // vec3 f1 = c2 * exp(-4.0 * c1);
  float f2 = exp(-l1);

  // c = mix(c, c2, f2 * kBright);
  c = mix(c, c2, f1 * kBright);
  c = mix(c, dark, f2 * kDark);
  // c = mix(c, c2, 0.9999);

  gl_FragColor = vec4(c, 1.0);
}
