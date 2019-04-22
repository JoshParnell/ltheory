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
uniform vec4 paintAttrib;
uniform vec4 paintColor;

// const vec4 paintAttrib = vec4(0.01, 2.0, 0.5, 0.0);
// const vec4 paintColor = vec4(3.0 * 0.1, 3.0 * 0.6, 3.0 * 1.0, 1.0);

uniform sampler2D texDiffuse;
uniform sampler2D texNormal;
uniform sampler2D texSpec;

#define ENABLE_PAINT 1
#define ENABLE_BUMPMAP 0

void main() {
  vec3 N = normalize(normal);
  vec3 uvw = sqrt(scale / 16.0) * abs(vertPos.xyz);
  vec3 diff = linear(sampleTriplanar(texDiffuse, uvw).xyz);
  float gloss = 1.0 - sampleTriplanar(texSpec, uvw).x;

#if ENABLE_BUMPMAP
  {
    vec3 vn = normalize(vertNormal);
    vec3 blend = vn * vn;
    vec2 uvt =
      blend.x * uvw.yz + 
      blend.y * uvw.zx +
      blend.z * uvw.xy;

    vec3 bump = sampleTriplanarBumpmap(texNormal, uvw).xyz;
    vec3 Q1  = dFdx(pos), Q2 = dFdy(pos);
    vec2 st1 = dFdx(uvt), st2 = dFdy(uvt);
    vec3 T = normalize(Q1 * st2.y - Q2 * st1.y);
    vec3 B = normalize(Q2 * st1.x - Q1 * st2.x);
    mat3 TBN = mat3(T, B, 4.0 * N);
    N = normalize(TBN * bump);
  }
#endif

  vec3 V = normalize(pos - eye);
  vec3 R = normalize(reflect(V, N));

#if ENABLE_PAINT
  {
    float paintGloss = paintAttrib.x;
    float paintScale = paintAttrib.y;
    float paintShape = paintAttrib.z;
    float paintPhase = paintAttrib.w;
    float freq = 1.0 / paintScale;
    float r = sqrt(length(freq * vertPos.xz));
    float x = mix(sqrt(abs(freq * vertPos.y)), r, paintShape) + paintPhase;
    float alpha =
        0.25 * exp(-256.0 * max(0.0, abs(2.0 * fract(x) - 1.0) - 0.75))
      + 0.75 * exp(-256.0 * max(0.0, abs(2.0 * fract(x) - 1.0) - 0.25));
    alpha *= paintColor.w;
    gloss = mix(gloss, paintGloss, alpha);
    diff = mix(diff, sqrt(diff) * paintColor.xyz, alpha);
  }
#endif

  vec3 c = diff;
  c *= 3.0 * radians(360.0);
  c *= uv.x;

  FRAGMENT_CORRECT_DEPTH;

  setAlbedo(c);
  setAlpha(1.0);
  setDepth();
  setNormal(N);
  setRoughness(gloss);
  setMaterial(Material_Metal);
}
