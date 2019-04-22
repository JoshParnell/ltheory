#include filter
#include math
#include noise

void main() {
  vec3 c = texture2D(src, uv).xyz;
  c -= (2.0 * noise3(noise(uv * 16.0)) - vec3(1.0)) / 256.0;
  gl_FragColor = vec4(saturate(c), 1.0);
}
