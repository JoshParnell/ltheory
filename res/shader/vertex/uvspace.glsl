#include vertex

void main() {
  VS_BEGIN
  gl_Position = vec4(
    2.0 * uv.x - 1.0,
    2.0 * uv.y - 1.0,
    0.0,
    1.0);
}
