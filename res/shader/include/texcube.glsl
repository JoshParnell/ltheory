#ifndef include_texcube
#define include_texcube

uniform vec3 cubeLook;
uniform vec3 cubeUp;
uniform float cubeSize;

vec3 cubeMapDir(vec2 uv) {
  uv = 2.0 * uv - vec2(1.0, 1.0);
  vec3 cubeRight = normalize(cross(cubeUp, cubeLook));
  return normalize(cubeLook + uv.x * cubeRight - uv.y * cubeUp);
}

#endif
