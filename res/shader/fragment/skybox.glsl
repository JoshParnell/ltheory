#include fragment
#include deferred
#include gamma
#include color
#include fog

#autovar samplerCube envMap
#autovar samplerCube irMap

void main() {
  vec3 V = normalize(vertPos);
  vec3 c = textureCube(envMap, V).xyz;

  gl_FragDepth = 1.0;

  setAlbedo(linear(c.xyz));
  setAlpha(1.0);
  setDepth();
  setNormal(-normalize(vertPos));
  setRoughness(0);
  setMaterial(Material_NoShade);
}
