#include fragment

uniform vec3 color;

void main() {
  gl_FragColor = vec4(color, uv.x);
}
