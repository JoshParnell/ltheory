#include fragment
#include color
#include gamma
#include math
#include noise

uniform sampler2D srcBottom;
uniform sampler2D srcTop;

void main() {
  vec3 cb = texture2D(srcBottom, uv).xyz;
  vec4 ct = texture2D(srcTop, uv);
  // ct.xyz = linear(ct.xyz);
  float l = pow(saturate(1.5 * ct.w), 0.75);
  ct.z = pow(ct.z, 0.95);
  ct.xyz *= 1.0 - 0.02 * log(1.0 - noise(gl_FragCoord.xy));
  vec3 c = cb * (1.0 - l) + ct.xyz;
  gl_FragColor = vec4(c, 1.0);
}
