#include fragment
#include color
#include math
#include noise
#include texcube
#include quat

uniform float seed;
uniform vec3 color;
uniform vec4 rot;
uniform samplerCube src;

const float kRoughness  = 0.7;
const int kIterations   = 32;

float magic(vec3 p) {
  vec4 z = vec4(vec3(0.53) + 0.25 * p, 0.0);
  float a = 0.0, l = 0.0, tw = 0.0, w = 1.0;

  vec4 c = vec4(
    0.51,
    0.49,
    0.52,
    0.48);
  for (int i = 0; i < kIterations; ++i) {
    float m = dot(z, z);
    z = abs(z) / m - c;
    z += 0.40 * (2.0 * noise4(float(i) + seed) - 1.0);
    z += 0.02 * sin(z);
    a += w * exp(-m*m);
    tw += w;
    w = pow(i + 1.0, -1.8);
    l = m;
    c = c.yzwx;
  }
  a /= tw;
  // a = cos(2 * PI * a + PI / 2);
  a = pow2(abs(a - 0.5) / 0.5);
  return a;
}

void main() {
  vec3 dir = cubeMapDir(uv);
  vec4 radiance = textureCube(src, dir);
  dir = normalize(quatMul(rot, dir));
  float emit = magic(dir);
  float d = sqrt(max(0.0, 1.0 - dot(dir, vec3(1, 0, 0))));
  float scatter = 1.0 - exp(-radiance.w);
  float mult =
    16.000 * exp(-1024.0 * d) +
    1.000 * exp(-512.0 * d) +
    2.000 * exp(-16.0 * d) +
    0.200 * exp(-8.0 * d) +
    0.100 * exp(-4.0 * d);
  // mult += 0.5 * emit;
  mult *= scatter;
  radiance.xyz += mult * (1.0 - exp(-exp(0.2 * color) * color));
  gl_FragColor = radiance;
}
