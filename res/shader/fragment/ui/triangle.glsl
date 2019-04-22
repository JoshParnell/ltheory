#include fragment

uniform vec2 p1;
uniform vec2 p2;
uniform vec2 p3;
uniform vec4 color;

const float kRadius = 0.5;

void main() {
  vec3 p = pos;
  vec2 center = (p1 + p2 + p3) / 3.0;
  p1 += kRadius * normalize(center - p1);
  p2 += kRadius * normalize(center - p2);
  p3 += kRadius * normalize(center - p3);

  vec2 d1 = normalize(p2 - p1);
  vec2 d2 = normalize(p3 - p2);
  vec2 d3 = normalize(p1 - p3);
  float ed1 = length(p - (p1 + d1 * clamp(dot(d1, p - p1), 0.0, length(p2 - p1))));
  float ed2 = length(p - (p2 + d2 * clamp(dot(d2, p - p2), 0.0, length(p3 - p2))));
  float ed3 = length(p - (p3 + d3 * clamp(dot(d3, p - p3), 0.0, length(p1 - p3))));
  float edm = min(ed1, min(ed2, ed3));

  vec2 n1 = vec2(-d1.y, d1.x);
  vec2 n2 = vec2(-d2.y, d2.x);
  vec2 n3 = vec2(-d3.y, d3.x);
  n1 *= sign(dot(n1, p3 - p1));
  n2 *= sign(dot(n2, p1 - p2));
  n3 *= sign(dot(n3, p2 - p3));
  float dist1 = -dot(n1, p - p1);
  float dist2 = -dot(n2, p - p2);
  float dist3 = -dot(n3, p - p3);
  float dist = max(dist1, max(dist2, dist3));
  float idm = step(0.0, dist) * edm;

  float fill    = exp(-1.0 * idm);
  float glow    = exp(-pow(0.25 * edm, 0.75));

  float alpha = 0.0;
  alpha += 0.8 * fill;
  alpha += 0.3 * glow;

  gl_FragColor = alpha * color.w * vec4(2.0 * color.xyz, 1.0);
}
