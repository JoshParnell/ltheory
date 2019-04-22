#include fragment
#include math
#include noise
#include texcube

uniform float seed;
uniform float freq;
uniform float power;
uniform vec4 coef;

float genClouds(vec3 p) {
  p += 0.5 * vec3(
    fCellNoise(p, seed + 1.0, 4, 1.3),
    fCellNoise(p, seed + 5.0, 4, 1.3),
    fCellNoise(p, seed + 8.0, 4, 1.3));
  return 0.5 + 0.5 * sin(8.0 * frCellNoise(p, seed + 6.0, 12, 1.4));
}

float genColor(vec3 p) {
  vec4 z = vec4(p / 4.0 + 0.75, 0.3);
  float a = 0.0, l = 0.0, w = 1.0;
  for (int i = 0; i < 24; ++i) {
    float m = dot(z, z);
    z = abs(z) / m - vec4(0.4, 0.5, 0.6, 0.4);
    z += 0.1 * log(1.0e-10 + noise4(float(i) + seed + 58.329));
    z *= 1.0 + 0.25 * noise(float(i) + seed * 5.0 + 12.0);
    z = z.yzwx;
    m = coef.x*z.x*z.x + coef.y*z.y*z.y + coef.z*z.z*z.z + coef.w*z.w*z.w;
    a += w * exp(-m);
    w *= 0.85;
    l = m;
  }
  return 0.5 + 0.5 * sin(4.0 * a);
}

float genHeight(vec3 p) {
  vec4 z = vec4(p / 4.0 + 0.75, 0.3);
  float a = 0.0, l = 0.0, w = 1.0;
  for (int i = 0; i < 32; ++i) {
    float m = dot(z, z);
    z = abs(z) / m - vec4(0.4, 0.5, 0.6, 0.3);
    z += 0.1 * log(1.0e-10 + noise4(float(i) + seed));
    z *= 1.0 + 0.25 * noise(float(i) + seed * 2.0 + 32.0);
    z = z.yzwx;
    m = coef.x*z.x*z.x + coef.y*z.y*z.y + coef.z*z.z*z.z + coef.w*z.w*z.w;
    if (i > 0) {
      a += w * exp(-abs(m - l));
      w *= 0.8 + 0.2 * (2.0 * noise(seed + 3.3 * float(i)) - 1.0);
    }
    l = m;
  }
  return gain(pow(0.5 + 0.5 * sin(freq * a), power), 4.0);
}

void main() {
  vec3 p = cubeMapDir(uv);
  gl_FragColor = vec4(genHeight(p), genColor(p), genClouds(p), 0.0);
}
