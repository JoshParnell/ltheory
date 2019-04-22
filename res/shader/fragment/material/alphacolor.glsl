#include fragment

uniform vec4 color;

void main() {
  gl_FragColor = color;
  FRAGMENT_CORRECT_DEPTH;
}
