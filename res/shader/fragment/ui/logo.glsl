#include fragment
#include noise
#include color

uniform sampler2D src;
uniform vec2 size;
uniform float alpha;
uniform float strength;
uniform float scroll;

void main() {
  vec4 c1 = texture2D(src, uv);
  vec2 p = size * uv;
  p.x += scroll;
  float mag = -0.4 * log(1.001 - pow(valueNoise(p / vec2(2.0)), 6.0));
  p.x += scroll;
  float sgn = 2.0 * valueNoise(p.x / 2.0) - 1.0;
  float dv = sgn * mag;
  vec4 c2 = texture2D(src, uv + vec2(0, dv));

  c2.xyz = pow(c2.xyz, vec3(1.2, 1.1, 0.6));
  vec4 c = max(c1, strength * c2);

  float a = 1.0;
  a *= 1.0 - exp(-6.0 * abs(1.0 - abs(2.0 * uv.y - 1.0)));

  gl_FragColor = vec4(c.xyz, a * alpha);
}
