#ifndef include_lighting
#define include_lighting

#include color
#include math

uniform samplerCube envMap;
uniform samplerCube envMapLF;
uniform samplerCube irMap;

uniform vec3 ambient;
uniform vec3 eye;
uniform float fogDensity;
uniform vec2 rcpFrame;
uniform vec3 starColor;
uniform vec3 starPos;

const float kDynamicLightMult = 16.0;

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

#if 0
vec3 getFog(vec3 ro, vec3 rd, float depth, float occlusion) {
  vec3 c = vec3(0.0);
  float d = 1.0 - dot(rd, normalize(starPos - ro));
  float l = exp(-pow2(8.0 * d));
  float lod = mix(2.0, 4.0, saturate((farPlane - depth) / farPlane));
  c += 0.1 * (1.0 - occlusion) * l * linear(texLod(envMap, rd, lod).xyz);
  vec3 bg = linear(texLod(irMap, rd, lod).xyz);
  c += bg;
  return c;
}
#endif

float getFoginess(float depth) {
  float d = 1.0 * fogDensity * (depth / farPlane);

  /* NOTE - Do not fking change the power.  You've gone back and forth on
   *        it a million times, and I'm tired of you getting it wrong.
   *  0.5 - TOO GLOBAL.  Obfuscates near objects way too much.
   *        Totally ruins the beauty of objects in dust.
   *  2.0 - TOO LOCAL.  Can't see anything long-distance. Total loss of
   *        context in dust.
   *  1.0 - JUST RIGHT.  Leave it.  Stop poking it. */
  return 1.0 - exp(-pow(d, 1.0));

}

#endif
