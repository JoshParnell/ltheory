local code = '''
  uniform float seed;

  void main() {
  }
  float hash(float x) {
    return fract(sin(x) * 4137.31315);
  }
  for
'''

local function generate (sx, sy, format, seed)
  local self = Tex2D.Create(sx, sy, format)

  return self
end

return {
  name = 'Noise',
  desc = 'Uniform 2D Noise',
  type = 'Tex2D',
  args = { 'width', 'height', 'format', 'seed' },
  fn = generate,
}
