#include brush
#include noise

#define SAMPLES 16

void main() {
  BRUSH_BEGIN
  float a = brushAlpha * exp(-pow(r, brushHardness));
  vec3 c = vec3(0.0);
  float tw = 0.0;
  float uvn = noise(noise(uv) + brushSeed);
  for (int i = 0; i < SAMPLES; ++i) {
    float t = radians(360.0) * (float(i) + noise(uvn + float(i))) / float(SAMPLES);
    float r = -brushSize * log(1.0 - noise(uvn + 1337.0 * brushSeed + float(i)));
    vec2 dir = r * vec2(cos(t), sin(t));
    float w = 1.0;
    c += w * texture2D(canvas, uv + dir / canvasSize).xyz;
    tw += w;
  }
  BRUSH_OUTPUT(mix(canvasColor, c / tw, a));
}
