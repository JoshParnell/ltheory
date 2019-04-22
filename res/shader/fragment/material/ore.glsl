#include fragment
#include deferred
#include gamma
#include fdm
#include color
#include math
#include fog

#autovar vec3 eye
#autovar samplerCube envMap

uniform sampler2D texDiffuse;
uniform float scale;

void main() {
  vec3 N = normalize(normal);
  vec3 V = normalize(pos - eye);
  vec3 R = normalize(reflect(V, N));

  vec3 c = sampleFDM(texDiffuse, scale * vertPos.xyz).xyz;
  c *= 8.0 * c;
  c *= (1.0 + c.x * c.x * vec3(1.0, 3.0, 5.0));
  float rough = saturate(c.x * c.x);
  vec3 env = textureCubeLod(envMap, R, 0.0).xyz;
  c = sqrt(c * env * env);
  c = applyFog(c, V);

  FRAGMENT_CORRECT_DEPTH;

  setAlbedo(c);
  setAlpha(1.0);
  setDepth();
  setNormal(N);
  setRoughness(0.9);
  setMaterial(Material_Diffuse);
}
