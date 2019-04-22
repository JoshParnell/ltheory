#include fragment
#include math
#include noise

uniform vec3 origin;
uniform vec3 du;
uniform vec3 dv;
uniform int octaves;
uniform float seed;
uniform float smoothness;

float smoothNoiseT(vec3 p, float tileFreq) {
  vec3 f = floor(p), i = fract(p);
  i = i * i * (3.0 - 2.0*i);
  return mix(
    mix(
      mix(noise(fract(tileFreq * (f + vec3(0.0, 0.0, 0.0)))),
          noise(fract(tileFreq * (f + vec3(1.0, 0.0, 0.0)))), i.x),
      mix(noise(fract(tileFreq * (f + vec3(0.0, 1.0, 0.0)))),
          noise(fract(tileFreq * (f + vec3(1.0, 1.0, 0.0)))), i.x), i.y),
    mix(
      mix(noise(fract(tileFreq * (f + vec3(0.0, 0.0, 1.0)))),
          noise(fract(tileFreq * (f + vec3(1.0, 0.0, 1.0)))), i.x),
      mix(noise(fract(tileFreq * (f + vec3(0.0, 1.0, 1.0)))),
          noise(fract(tileFreq * (f + vec3(1.0, 1.0, 1.0)))), i.x), i.y), i.z);
}

float fSmoothNoiseT(vec3 p, int octaves, float lac) {
  float a = 0.0, tw = 0.0, w = 1.0;
  float tileFreq = 1.0;
  for (int i = 0; i < octaves; i++) {
    a += w * smoothNoiseT(p, tileFreq);
    tw += w;
    p *= 2.0;
    tileFreq *= 0.5;
    w /= lac;
  }
  return a / tw;
}

void main() {
  vec3 p = origin + du * uv.x + dv * uv.y;
  float n = fSmoothNoiseT(p + seed * vec3(2.0, 3.0, 5.0), octaves, smoothness);
  n = exp(-pow2(4.0 * (n - 0.5)));
  float d = n;
  gl_FragColor.x = n;
}
