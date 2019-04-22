#include fragment
#include gamma
#include math
#include noise
#include color

#autovar samplerCube irMap
uniform sampler2D texDust;

void main() {
  vec3 V = pos - eye;
  float dist = length(V) / 1024.0;
  vec4 bg = textureCubeLod(irMap, V, 2.0);
  vec3 c = mix(vec3(0.2), mix(bg.xyz, 0.75 * sqrt(bg.xyz), 0.25), 0.8);
  float a = texture2D(texDust, 0.5 + 0.5 * uv).x;
  a *= saturate((1.0 - dist) / 0.25);
  a *= saturate(dist / 0.25);
  a *= 0.75;
  a = saturate(a);
  a *= a;
  gl_FragColor = vec4(linear(c), a);
  FRAGMENT_CORRECT_DEPTH;
}
