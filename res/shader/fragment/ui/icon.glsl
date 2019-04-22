#include fragment

uniform vec4 color;
uniform sampler2D icon;

void main() {
  vec3 c = color.xyz;
  float alpha = texture2D(icon, uv).w;
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
