#include brush
#include noise

void main() {
  BRUSH_BEGIN
  float a = brushAlpha * exp(-pow(r, brushHardness));
  BRUSH_OUTPUT(canvasColor * exp(-a * canvasColor / normalize(pow(brushColor, vec3(4.0)))));
}
