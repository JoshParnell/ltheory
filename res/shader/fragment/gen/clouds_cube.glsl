#include fragment
#include color
#include math
#include noise
#include texcube

void main() {
  vec3 dir = cubeMapDir(uv);
  float xp = 2.0 * pow2(fSmoothNoise(dir + vec3(2, 3, 5), 4, 1.8)) - 1.0;
  float yp = 2.0 * pow2(fSmoothNoise(dir + vec3(7, 11, 13), 4, 1.8)) - 1.0;
  float zp = 2.0 * pow2(fSmoothNoise(dir + vec3(17, 19, 23), 4, 1.8)) - 1.0;
  vec3 dir2 = normalize(dir + 0.4 * normalize(vec3(xp, yp, zp)));

  const float seed = 1337.0;
  float lac = 1.0 + 1.0 * fSmoothNoise(4.0 * dir + vec3(27, 31, 37), 10, 1.8);
  float thresh = 0.3 * fSmoothNoise(4.0 * dir + vec3(127, 131, 137), 10, 1.8);
  float d = 1.0 - exp(-6.0 * pow2(frCellNoise(1.0 * dir2, seed + 33.3, 10, lac)));
  d = mix(d, 1.0 - exp(-6.0 * pow2(frCellNoise(2.0 * dir, seed, 10, lac))), 0.5);
  // d *= fSmoothNoise(dir + vec3(41, 45, 99), 4, lac);
  d = smoothstep(0.0, 1.0, max(0.0, d - thresh));
  // d *= frCellNoise(dir, 2.0 * seed + 33.0, 8, lac);
  d = saturate(d);
  gl_FragColor = vec4(d);
}
