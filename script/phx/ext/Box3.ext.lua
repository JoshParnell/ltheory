local function defineBox3 (box3, mt)
  function mt.__tostring (b)
    return format(
      '[(%.2f, %.2f, %.2f) -> (%.2f, %.2f, %.2f)]',
      b.lowerx, b.lowery, b.lowerz,
      b.upperx, b.uppery, b.upperz)
  end
end

onDef_Box3i_t = defineBox3
onDef_Box3f_t = defineBox3
onDef_Box3d_t = defineBox3
