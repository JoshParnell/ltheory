#include fragment
#include math

uniform float brushSize;
uniform vec3 brushColor;
uniform vec3 brushPos;

void main() {
  float r = length(brushPos - vertPos.xyz);
  float alpha = exp(-pow2(r / brushSize));
  gl_FragColor = vec4(brushColor, alpha);
}
