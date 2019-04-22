#include fragment
#include deferred
#include gamma
#include texturing
#include color
#include math
#include fog

#autovar samplerCube irMap
#autovar samplerCube envMap
#autovar vec3 eye

uniform float scale;
uniform float edgeDarkness;
uniform sampler2D texDiffuse;
uniform sampler2D texDiffuseUV;
uniform sampler2D texPaintUV;
uniform sampler2D texNormal;
uniform sampler2D texSpec;

float glossToLOD(float gloss) {
  return 8.0 * (pow(2.0, gloss) - 1.0);
}

void main() {
  vec3 N = normalize(normal);
  vec3 uvw = sqrt(scale / 32.0) * abs(vertPos.xyz);
  vec3 diff = texture2D(texDiffuseUV, uv).xyz;

#if 1
  diff *= mix(vec3(1.0 - edgeDarkness), vec3(1.0), exp(-sqrt(1024.0 * length(N - normal)));
#endif

  float gloss = 1.0 - sampleTriplanar(texSpec, uvw).x;

#if 0
  vec3 vn = normalize(vertNormal);
  vec3 blend = vn * vn;
  vec2 uvt = vec2(uv.x, uv.y);
  vec3 bump = sampleTriplanarBumpmap(texNormal, uvw).xyz;
  vec3 Q1  = dFdx(pos), Q2 = dFdy(pos);
  vec2 st1 = dFdx(uvt), st2 = dFdy(uvt);
  vec3 T = normalize(Q1 * st2.y - Q2 * st1.y);
  vec3 B = normalize(Q2 * st1.x - Q1 * st2.x);
  mat3 TBN = mat3(T, B, 1.0 * N);
  N = normalize(TBN * bump);
#endif

  vec3 V = normalize(pos - eye);
  vec3 R = normalize(reflect(V, N));

#if 0
  vec3 color = 0.0 * pow2(vec3(0.1, 0.3, 1.0));
  float freq = 8;
  float paint = min(
    exp(-256.0 * max(0.0, abs(2.0 * fract(freq * vertPos.x) - 1.0) - 0.5)),
    exp(-256.0 * max(0.0, abs(2.0 * fract(freq * vertPos.z) - 1.0) - 0.5)));
  gloss = mix(gloss, 0.0, paint);
#endif

  vec4 paint = texture2D(texPaintUV, uv);

  float u = uv.x;
  const float K = 5.0;
  vec3 c = diff;
  c = mix(c, paint.xyz, paint.w);
  #ifdef HIGHQ
    c *= textureCubeLod(irMap, R, glossToLOD(gloss)).xyz;
  #else
    c *= textureCube(envMap, R).xyz;
  #endif
  // c *= u;
  c *= K;
  c = mix(c, textureCubeLod(envMap, V, 4.0).xyz, getFog());
  float lod = glossToLOD(gloss);

  FRAGMENT_CORRECT_DEPTH;

  setAlbedo(c);
  setAlpha(1.0);
  setDepth();
  setNormal(N);
  setRoughness(gloss);
  setMaterial(Material_Metal);
}
