#include filter
#include math
#include color
#include noise

uniform float strength;

const float k = 1.00;
const float a = 0.0002;

void main() {
  vec3 cc = texture2D(src, uv).xyz;
  vec3 c = cc;
  vec3 tw = vec3(1.0);
  vec2 dir = uv - 0.5;
  dir *= k;
  dir = sign(dir) * pow2(dir);
  dir = a * normalize(dir);
  vec2 uvp = uv;
  for (int i = -8; i <= 8; ++i) {
    vec3 w = pow(vec3(1.5, 1.00, 0.50), vec3(float(i) / 4.0));
    c += w * texture2D(src, uvp + float(i) * dir).xyz;
    tw += w;
  }
  c /= tw;
  c = lum(cc) * (c / lum(c));
  c = mix(cc, c, strength);
  gl_FragColor = vec4(c, 1.0);
}
