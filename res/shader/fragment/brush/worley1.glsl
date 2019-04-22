#include brush
#include noise

void main() {
  BRUSH_BEGIN
  float a = brushAlpha * exp(-pow(r, 1.0));
  a *= exp(-pow(2.0 * fCellNoise(p / brushSize, 1000.0 * brushSeed, 24, 1.5), 1.5));
  BRUSH_OUTPUT(canvasColor * exp(-a * canvasColor / normalize(pow(brushColor, vec3(4.0)))));
}
