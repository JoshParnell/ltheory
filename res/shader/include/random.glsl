#ifndef include_random
#define include_random

/* NOTE : Unlike the 'hash'-style functions in noise.glsl, these random
          functions are intended to be high-quality rather than fast. They are
          primarily for ground-truth / non-real-time renders or GPU computation
          passes. The lower-quality but significantly-faster noise.glsl
          functions should be used for real-time shaders. */

#ifndef TAU
#define TAU 6.28318530718 
#endif

/* Uniform sample on unit circle. */
vec2 randDir2 (float u) {
  float t = TAU * u;
  return vec2(cos(t), sin(t));
}

/* Uniform sample on the surface of unit disc. */
vec2 randDisc (vec2 uv) {
  float t = TAU * uv.x;
  float r = sqrt(uv.y);
  return r * vec2(cos(t), sin(t));
}

/* Uniform sample on surface of unit sphere. */
vec3 randDir3 (vec2 uv) {
  float t = TAU * uv.x;
  float z = 2.0 * uv.y - 1.0;
  float r = sqrt(1.0 - z*z);
  return vec3(r * cos(t), r * sin(t), z);
}

/* Uniform sample within spherical volume. */
vec3 randSphere (vec3 uvw) {
  float t = TAU * uv.x;
  float z = 2.0 * uv.y - 1.0;
  float r = sqrt(1.0 - z*z);
  float R = pow(uvw.z, 1.0 / 3.0);
  return R * vec3(r * cos(t), r * sin(t), z);
}

#endif
