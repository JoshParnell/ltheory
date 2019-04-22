#include fragment
#include math
#include color

uniform sampler2D src;
uniform sampler2D srcBlur;
uniform float strength;

vec3 normalum (vec3 x) {
  return x / lum(x);
}

void main() {
  vec3 c1 = texture2D(src, uv).xyz;
  vec4 c2w = texture2D(srcBlur, uv);
  vec3 c2 = c2w.xyz;
  float w = c2w.w;
  
  c1 = max(c1, vec3(0.0));
  c2 = max(c2, vec3(0.0));
  float l1 = lum(c1);
  float l2 = lum(c2);

  vec3 c = c1;
  vec3 dark = sqrt(c1 * c2);
  c = mix(c, dark, 0.1);
  c += 0.25 * strength * mix(normalum(c2), normalum(vec3(0.1, 0.3, 1.0)), 0.4) * pow(lum(c2), 1.5);
  gl_FragColor = vec4(c, 1.0);
}
