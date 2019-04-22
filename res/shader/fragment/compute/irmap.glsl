varying vec2 uv;

uniform vec3 cubeLook;
uniform vec3 cubeUp;

vec3 cubeMapDir(vec2 uv) {
  uv = 2.0 * uv - vec2(1.0, 1.0);
  vec3 cubeRight = normalize(cross(cubeUp, cubeLook));
  return normalize(cubeLook + uv.x * cubeRight - uv.y * cubeUp);
}

float lum(vec3 rgb) {
  return dot(rgb, vec3(0.2126, 0.7152, 0.0722));
}

uniform samplerCube src;
uniform sampler2D sampleBuffer;
uniform float angle;
uniform int samples;

void main() {
  vec3 N = cubeMapDir(uv);
  vec3 T = normalize(cubeUp - N * dot(cubeUp, N));
  vec3 B = normalize(cross(N, T));
  vec4 c = vec4(0.0);
  float tw = 0;

  for (int i = 0; i < samples; ++i) {
    float u = float(i + 1) / float(samples + 1);
    vec2 sample = texture2DLod(sampleBuffer, vec2(u, 0.5), 0.0).xy;
    float pitch = sample.x;
    float yaw = sample.y;
    vec3 L =
      cos(pitch) * N +
      sin(pitch) * sin(yaw) * T +
      sin(pitch) * cos(yaw) * B;

    float w = 1.0 / dot(N, L);
    w = 1;
    c += w * textureCubeLod(src, L, 0.0);
    tw += w;
  }

  gl_FragColor = c / tw;
  gl_FragColor.w = 1;
}
