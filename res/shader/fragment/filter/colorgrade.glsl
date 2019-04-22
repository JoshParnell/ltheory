#include fragment
#include color
#include math

uniform sampler2D src;
uniform sampler1D curve1;
uniform sampler1D curve2;
const vec2 rDir = vec2(1, 0);
const vec2 gDir = vec2(0, 1);
const vec2 bDir = vec2(1, 0);

const float colorPoints = 256.0;
const float kVariation = 1.0;

void main() {
  vec3 original = saturate(texture2D(src, uv).xyz);
  original = (original * (colorPoints - 1.0) + 0.5) / colorPoints;
  vec3 c = original;

  c.x = mix(
    texture1D(curve1, c.x).x,
    texture1D(curve2, c.x).x,
    kVariation * dot(uv, rDir));

  c.y = mix(
    texture1D(curve1, c.y).y,
    texture1D(curve2, c.y).y,
    kVariation * dot(uv, gDir));

  c.z = mix(
    texture1D(curve1, c.z).z,
    texture1D(curve2, c.z).z,
    kVariation * dot(uv, bDir));

  c *= avg(original) / max(0.00001, avg(c));
  gl_FragColor = vec4(c, 1.0);
}
