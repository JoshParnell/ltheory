#include fragment
#include deferred
#include gamma
#include fdm
#include color
#include math
#include fog

#autovar vec3 eye
#autovar samplerCube envMap
#autovar samplerCube irMap

uniform sampler2D texDiffuse;
uniform float scale;

void main() {
  vec3 N = normalize(normal);
  vec3 V = normalize(pos - eye);
  vec3 c = linear(sampleFDM(texDiffuse, scale * vertPos.xyz).xyz);
  c *= radians(360.0);
  c *= uv.x;
  c *= c;
  // c *= textureCubeLod(envMap, N, 9.0).xyz;
  // c = applyFog(c, V);

  FRAGMENT_CORRECT_DEPTH;

  setAlbedo(c);
  setAlpha(1.0);
  setDepth();
  setNormal(N);
  setRoughness(1.0);
  setMaterial(Material_Diffuse);
}
