#include filter

void main() {
  gl_FragColor = log(vec4(1.0) + texture2D(src, uv));
}
