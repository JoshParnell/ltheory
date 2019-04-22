varying vec2 uv;
varying vec3 pos;
varying vec3 vertPos;

uniform sampler2D texDiffuse;
uniform samplerCube texEnv;

void main() {
  vec3 dir = normalize(vertPos);
  vec2 uvSphere = vec2(
    atan(vertPos.z, vertPos.x) / radians(360.0) + 0.5,
    -atan(vertPos.y, length(vertPos.xz)) / radians(180.0) + 0.5);
  vec3 c = vec3(0.0, 0.0, 0.0);
  c = mix(
    vec3(0.8, 0.5 + 0.5 * abs(dir.y), 0.5),
    vec3(0.5, 0.7, 1.0),
    abs(dir.y));
  if (dir.y < 0.0)
    c = vec3(0.1, 0.1, 0.1);
  float d = acos(dot(dir, normalize(vec3(1, 1, 0))));
  c += exp(-24.0 * d * d) * vec3(1.0, 0.5, 0.1);
  // c = texture2D(texDiffuse, uvSphere).xyz;
  c = textureCube(texEnv, dir * vec3(1, 1, 1)).xyz;
  gl_FragColor = vec4(c, 1.0);
  gl_FragDepth = 1.0;
}
