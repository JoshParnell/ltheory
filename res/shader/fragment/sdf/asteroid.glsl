#include fragment
#include math
#include noise

uniform vec3 origin;
uniform vec3 du;
uniform vec3 dv;
uniform int octaves;
uniform float seed;
uniform float smoothness;

void main() {
  vec3 p = origin + du * uv.x + dv * uv.y;
  float n = fCellNoise(2.0 * p, seed, octaves, smoothness);
  float d = length(p) - mix(0.05, 1.0, n);
  gl_FragColor.x = d;
}
