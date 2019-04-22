#include fragment

uniform float strength;
uniform sampler2D src;
uniform sampler2D srcBlur;

void main() {
  vec3 c = texture2D(src, uv).xyz;
  vec3 mask = texture2D(srcBlur, uv).xyz;
  vec3 hp = c - mask;
  c += strength * hp;
  gl_FragColor = vec4(c, 1.0);
}
