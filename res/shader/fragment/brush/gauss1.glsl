#include brush

void main() {
  BRUSH_BEGIN
  float a = brushAlpha * exp(-pow(r, brushHardness));
  BRUSH_OUTPUT(canvasColor + a * brushColor);
}
