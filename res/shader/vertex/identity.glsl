varying vec2 uv;
varying vec3 pos;

void main() {
  uv = gl_MultiTexCoord0.xy;
  pos = gl_Vertex.xyz;
  gl_Position = gl_Vertex;
}
