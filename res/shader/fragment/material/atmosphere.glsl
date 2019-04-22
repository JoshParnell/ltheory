#include fragment
#include math
#include color
#include noise
#include scattering2

#autovar vec3 eye
#autovar vec3 starDir

uniform vec3 origin;

void main() {
  vec3 L = starDir;
  vec3 N = normalize(normal);
  vec3 V = normalize(pos - eye);
  vec4 atmo = atmosphereDefault(V, eye - origin);
  float depth = length(pos - eye);
  float a = exp(-max(0.0, depth / (1.0e6) - 1.0) / 0.01);
  a = 1.0;
  vec4 c = a * vec4(atmo.xyz, atmo.w);
  gl_FragColor = c;
  FRAGMENT_CORRECT_DEPTH;
}
