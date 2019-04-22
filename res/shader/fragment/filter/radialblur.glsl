#include filter
#include math
#include color
#include noise

uniform float strength;
uniform float scanlines;

const float k = 1.0;
const float a = 0.005;

void main() {
  vec3 cc = texture2D(src, uv).xyz;
  vec3 c = cc;

  vec3 tw = vec3(1.0);
  float w = 1.0;
  vec2 dir = (uv - 0.5);
  dir *= k;
  dir = sign(dir) * pow2(dir);
  dir /= k;
  vec2 uvp = uv;
  for (int i = 0; i < 32; ++i) {
    w *= 0.9;
    uvp += a * dir;
    c += w * texture2D(src, uvp).xyz;
    tw += w;
  }
  c /= tw;
  float r = length(2.0 * uv - 1.0);
  float f1 = 1.0 - exp(-2.0 * r*r);
  float f2 = 1.0 - exp(-r);
  // c *= 1.0 + f * 0.5 * (1.0 - pow(-log(1.0 - noise(uv * 38.0)), 0.25));
  c = mix(c,
    c * (1.0 + f2 * vec3(0.5, 0.2, 0.1) * sin(radians(180.0) * gl_FragCoord.y)),
    scanlines);

  // c = mix(c, c * sqrt(c / lum(c)), f2);
  // c = mix(c, vec3(lum(c)), f1);

  c = mix(cc, c, strength);
  gl_FragColor = vec4(c, 1.0);
}
