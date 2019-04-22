#include fragment
#include deferred
#include math
#include pbr

#autovar vec3 eye

varying vec3 worldOrigin;
varying vec3 worldDir;

uniform vec3 lightColor;
uniform vec3 lightPos;

uniform sampler2D texNormalMat;
uniform sampler2D texDepth;

const float kMinDistance = 0.0001;
const float kPointLightMult = 16.0;

void main () {
  vec4 normalMat = texture2D(texNormalMat, uv);
  float depth = texture2D(texDepth, uv).x;
  vec3 N = decodeNormal(normalMat.xy);
  float rough = normalMat.z;
  float mat = normalMat.w;

  vec3 p = worldOrigin + depth * normalize(worldDir);

  vec3 light = vec3(0.0);

  if (mat == Material_Diffuse) {
    vec3 L = lightPos - p;
    float Lmag = 1.0 / max(kMinDistance, length(L));
    light += lightColor * Lmag * saturate(dot(N, L * Lmag));
  }

  else if (mat == Material_Metal) {
    vec3 L = lightPos - p;
    float Lmag = 1.0 / max(kMinDistance, length(L));
    light += lightColor * Lmag * cookTorrance(L * Lmag, p, N, rough, 1.0);
  }

  light *= kPointLightMult;

  gl_FragData[0] = vec4(light, 1.0);
}
