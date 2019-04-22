#ifndef include_color
#define include_color

float lum(vec3 rgb) {
  return dot(rgb, vec3(0.2126, 0.7152, 0.0722));
}

float hueToComponent(float p, float q, float t) {
  if (t < 0.0) t += 1.0;
  if (t > 1.0) t -= 1.0;
  if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
  if (t < 1.0 / 2.0) return q;
  if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
  return p;
}

vec3 oversaturate(vec3 c, float amount) {
  c = max(c, vec3(0.0));
  float avg = (c.x + c.y + c.z) / 3.0 + 0.00001;
#if 0
  return mix(
    c / (1.0 + amount * (avg / c - 1.0)),
    c * (1.0 + amount * (c / avg - 1.0)),
    step(avg, c));
#else
  return c * max(vec3(0.0), (1.0 + amount * (c / avg - 1.0)));
#endif
}

vec3 toRGB(vec3 hsl) {
  float h = hsl.x;
  float s = hsl.y;
  float l = hsl.z;
  if (s == 0.0)
    return vec3(l);
  else {
    float q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    float p = 2.0 * l - q;
    float r = hueToComponent(p, q, h + 1.0 / 3.0);
    float g = hueToComponent(p, q, h);
    float b = hueToComponent(p, q, h - 1.0 / 3.0);
    return vec3(r, g, b);
  }
}

vec3 toHSL(vec3 rgb) {
  float r = rgb.x;
  float g = rgb.y;
  float b = rgb.z;
  float M = max(r, max(g, b));
  float m = min(r, min(g, b));
  float mSum = M + m;
  float mDiff = M - m;
  float h, s, l = mSum / 2.0;
  if (M == m) {
    return vec3(0.0, 0.0, l);
  } else {
    s = l > 0.5 ? mDiff / (2.0 - mSum) : mDiff / mSum;
    if (r == M)       h = (g - b) / mDiff + (g < b ? 6.0 : 0.0);
    else if (g == M)  h = (b - r) / mDiff + 2.0;
    else              h = (r - g) / mDiff + 4.0;
    return vec3(h / 6.0, s, l);
  }
}

#endif
