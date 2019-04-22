#include brush
#include color
#include noise

void main() {
  BRUSH_BEGIN
  float a = brushAlpha * exp(-pow(r, brushHardness));
  float l = lum(canvasColor);
  vec3 dc = mix(canvasColor, vec3(l), saturate(a * brushColor));
  dc *= l / lum(dc);
  BRUSH_OUTPUT(dc);
}
