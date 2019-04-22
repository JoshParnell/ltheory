#ifndef include_pbr
#define include_pbr

#include random

/* (Approximate) GGX microsurface distribution sample in NTB frame.
   w : GGX width (1.0 = maximally diffuse) */
vec3 ggx (vec2 uv, float w) {
  float yaw = TAU * uv.x;
  float pitch = atan(w * sqrt(uv.y), sqrt(1.0 - uv.y));
  float sp = sin(pitch);
  return vec3(cos(pitch), sp * sin(yaw), sp * cos(yaw));
}

/* Cook-Torrance model. Pulled from LTC++, likely needs to be double-checked for
   correctness. */
float cookTorrance(vec3 L, vec3 position, vec3 N, float R2, float spec) {
  vec3 V = normalize(eye - position);
  vec3 H = normalize(L + V);

  float NL = max(0.0000001, dot(N, L));
  float NH = max(0.000001, dot(N, H));
  float NV = max(0.000001, dot(N, V));
  float VH = max(0.000001, dot(V, H));
  float NH2 = NH * NH;

  float G1 = (2.0 * NH * NV) / VH;
  float G2 = (2.0 * NH * NL) / VH;
  float geom = min(1.0, min(G1, G2));

  float denom = 4.0 * R2 * NH2 * NH2;
  float num = exp((NH2 - 1.0) / (R2 * NH2));
  float rough = num / denom;

  float fs = pow(saturate(1.0 - VH), 5.0);
  float fsg = exp2((-5.55473 * VH - 6.98316) * VH);
  float fresnel = mix(1.0, fsg, 0.25);

  float speccoef = fresnel * (geom * rough) / (NV * NL * 3.14159);
  return NL * mix(1.0, speccoef, spec);
}

#endif
