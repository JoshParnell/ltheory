local PolyMesh = {}
PolyMesh.__index = PolyMesh

function PolyMesh.Create ()
  return setmetatable({
    verts    = {},
    polys    = {},
    selected = {},
  }, PolyMesh)
end

function PolyMesh:add (other)
  local base = #self.verts
  for i = 1, #other.verts do
    local v = other.verts[i]
    self:addVertex(v.x, v.y, v.z)
  end

  for i = 1, #other.polys do
    local poly = other.polys[i]
    local copy = {}
    for j = 1, #poly do
      copy[#copy + 1] = poly[j] + base
    end
    self.polys[#self.polys + 1] = copy
  end
  return self
end

function PolyMesh:addTri (i0, i1, i2)
  self.polys[#self.polys + 1] = { i0, i1, i2 }
  return self
end

function PolyMesh:addQuad (i0, i1, i2, i3)
  self.polys[#self.polys + 1] = { i0, i1, i2, i3 }
  return self
end

-- Add a poly of arbitrary degree to the mesh; input is a list of indices
function PolyMesh:addPoly (poly)
  assert(#poly >= 3, 'addPoly requires at least three indices')
  self.polys[#self.polys + 1] = poly
  return self
end

function PolyMesh:addVertex (x, y, z)
  self.verts[#self.verts + 1] = Vec3d(x, y, z)
  return self
end

function PolyMesh:bevel (t)
  local result = PolyMesh.Create()
  local top = self:getTopology()
  local edgeMap = {}
  local e2v = {} -- Directed Edge to Bevel Corner { ref, subindex }
  local vc = self:getVertexCount()

  -- Create bevel corner faces
  for i = 1, #self.verts do
    local v = self.verts[i]
    local faces = top.v2f[i - 1]
    local newFace = {}
    for j = 1, #faces do
      local face = faces[j]
      newFace[j] = result:getVertexCount()
      local nextVert = face.ref[Math.Wrap(face.index + 1, 1, #face.ref)]
      e2v[vc * (i - 1) + nextVert] = { newFace, j }
      local p = v:lerp(self:getFaceCenter(face.ref), t)
      result:addVertex(p.x, p.y, p.z)
    end
    result:addPoly(newFace)
  end

  -- Connect bevelled corners with quads
  for i = 1, #self.verts do
    local faces = top.v2f[i - 1]
    local verts = top.v2v[i - 1]
    for j = 1, #verts do
      if (i - 1) < verts[j] then
        local corner1 = e2v[vc * (i - 1) + verts[j]]  -- Incoming
        local corner2 = e2v[vc * verts[j] + (i - 1)]  -- Outgoing
        local f1, i1 = corner1[1], corner1[2]
        local f2, i2 = corner2[1], corner2[2]
        result:addQuad(
          f1[i1],
          f1[Math.Wrap(i1 - 1, 1, #f1)],
          f2[i2],
          f2[Math.Wrap(i2 - 1, 1, #f2)])
      end
    end
  end

  -- Re-connect original faces
  for i = 1, #self.polys do
    local face = self.polys[i]
    local newFace = {}
    for j = 1, #face do
      local v1 = face[j]
      local v2 = face[Math.Wrap(j + 1, 1, #face)]
      local corner = e2v[vc * v1 + v2]
      local cf, ci = corner[1], corner[2]
      newFace[j] = cf[ci]
    end
    result:addPoly(newFace)
  end

  return result
end

function PolyMesh:center ()
  local c = self:getCenter()
  return self:translate(-c.x, -c.y, -c.z)
end

function PolyMesh:extrude (length, scale)
  local scale = scale or 1
  for i = 1, #self.selected do
    self:extrudeFace(self.selected[i], length, scale)
  end
  return self
end

function PolyMesh:extrudeFn (lengthFn, scaleFn)
  for i = 1, #self.selected do
    local p = self:getFaceCenter(self.selected[i])
    self:extrudeFace(self.selected[i], lengthFn(p), scaleFn(p))
  end
  return self
end

function PolyMesh:extrudeFace (poly, length, scale)
  local newPoly = {}
  local c = self:getFaceCentroid(poly)
  local n = self:getFaceNormal(poly)

  -- Create extruded verts
  for i = 1, #poly do
    local p = self:getVertex(poly[i])
    newPoly[#newPoly + 1] = self:getVertexCount()
    self:addVertex(
      Math.Lerp(c.x, p.x, scale) + n.x * length,
      Math.Lerp(c.y, p.y, scale) + n.y * length,
      Math.Lerp(c.z, p.z, scale) + n.z * length)
  end

  -- Stitch extrusion sides with quads
  for i0 = 1, #poly do
    local i1 = i0 % #poly + 1
    self:addQuad(
      poly[i0],
      poly[i1],
      newPoly[i1],
      newPoly[i0])
  end

  -- Move original face to new verts
  for i = 1, #poly do
    poly[i] = newPoly[i]
  end
end

-- Convert to native triangle mesh; perform normal splitting and AO computation
function PolyMesh:finalize (aoMult)
  local mesh = self:getMesh()
  mesh:splitNormals(1.0)
  mesh:computeAO((aoMult or 0.5) * mesh:getRadius())
  return mesh
end

-- Compute center of part as average of vertex positions
function PolyMesh:getCenter ()
  local c = Vec3d(0, 0, 0)
  for i = 1, #self.verts do c:iadd(self.verts[i]) end
  c:idivs(#self.verts)
  return c
end

-- Compute and return the dual mesh
function PolyMesh:getDual ()
  local dual = PolyMesh.Create()
  local top = self:getTopology()

  for i = 1, #self.polys do
    local poly = self.polys[i]
    local c = self:getFaceCentroid(poly)
    dual:addVertex(c.x, c.y, c.z)
  end

  for i = 1, #self.verts do
    local poly = {}
    local faces = top.v2f[i - 1]
    for j = 1, #faces do
      poly[#poly + 1] = faces[j].face - 1
    end
    dual:addPoly(poly)
  end
  return dual
end

-- Compute poly face center as average of vertex positions
function PolyMesh:getFaceCenter (poly)
  local c = Vec3d(0, 0, 0)
  for i = 1, #poly do
    c:iadd(self:getVertex(poly[i]))
  end
  c:idivs(#poly)
  return c
end

-- Compute poly face centroid as area-weighted average of face centers
function PolyMesh:getFaceCentroid (poly)
  local c = Vec3d(0, 0, 0)
  local n = Vec3d(0, 0, 0)
  for i = 1, #poly - 2 do
    local p0 = self:getVertex(poly[1])
    local p1 = self:getVertex(poly[1 + i])
    local p2 = self:getVertex(poly[2 + i])
    local pn = (p1 - p0):cross(p2 - p0)
    c:iadd((p0 + p1 + p2):scale(pn:length() / 3.0))
    n:iadd(pn)
  end
  c:idivs(n:length())
  return c
end

-- Compute poly face normal as area-weighted average of edge cross-products
function PolyMesh:getFaceNormal (poly)
  local n = Vec3d(0, 0, 0)
  for i = 1, #poly - 2 do
    local p0 = self:getVertex(poly[1])
    local p1 = self:getVertex(poly[1 + i])
    local p2 = self:getVertex(poly[2 + i])
    n:iadd((p1 - p0):cross(p2 - p0))
  end
  assert(n:length() > 1e-6)
  n:inormalize()
  return n
end

-- Convert to native triangle mesh without calculating additional information
function PolyMesh:getMesh ()
  local mesh = Mesh.Create()
  -- Copy vertices
  for i = 1, #self.verts do
    local vertex = self.verts[i]
    mesh:addVertex(vertex.x, vertex.y, vertex.z, 1, 0, 0, 0, 0)
  end

  -- Triangulate polygons
  for i = 1, #self.polys do
    local poly = self.polys[i]
    for j = 1, #poly - 2 do
      mesh:addTri(poly[1], poly[1 + j], poly[2 + j])
    end
  end

  return mesh
end

function PolyMesh:getTopology ()
  local v2f = Map(List) -- Vertex -> Connected faces
  local v2v = Map(List) -- Vertex -> Connected vertices

  -- Add faces to vertex -> face list
  for i = 1, #self.polys do
    local poly = self.polys[i]
    for j = 1, #poly do
      local v = poly[j]
      v2f[v]:add({ref = poly, face = i, index = j})
      v2v[v]:add(poly[j % #poly + 1])
    end
  end

  -- Sort v2f and v2v to maintain adjacency and CCW winding
  for i = 1, #self.verts do
    local faces = v2f[i - 1]
    local verts = v2v[i - 1]
    assert(#faces == #verts)
    local fi = faces[1]
    for j = 2, #faces do
      local nextVert = fi.ref[Math.Wrap(fi.index - 1, 1, #fi.ref)]
      local foundFace = false
      for k = j, #faces do
        fi = faces[k]
        if fi.ref[Math.Wrap(fi.index + 1, 1, #fi.ref)] == nextVert then
          verts[j], verts[k] = verts[k], verts[j]
          faces[j], faces[k] = faces[k], faces[j]
          foundFace = true
          break
        end
      end
      assert(foundFace, 'Topological Error: Failed to find adjacent face')
      fi = faces[j]
    end
  end

  return {
    v2v = v2v,
    v2f = v2f,
  }
end

function PolyMesh:getVertex (index)
  return self.verts[index + 1]
end

function PolyMesh:getVertexCount ()
  return #self.verts
end

function PolyMesh:tessellate (fn)
  self:triangulateCentroid()
  local edgeMap = {}
  local vc = self:getVertexCount()

  for i = 1, #self.polys do
    local poly = self.polys[i]
    local verts = {}
    for j1 = 1, #poly do
      local j2 = j1 % #poly + 1
      local v1 = poly[j1]
      local v2 = poly[j2]
      local ei = min(v1, v2) * vc + max(v1, v2)
      if not edgeMap[ei] then
        edgeMap[ei] = self:getVertexCount()
        local p = self:getVertex(v1):lerp(self:getVertex(v2), 0.5)
        self:addVertex(p.x, p.y, p.z)
      end
      verts[#verts + 1] = edgeMap[ei]
    end
    self:addTri(verts[1], poly[2], verts[2])
    self:addTri(verts[2], poly[3], verts[3])
    self:addTri(verts[3], poly[1], verts[1])
    List.clear(poly)
    poly[1] = verts[1]
    poly[2] = verts[2]
    poly[3] = verts[3]
  end
end

function PolyMesh:scale (sx, sy, sz)
  for i = 1, self:getVertexCount() do
    local v = self.verts[i]
    v.x, v.y, v.z = v.x * sx, v.y * sy, v.z * sz
  end
  return self
end

function PolyMesh:selectAll ()
  self.selected = {}
  for i = 1, #self.polys do
    self.selected[i] = self.polys[i]
  end
end

function PolyMesh:selectClear ()
  self.selected = {}
end

function PolyMesh:selectFace (modIndex)
  self.selected[#self.selected + 1] = self.polys[modIndex % #self.polys]
end

function PolyMesh:selectSubset (fn)
  local newSelection = {}
  for i = 1, #self.selected do
    if fn(self.selected[i]) then
      newSelection[#newSelection + 1] = self.selected[i]
    end
  end
  self.selected = newSelection
end

function PolyMesh:spherize ()
  for i = 1, #self.verts do
    self.verts[i]:inormalize()
  end
  return self
end

function PolyMesh:stellate (length)
  for i = 1, #self.selected do
    local poly = self.selected[i]

    -- Calculate displaced vertex position
    local n = self:getFaceNormal(poly)
    local p = self:getFaceCentroid(poly)
    local index = #self.verts
    self:addVertex(
      p.x + length * n.x,
      p.y + length * n.y,
      p.z + length * n.z)

    -- Stitch poly base to displaced vertex using tris
    for j0 = 2, #poly do
      local j1 = j0 % #poly + 1
      local newPoly = { poly[j0], poly[j1], index }
      self.polys[#self.polys + 1] = newPoly
      self.selected[#self.selected + 1] = newPoly
    end
    local i1 = poly[1]
    local i2 = poly[2]
    List.clear(poly)
    poly[1] = i1
    poly[2] = i2
    poly[3] = index
  end
  return self
end

function PolyMesh:translate (x, y, z)
  for i = 1, self:getVertexCount() do
    local v = self.verts[i]
    v.x, v.y, v.z = v.x + x, v.y + y, v.z + z
  end
  return self
end

-- Convert all higher-order polys into triangles using triangle fans from
-- first vertex to all others (no new vertices)
function PolyMesh:triangulate ()
  for i = 1, #self.polys do
    local poly = self.polys[i]
    if #poly > 3 then
      for j = 2, #poly - 2 do
        self.polys[#self.polys + 1] = { poly[1], poly[j + 1], poly[j + 2] }
      end
      self.polys[i] = { poly[1], poly[2], poly[3] }
    end
  end
end

-- Call fn on each vertex of the mesh; fn is expected to directly modify the
-- passed-by-value Vec3d
function PolyMesh:transform (fn)
  for i = 1, #self.verts do fn(self.verts[i]) end
  return self
end

-- Convert all higher-order polys into triangles using fans from centroid
-- (one new vertex per non-triangle face)
function PolyMesh:triangulateCentroid ()
  for i = 1, #self.polys do
    local poly = self.polys[i]
    if #poly > 3 then
      local ci = self:getVertexCount()
      local c = self:getFaceCentroid(poly)
      self:addVertex(c.x, c.y, c.z)
      for j = 1, #poly - 1 do
        self.polys[#self.polys + 1] = { ci, poly[j], poly[j + 1] }
      end
      self.polys[i] = { ci, poly[#poly], poly[1] }
    end
  end
end

function PolyMesh:__tostring ()
  return format('PolyMesh(%d verts, %d polys)', #self.verts, #self.polys)
end

return PolyMesh.Create
