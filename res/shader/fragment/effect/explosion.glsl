#include fragment
#include math
#include noise

uniform float age;
uniform float seed;
const float animSpeed = 0.4;

void main() {
  float t = animSpeed * age;
  float r = sqrt(length(uv));
  float rd = 0.3 * (2.0 * fSmoothNoise(2.0 * uv + 1337.0 * seed + 39.0, 6, 1.5) - 1.0);
  r = pow2(max(0.0, r + rd - (1.0 - exp(-t))));
  float a =
    10.0 * exp(-abs(128.0 * r)) +
     2.0 * exp(-abs(64.0 * r)) + 
     0.2 * exp(-sqrt(16.0 * r));
  a *= 2.0 * fSmoothNoise(2.0 * uv + 33.0, 4, 2.0);
  a *= exp(-5.0 * max(0.0, t));
  a *= 1.0 - exp(-32.0 * max(0.0, t));
  vec3 c = mix(mix(
    vec3(1.0, 0.2, 0.0),
    vec3(1.0, 0.5, 0.2), a),
    vec3(4.0, 2.0, 1.0), a);
  gl_FragColor = vec4(c * a, 1.0);
  FRAGMENT_CORRECT_DEPTH;
}
