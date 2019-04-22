#include fragment
#include color
#include deferred
#include gamma
#include math

void main() {
  vec3 N = normalize(vertNormal);
  vec3 c = mix(
    mix(vec3(0.2, 0.1, 0.5), vec3(0.5, 0.0, 0.2), max(0.0, -N.y)),
    mix(vec3(0.2, 0.1, 0.5), vec3(0.2, 0.6, 1.0), max(0.0,  N.y)),
    0.5 + 0.5 * N.y);
  c = mix(c, vec3(0.5, 0.5, 0.5), 0.25);

  float f = 0.2;
  vec3 cc = 1.0 * vec3(1.0, 1.0, 1.0);

  N *= N;
  N *= N;

#if 0
  const float scale = 0.1;
  for (int i = 0; i < 4; ++i) {
    c -= cc * step(0.0, abs(2.0 * fract(f * pos.x * scale) - 1.0) - pow(0.95, f))
      * (1.0 - N.x);
    c -= cc * step(0.0, abs(2.0 * fract(f * pos.y * scale) - 1.0) - pow(0.95, f))
      * (1.0 - N.y);
    c -= cc * step(0.0, abs(2.0 * fract(f * pos.z * scale) - 1.0) - pow(0.95, f))
      * (1.0 - N.z);
    f *= 2.0;
    cc *= 0.5;
  }
#endif

  c = max(c, vec3(0.0, 0.0, 0.0));
  c *= uv.x * uv.x;

  FRAGMENT_CORRECT_DEPTH;

  setAlbedo(linear(c));
  setAlpha(1.0);
  setDepth();
  setMaterial(Material_NoShade);
  setNormal(N);
  setRoughness(0.0);
}
