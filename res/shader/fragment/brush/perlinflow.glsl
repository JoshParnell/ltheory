#include brush
#include noise

void main() {
  BRUSH_BEGIN
  float a = brushAlpha * exp(-pow(r, brushHardness));
  vec2 v = vec2(
    fSmoothNoise(vec3(p / brushSize + 1234.37 * brushSeed, brushTime), 8, 1.7),
    fSmoothNoise(vec3(p / brushSize + 3333.0 * brushSeed, brushTime), 8, 1.7));
  v = normalize(2.0 * v - 1.0);
  vec3 sample = 1.01 * texture2D(canvas, uv + brushSize * v / canvasSize).xyz;
  BRUSH_OUTPUT(mix(canvasColor, sample * brushColor, a));
}
