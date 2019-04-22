#include filter

const float K = 1.50;
const float P = 1.25;

void main() {
  vec3 c = texture2D(src, uv).xyz;
  c = vec3(1.0) - 1.0 / (vec3(1.0) + K * pow(c, vec3(P)));
  gl_FragColor = vec4(c, 1.0);
}
