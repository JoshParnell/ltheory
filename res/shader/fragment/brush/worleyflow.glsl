#include brush
#include noise

void main() {
  BRUSH_BEGIN
  float a = brushAlpha * exp(-pow(r, brushHardness));
  vec2 v = vec2(
    fCellNoise(vec2(p / brushSize + 1337.3713), 1000.0 * brushSeed, 16, 2.0),
    fCellNoise(vec2(p / brushSize), 2000.0 * brushSeed, 16, 2.0));
  v = normalize(2.0 * v - 1.0);
  vec3 sample = 1.1 * texture2D(canvas, uv + brushSize * v / canvasSize).xyz;
  BRUSH_OUTPUT(mix(canvasColor, sample * (0.5 + 0.5 * brushColor), a));
}
