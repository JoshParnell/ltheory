local MathUtil = require('Gen.MathUtil')
local Joint    = require('Gen.ShapeLib.Joint')
local wrap     = Math.Wrap

-- BAD MESH PROTECTION POLICY
-- In the case that a bad piece of mesh data is encountered
--   in any function which operates on a poly,
--   IE, a poly fails a shape:polyValid(poly) test,
--   the function MUST skip that poly for that operation
--   so that we prevent junk shapes & crashes in release.
-- It is assumed that the validPoly function will ASSERT
--   so that the devs can debug the offending shape.

local Shape = {}
Shape.__index = Shape

-- Shape
--   verts: list of Vec3d
--   polys: list of int indicies, of variable size
setmetatable(Shape, {
  __call = function(T)
    return setmetatable({
      verts  = {},
      polys  = {}
    }, Shape)
  end
})

function Shape:add (...)
  local args = { ... }
  return self:addList(args)
end

-- AddList (Shape[])
function Shape:addList (others)
  for i = 1, #others do
    local other = others[i]
    local indexOffset = #self.verts

    -- Copy vertices
    for j = 1, #other.verts do
      local v = other.verts[j]
      self:addVertex(v.x, v.y, v.z)
    end

    -- Copy polygons
    for j = 1, #other.polys do
      local poly = other.polys[j]
      local copy = {}
      for k = 1, #poly do
        copy[#copy + 1] = poly[k] + indexOffset
      end
      self.polys[#self.polys + 1] = copy
    end
  end
  return self
end

function Shape:addTri (i0, i1, i2)
  self.polys[#self.polys + 1] = { i0, i1, i2 }
  return self
end

function Shape:addQuad (i0, i1, i2, i3)
  self.polys[#self.polys + 1] = { i0, i1, i2, i3 }
  return self
end

-- Add a poly of arbitrary degree to the mesh; input is a list of indices
function Shape:addPoly (poly)
  assert(#poly >= 3, 'addPoly requires at least three indices')
  self.polys[#self.polys + 1] = poly
  return self
end

function Shape:addVertex (x, y, z)
  self.verts[#self.verts + 1] = Vec3d(x, y, z)
  return self
end

function Shape:getRandomPoly(rng)
  return self.polys[rng:getInt(1, #self.polys)]
end

-- Connect(Shape other, int[] otherPoly, int[] myPoly)
-- Transforms other.verts so that the vertex defined by otherPoly
--   is attached to myPoly.
function Shape:connect (other, otherPoly, myPoly)
  local myJoint = Joint()
  local valid = myJoint:generateFromPoly(self, myPoly)
  local otherJoint = Joint()
  valid = valid and otherJoint:generateFromPoly(other, otherPoly)

  -- protect against bad joints
  if not valid then
    assert(valid, "Invalid shape:connect() joint input.")
    return self
  end

  local targetBasis = MathUtil.CreateBasis(myJoint.dir, myJoint.pos)
  local sourceBasis = MathUtil.CreateBasis(-otherJoint.dir, otherJoint.pos)
  sourceBasis:iInverse()
  local trans = targetBasis:product(sourceBasis)

  for i = 1, #other.verts do
    local v = other.verts[i]
    other.verts[i] = trans:mulPoint(v):toVec3d()
  end

  sourceBasis:free()
  targetBasis:free()
  trans:free()

  self:add(other)
  return self
end

-- AttachPolyToJoint (int[] poly, Joint joint)
function Shape:attachPolyToJoint (poly, joint)
  local myJoint = Joint()
  myJoint:generateFromPoly(self, poly)
  return self:attachJointToJoint(myJoint, joint)
end

-- AttachJointToJoint (Joint myJoint, Joint joint)
function Shape:attachJointToJoint(myJoint, joint)
  -- protect against bad joints
  local valid = myJoint and joint and joint:valid() and myJoint:valid()
  if not valid then
    assert(valid, "Bad joint ipnut to shape:attachJointToJoint().")
    return false
  end

  -- transformation for rotation & translation
  local sourceBasis = MathUtil.CreateBasis(myJoint.dir, myJoint.pos, myJoint.up)
  local targetBasis = MathUtil.CreateBasis(-joint.dir,  joint.pos, joint.up)
  sourceBasis:iInverse()
  local trans = targetBasis:product(sourceBasis)
  -- transformation for scale
  local tscale = Matrix.Scaling(joint.scale.x, joint.scale.y, joint.scale.z)
  trans = trans:product(tscale)

  for i = 1, #self.verts do
    local v = self.verts[i]
    self.verts[i] = trans:mulPoint(v):toVec3d()
  end

  sourceBasis:free()
  targetBasis:free()
  trans:free()
  return true
end

-- Compute center of part as average of vertex positions
function Shape:getCenter ()
  local c = Vec3d(0, 0, 0)
  for i = 1, #self.verts do c:iadd(self.verts[i]) end
  c:idivs(#self.verts)
  return c
end

-- Compute the center as the center of the bounding box
function Shape:getCenterBB ()
  local aabb = self:getAABB()
  return {(aabb.lower.x + aabb.upper.x) / 2,
          (aabb.lower.y + aabb.upper.y) / 2,
          (aabb.lower.z + aabb.upper.z) / 2 }
end

-- Compute poly face center as average of vertex positions
function Shape:getFaceCenter (poly)
  local c = Vec3d(0, 0, 0)
  for i = 1, #poly do
    c:iadd(self:getVertex(poly[i]))
  end
  c:idivs(#poly)
  return c
end

-- Compute poly face centroid as area-weighted average of face centers
function Shape:getFaceCentroid (poly)
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
function Shape:getFaceNormal (poly)
  if #poly < 3 then
    assert(#poly >= 3)
    return nil
  end

  local n = Vec3d(0, 0, 0)
  for i = 1, #poly - 2 do
    local p0 = self:getVertex(poly[1])
    local p1 = self:getVertex(poly[1 + i])
    local p2 = self:getVertex(poly[2 + i])

    if p0 == nil or p1 == nil or p2 == nil then
      --assert(p0, p1, p2)
      return nil
    end

    n:iadd((p1 - p0):cross(p2 - p0))
  end

  if n:length() > 1e-6 then
    n:inormalize()
    return n
  else
    print("Bad normal at poly:")
    self:printPoly(poly)
    --assert(n:length() > 1e-6)
  end
  return nil
end

-- returns the first poly found
-- with a normal = n
-- or the face with a normal closest to n
function Shape:getPolyWithNormal (n)
  local polyi
  local closestDiff = 1e10
  for i = 1, #self.polys do
    local poly = self.polys[i]
    if self:polyValid(poly) then
      local norm = self:getFaceNormal(poly)
      if norm ~= nil then
        local diff = (norm - n):length()
        if diff < closestDiff then
          closestDiff = diff
          polyi = i
        end
      end
    end
  end
  return polyi
end

-- Returns a list of all polys (by index)
-- with the normal n (within the margin of error 'margin')
function Shape:getPolysWithNormal(n, margin)
  local polys = {}
  for i = 1, #self.polys do
    local poly = self.polys[i]
    if self:polyValid(poly) then
      local norm = self:getFaceNormal(poly)
      if norm ~= nil and abs((n - norm):length()) <= margin then
        polys[#polys+1] = i
      end
    end
  end
  return polys
end

function Shape:getRandomPolyWithNormal(n, rng, margin)
  margin = margin or 0.001
  local polys = self:getPolysWithNormal(n, margin)
  if #polys == 0 then print("No polys found with normal ", n) end
  local poly = rng:choose(polys)
  return poly
end

function Shape:getRandomPolyWithNormalList(nl, rng, margin)
  margin = margin or 0.001

  local polys = {}
  for i = 1, #nl do
    local newPolys = self:getPolysWithNormal(nl[i], margin)
    for j = 1, #newPolys do
      polys[#polys+1] = newPolys[j]
    end
  end
  --print("poly list size:", #polys)

  if #polys == 0 then print("No polys found with normal from list ", nl) end
  local poly = rng:choose(polys)
  return poly
end

function Shape:getVertex (index)
  return self.verts[index + 1]
end

function Shape:getVertexCount ()
  return #self.verts
end

-- Clone ()
-- Returns new shape with values copied
function Shape:clone ()
  local clone = Shape()

  for i = 1, #self.verts do
    clone:addVertex(self.verts[i].x, self.verts[i].y, self.verts[i].z)
  end

  for i = 1, #self.polys do
    local poly = {}
    for j = 1, #self.polys[i] do
      poly[j] = self.polys[i][j]
    end
    clone:addPoly(poly)
  end

  return clone
end

-- TODO LR : In the rest of the engine, we use 'bound' instead of AABB, please
--           change to :getBound for uniformity (this performs the same
--           operation as the engine's Mesh_GetBound function)
-- GetAABB ()
-- Returns {Vec3d min, Vec3d max}
function Shape:getAABB ()
  local p = self.verts[1]
  local lower = Vec3d(p.x, p.y, p.z)
  local upper = Vec3d(p.x, p.y, p.z)
  for i = 2, #self.verts do
    local v = self.verts[i]
    lower.x = min(lower.x, v.x)
    lower.y = min(lower.y, v.y)
    lower.z = min(lower.z, v.z)
    upper.x = max(upper.x, v.x)
    upper.y = max(upper.y, v.y)
    upper.z = max(upper.z, v.z)
  end
  return { lower = lower, upper = upper }
end

-- Return the radius of the bounding box
function Shape:getRadius ()
  local bound = self:getAABB()
  return 0.5 * (bound.upper - bound.lower):length()
end

-- GetTopology ()
function Shape:getTopology ()
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
    if #faces ~= #verts then
      assert(#faces == #verts)
      return nil
    end
    local fi = faces[1]
    for j = 2, #faces do
      local nextVert = fi.ref[wrap(fi.index - 1, 1, #fi.ref)]
      local foundFace = false
      for k = j, #faces do
        fi = faces[k]
        if fi.ref[wrap(fi.index + 1, 1, #fi.ref)] == nextVert then
          verts[j], verts[k] = verts[k], verts[j]
          faces[j], faces[k] = faces[k], faces[j]
          foundFace = true
          break
        end
      end
      if not foundFace then
        --assert(foundFace, 'Topological Error: Failed to find adjacent face')
        return nil
      end
      fi = faces[j]
    end
  end

  return {
    v2v = v2v,
    v2f = v2f,
  }
end

-- Convert ALL higher-order polys into triangles
-- using triangle fans from first vertex to all others
-- NO NEW VERTICIES
-- GOOD for mesh finalization; NOT good for warping & adding detail
function Shape:triangulateFan ()
  for i = 1, #self.polys do
    local poly = self.polys[i]
    if self:polyValid(poly) then
      for j = 2, #poly - 2 do
        self.polys[#self.polys + 1] = { poly[1], poly[j + 1], poly[j + 2] }
      end
      self.polys[i] = { poly[1], poly[2], poly[3] }
    end
  end
end

-- InvertPoly (int pi)
-- Inverts winding order of one poly
function Shape:invertPoly(pi)
  local poly = self.polys[pi]
  local first = poly[1]
  local newPoly = {}
  for j = 0, #poly do
    newPoly[j+1] = poly[#poly-j]
  end
  newPoly[#poly] = first
  self.polys[pi] = newPoly
end

-- ExtrudePoly (int pi,
--              float length,
--              Vec3d scale,
--              Vec3d dir)
-- Extrudes a single poly by length along normal, contracts/expands by scale
--   toward centroid (no contraction/expansion if omitted)
-- Direction defaults to surface normal
-- Deletes original poly unless specified otherwise in preserveOriginal
function Shape:extrudePoly (pi, length, scale, dir, preserveOriginal)
  -- default vals
  length = length or 0.5
  scale = scale or Vec3d(1,1,1)
  preserveOriginal = preserveOriginal or false
  -- bad input protection
  local poly = self.polys[pi]
  if not self:polyValid(poly) then
    return self
  end
  if scale:length() < 1e-6 then
    assert(scale:length() > 1e-6)
    return self
  end

  dir = dir or self:getFaceNormal(poly)
  if dir:length() < 1e-6 then
    assert(dir:length() > 1e-6)
    return self
  end

  local newPoly = {}
  local c = self:getFaceCentroid(poly)

  -- Create extruded verts
  for j = 1, #poly do
    local p = self:getVertex(poly[j])
    newPoly[#newPoly + 1] = #self.verts
    self:addVertex(
      Math.Lerp(c.x, p.x, scale.x) + dir.x * length,
      Math.Lerp(c.y, p.y, scale.y) + dir.y * length,
      Math.Lerp(c.z, p.z, scale.z) + dir.z * length)
  end

  -- Stitch extrusion sides with quads
  -- NOTE : Winding order on the sides must be *opposite* that of the base
  --        poly order! (Picture it ...)
  for j0 = 1, #poly do
    local j1 = j0 % #poly + 1
    self:addQuad(
      poly[j0],
      poly[j1],
      newPoly[j1],
      newPoly[j0])
  end

  if not preserveOriginal then
    -- Move existing face to extruded verticies
    for j = 1, #poly do self.polys[pi][j] = newPoly[j] end
  else
    -- add new face
    local npi = #self.polys + 1
    self.polys[npi] = newPoly
    -- invert original face
    self:invertPoly(pi)
  end
end

-- TriangulatePolyCentroid (int[] poly, float length)
-- Adds a new vertex in the center of poly & creates tris connecting
--   that center to the existing verticies of the poly
-- Extrudes the new vertex by length
function Shape:triangulatePolyCentroid (pi, length, dir)
  local poly = self.polys[pi]
  if not self:polyValid(poly) then
    return -- skip operation
  end
  length = length or 0

  local ci = self:getVertexCount()
  local c = self:getFaceCentroid(poly)
  dir = dir or self:getFaceNormal(poly)
  self:addVertex(c.x + length*dir.x,
                 c.y + length*dir.y,
                 c.z + length*dir.z)
  for j = 1, #poly - 1 do
    self.polys[#self.polys + 1] = { ci, poly[j], poly[j + 1] }
  end
  self.polys[pi] = { ci, poly[#poly], poly[1] }
end

-- TriangulateTriEven (int pi, int[] edgeMap)
-- Splits a single tri into 4 tris (imagine the triforce symbol)
-- Is useful for applying warps after using,
--   because preserves tri angles
-- Adds new verts; uses edgeMap to avoid creating duplicate verts
function Shape:triangulateTriEven (pi, edgeMap, vc)
  local poly = self.polys[pi]
  if not self:polyValid(poly) then
    return -- skip operation
  end

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

-- makes roof shape from quad
function Shape:roofQuad(pi, h, preserveOriginal)
  local quad = self.polys[pi]
  if #quad ~= 4 or not self:polyValid(quad) then
    return
  end

  local o1 = quad[1]
  local o2 = quad[4]
  local o3 = quad[2]
  local o4 = quad[3]
  local o1v = self.verts[o1+1]
  local o2v = self.verts[o2+1]
  local o3v = self.verts[o3+1]
  local o4v = self.verts[o4+1]

  local v1 = self:getVertexCount()
  self:addVertex((o1v.x + o2v.x)/2.0, o1v.y + h, o1v.z)

  local v2 = self:getVertexCount()
  self:addVertex((o3v.x + o4v.x)/2.0, o3v.y + h, o3v.z)

  self:addTri(o4, v2, o3)
  self:addTri(v1, o2, o1)
  self:addPoly({v2, v1, o1, o3})

  if preserveOriginal then
    self:addPoly({v1, v2, o4, o2})
    self:invertPoly(pi)
  else
    self.polys[pi] = {v1, v2, o4, o2}
    quad = nil
  end

  return self
end

-- TessellateQuad (int pi, int[] edgeMap)
-- Splits a single quad into 4 quads
-- Adds new verts; uses edgeMap to avoid creating duplicate verts
function Shape:tessellateQuad (pi, edgeMap, vc)
  local quad = self.polys[pi]
  if #quad ~= 4 or not self:polyValid(quad) then
    return
  end

  -- new vertex in center of quad
  local verts = {}
  verts[1] = self:getVertexCount()
  local c = self:getFaceCentroid(quad)
  self:addVertex(c.x, c.y, c.z)

  -- new verticies on edges of quad
  for j1 = 1, #quad do
    local j2 = j1 % #quad + 1
    local i1 = quad[j1]
    local i2 = quad[j2]
    local ei = min(i1, i2) * vc + max(i1, i2)
    if not edgeMap[ei] then
      edgeMap[ei] = self:getVertexCount()
      local p = self:getVertex(i1):lerp(self:getVertex(i2), 0.5)
      self:addVertex(p.x, p.y, p.z)
    end
    verts[#verts + 1] = edgeMap[ei]
  end

  -- new quads
  self:addQuad(verts[2], quad[2], verts[3], verts[1])
  self:addQuad(verts[1], verts[3], quad[3], verts[4])
  self:addQuad(verts[5], verts[1], verts[4], quad[4])
  local q1 = quad[1]
  List.clear(quad)
  quad[1] = q1
  quad[2] = verts[2]
  quad[3] = verts[1]
  quad[4] = verts[5]
end

function Shape:addAtIntersection(rayOrigin, rayDir, shape)
  local intersection = self:intersectRay(rayOrigin, rayDir)
  if intersection then
    shape:translate(intersection.x, intersection.y, intersection.z)
    self:add(shape)
  end
end

-- tests for intersection with ray
-- returns intersection point, if found; null otherwise
-- WARNING: fan triangulates the mesh
-- TODO : Don't triangulate
function Shape:intersectRay (rayOrigin, rayDir)
  -- local tBegin = TimeStamp.Get()
  -- triangulate
  self:triangulateFan()

  -- check every poly in the mesh for an intersection
  local tMin = math.huge
  local intersection = nil

  for i = 1, #self.polys do
    local poly = self.polys[i]
    local t = self:checkRayIntersectTri(rayOrigin, rayDir, poly)

    if t and t < tMin then
      tMin = t
      intersection = rayOrigin + rayDir:scale(t)
    end
  end

  -- printf('Raycast took %.2f ms', TimeStamp.GetElapsedMs(tBegin))
  return intersection
end

function Shape:checkRayIntersectTri(rayOrigin, rayDir, tri, oldT)
  local p0 = self.verts[tri[1]+1]
  local p1 = self.verts[tri[2]+1]
  local p2 = self.verts[tri[3]+1]

  -- 1) check if ray intersects plane
  local n = self:getFaceNormal(tri)
  local dot = n:dot(rayDir)

  if dot >= 0.0 then
    return nil
  end

  local d = n:dot(p0)
  local t = d - n:dot(rayOrigin)
  if t > 0.0 then
    return nil
  end

  -- 2) compute parametric point of intersection with plane
  t = t / dot
  local p = rayOrigin + Vec3d(rayDir.x*t, rayDir.y*t, rayDir.z*t)

  local u0, u1, u2
  local v0, v1, v2
  if abs(n.x) > abs(n.y) then
    if abs(n.x) > abs(n.z) then
      u0 = p.y - p0.y
      u1 = p1.y - p0.y
      u2 = p2.y - p0.y
      v0 = p.z - p0.z
      v1 = p1.z - p0.z
      v2 = p2.z - p0.z
    else
      u0 = p.x - p0.x
      u1 = p1.x - p0.x
      u2 = p2.x - p0.x
      v0 = p.y - p0.y
      v1 = p1.y - p0.y
      v2 = p2.y - p0.y
    end
  else
    if abs(n.y) > abs(n.z) then
      u0 = p.x - p0.x
      u1 = p1.x - p0.x
      u2 = p2.x - p0.x
      v0 = p.z - p0.z
      v1 = p1.z - p0.z
      v2 = p2.z - p0.z
    else
      u0 = p.x - p0.x
      u1 = p1.x - p0.x
      u2 = p2.x - p0.x
      v0 = p.y - p0.y
      v1 = p1.y - p0.y
      v2 = p2.y - p0.y
    end
  end

  local temp = u1*v2 - v1*u2
  if temp == 0.0 then
    return nil
  end
  temp = 1.0 / temp

  local alpha = (u0*v2 - v0*u2) * temp
  if alpha < 0.0 then
    return nil
  end

  local beta = (u1*v0 - v1*u0) * temp
  if beta < 0.0 then
    return nil
  end

  local gamma = 1.0 - alpha - beta
  if gamma < 0.0 then
    return nil
  end

  -- intersection found
  return t
end

-- Valid ()
-- Checks that all polys can be operated on.
function Shape:checkValid ()
  for i = 1, #self.polys do
    if not self:polyValid(self.polys[i]) then
      return false
    end
  end
  return true
end

-- PolyValid (int[] poly)
-- A poly is invalid if it has:
--   < 3 indicies
--   OR normal length < 1e-6
function Shape:polyValid (poly)
  if poly == nil then
    assert(poly ~= nil)
    return false
  elseif #poly < 3 then
    assert(#poly >= 3)
    return false
  elseif self:getFaceNormal(poly) == nil then
    -- getFaceNormal asserts
    return false
  end
  for i = 1, #poly do if poly[i] == nil then error("Poly contains nil") end end
  return true
end

-- Convert shape into native triangle mesh for external use
function Shape:finalize ()
  local mesh = Mesh.Create()
  self:triangulateFan()

  -- Copy vertices
  for i = 1, #self.verts do
    local vertex = self.verts[i]
    mesh:addVertex(vertex.x, vertex.y, vertex.z, 1, 0, 0, 0, 0)
  end

  -- Copy tris
  for i = 1, #self.polys do
    local tri = self.polys[i]
    mesh:addTri(tri[1], tri[2], tri[3])
  end

  mesh:center()
  mesh:rotateY(Math.Pi)

  -- Compute missing information
  mesh:splitNormals(0.99)
  if Config.gen.uvMapping then
    mesh = require('Gen.UVMap')(mesh, Config.gen.uvMapRes)
  else
    mesh:computeAO(0.6 * mesh:getRadius())
  end
  return mesh--, BSP.Create(mesh)
end

-- PrintPoly ()
function Shape:printPoly(poly)
  for i = 1, #poly do
    print(i, " = ", poly[i], " = ", self.verts[poly[i]])
  end
end

-- ToString ()
function Shape:__tostring ()
  return format('Shape(%d verts, %d polys)',
    #self.verts,
    #self.polys)
end

return Shape
