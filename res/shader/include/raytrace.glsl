#ifndef include_raytrace
#define include_raytrace

#include random

vec3 getCameraRay (vec3 look, vec3 up, vec2 uv, float aspect, float fovyDeg) {
  uv = 2.0 * uv - 1.0;
  uv.x *= aspect;
  float dist = 1.0 / tan(radians(0.5 * fovyDeg));
  vec3 right = normalize(cross(up, look));
  up = cross(look, right);
  return normalize(uv.x * right + uv.y * up + dist * look);
}

/* Scatter a ray with uniform sphere sample perturbation + renormalization.
   r : radius of sphere, also 'roughness'
   Constant r in [0, 1] gives Lambertian (0 = mirror, 1 = ideal diffuse)
   Draw r from an infinte-tail distribution for more interesting BRDFs:
     r = roughness * sqrt(-log(1.0 - randf()))
     r = roughness / sqrt(randf()) */
vec3 rayScatter (vec3 dir, vec2 uv, float r) {
  vec3 s = randDir3(uv);
  return normalize(dir + r * s);
}

#endif
