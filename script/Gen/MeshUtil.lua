local MeshUtil = {}

-- Combine(Mesh[] meshlist)
function MeshUtil.Combine(meshlist)
  local mesh = Mesh.Create()
  for i = 1, #meshlist do
    mesh:addMesh(meshlist[i])
  end
  return mesh
end

-- Finalize (Mesh mesh)
function MeshUtil.Finalize (mesh)
  mesh:computeNormals()
  mesh:computeAO(1.0)
  return mesh
end

return MeshUtil
