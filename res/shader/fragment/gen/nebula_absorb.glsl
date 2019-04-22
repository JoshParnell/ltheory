#include fragment
#include color
#include math
#include noise
#include texcube
#include quat

uniform float density;
uniform float seed;
uniform vec4 rot;
uniform samplerCube src;

const int kIterations = 24;

float magic(vec3 p) {
  vec4 z = vec4(vec3(0.53) + p, 0.0);
  float a = 0.0, l = 0.0, tw = 0.0, w = 1.0;

  vec4 c = vec4(
    0.21,
    0.49,
    0.52,
    0.48);
  for (int i = 0; i < kIterations; ++i) {
    float m = dot(z, z);
    z = abs(z) / m - c;
    z += 0.20 * (2.0 * noise4(float(i) + seed) - 1.0);
    z += 0.25 * sin(z);
    a += w * exp(-pow2(m - l));
    tw += w;
    w = pow(float(1 + i), -2.0);
    l = m;
    c = c.yzwx;
  }
  a /= tw;
  a = 4.0 * density * pow2(max(0.0, a - 0.5) / 0.5);
  return a;
}

void main() {
  vec3 dir = cubeMapDir(uv);
  vec4 radiance = textureCube(src, dir);
  dir = quatMul(rot, dir);
  float od = magic(dir);
  radiance.xyz *= exp(-od / normalize(0.0001 + radiance.xyz));
  radiance.w += od;
  gl_FragColor = radiance;
}
