#include fragment
#include math
#include color
#include noise
#include scattering2

#autovar vec3 eye
#autovar vec3 starDir

uniform samplerCube surface;
uniform vec3 origin;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec3 color4;
uniform float heightMult;
uniform float oceanLevel;

const float kSpecular = 1.0;
const vec3 kOceanColor = vec3(0.01, 0.13, 0.20);

float heightFn(float h, int octaves, float roughness) {
  float total = 1.0;
  float tw = 0.0;
  float f = PI;
  float w = 1.0;
  float off = 17.371;

  for (int i = 0; i < octaves; ++i) {
    total += w * (0.5 + 0.5 * sin(f * h + off));
    tw += w;
    w *= roughness;
    f *= 2.00;
    off += 2.3337;
  }
  total /= tw;
  return 1.0 - exp(-2.0 * pow2(max(0.0, total - 0.5)));
}

float visibility(
    samplerCube map, vec3 p, int octaves, float roughness,
    float offset, float radius, float strength)
{
  vec3 toStar = -starDir;
  const float samples = 8.0;
  float v = 0.0;
  float tw = 0.0;
  for (float i = 0.0; i < samples; ++i) {
    vec3 sp = normalize(mix(p, toStar, radius * (i + 1.0) / samples));
    float h = heightFn(textureCube(map, sp).x, octaves, roughness);
    float rh = h - (offset + (length(sp) - 1.0));
    v += exp(-strength * heightMult * max(0.0, rh));
  }
  return v / samples;
}

void main() {
  vec3 L = starDir;
  vec3 P = pos - origin;
  vec3 N = normalize(normal);
  vec3 V = normalize(pos - eye);
  float NL = dot(N, L);
  float light = mix(exp(-max(0.0, pow(1.0 - NL, 4.0))), 1.0, 0.01);

  vec4 map = textureCube(surface, vertPos);
  float dist = length((pos - eye) / rPlanet);
  float h1 = heightFn(map.x, 9, 0.70);
  float h2 = heightFn(map.x, 3, 0.20);

  vec3 color = mix(color1, color2, h1);
  color = 1.0 - exp(-pow2(3.0 * color));
  color *= visibility(surface, vertPos, 9, 0.70, h1, 0.002, 2.0);
  color = mix(color, kOceanColor, 1.0 - exp(-sqrt(16.0 * max(0.0, h2 - 0.8))));
  color *= light;

#if 0
  vec3 R = reflect(V, N);
  color +=
    kSpecular * ocean * kOceanColor * starColor *
    cookTorrance(L, pos, N, 0.01, 1.0);
#endif

#if 1
  vec4 atmo = atmosphereDefault(V, eye - origin);
  color = atmo.xyz + color * (1.0 - atmo.w);
#endif

  gl_FragColor = vec4(color, 1.0);
  FRAGMENT_CORRECT_DEPTH;
}
