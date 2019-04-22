#include fragment
#include noise

uniform sampler2D src;
uniform vec2 size;
uniform float strength;
uniform float scroll;

void main() {
  vec4 c1 = texture2D(src, uv);
  vec2 p = size * uv;
  p.x += scroll;
  float mag = -0.4 * log(1.001 - pow(valueNoise(p / 2.0), 4.0));
  float sgn = 2.0 * valueNoise(p.x / 2.0) - 1.0;
  float dv = sgn * mag;
  vec4 c2 = texture2D(src, uv + vec2(0, dv));

  c2.xyz = pow(c2.xyz, vec3(1.2, 1.1, 0.6));
  gl_FragColor = max(c1, strength * c2);
}
