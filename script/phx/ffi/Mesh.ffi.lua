-- Mesh ------------------------------------------------------------------------
local Mesh

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Mesh*   Mesh_Create            ();
    void    Mesh_Acquire           (Mesh*);
    void    Mesh_Free              (Mesh*);
    Mesh*   Mesh_Load              (cstr name);
    Mesh*   Mesh_Clone             (Mesh*);
    Bytes*  Mesh_ToBytes           (Mesh*);
    Mesh*   Mesh_FromBytes         (Bytes*);
    Mesh*   Mesh_FromObj           (cstr);
    Mesh*   Mesh_FromSDF           (SDF*);
    void    Mesh_AddIndex          (Mesh*, int);
    void    Mesh_AddMesh           (Mesh*, Mesh*);
    void    Mesh_AddQuad           (Mesh*, int, int, int, int);
    void    Mesh_AddTri            (Mesh*, int, int, int);
    void    Mesh_AddVertex         (Mesh*, float px, float py, float pz, float nx, float ny, float nz, float u, float v);
    void    Mesh_AddVertexRaw      (Mesh*, Vertex const*);
    uint64  Mesh_GetVersion        (Mesh*);
    void    Mesh_IncVersion        (Mesh*);
    void    Mesh_GetBound          (Mesh*, Box3f* out);
    void    Mesh_GetCenter         (Mesh*, Vec3f* out);
    int     Mesh_GetIndexCount     (Mesh*);
    int*    Mesh_GetIndexData      (Mesh*);
    float   Mesh_GetRadius         (Mesh*);
    Vertex* Mesh_GetVertex         (Mesh*, int);
    int     Mesh_GetVertexCount    (Mesh*);
    Vertex* Mesh_GetVertexData     (Mesh*);
    void    Mesh_ReserveIndexData  (Mesh*, int capacity);
    void    Mesh_ReserveVertexData (Mesh*, int capacity);
    Error   Mesh_Validate          (Mesh*);
    void    Mesh_Draw              (Mesh*);
    void    Mesh_DrawBind          (Mesh*);
    void    Mesh_DrawBound         (Mesh*);
    void    Mesh_DrawUnbind        (Mesh*);
    void    Mesh_DrawNormals       (Mesh*, float scale);
    Mesh*   Mesh_Center            (Mesh*);
    Mesh*   Mesh_Invert            (Mesh*);
    Mesh*   Mesh_RotateX           (Mesh*, float rads);
    Mesh*   Mesh_RotateY           (Mesh*, float rads);
    Mesh*   Mesh_RotateZ           (Mesh*, float rads);
    Mesh*   Mesh_RotateYPR         (Mesh*, float yaw, float pitch, float roll);
    Mesh*   Mesh_Scale             (Mesh*, float x, float y, float z);
    Mesh*   Mesh_ScaleUniform      (Mesh*, float);
    Mesh*   Mesh_Transform         (Mesh*, Matrix*);
    Mesh*   Mesh_Translate         (Mesh*, float x, float y, float z);
    void    Mesh_ComputeAO         (Mesh*, float radius);
    void    Mesh_ComputeOcclusion  (Mesh*, Tex3D* sdf, float radius);
    void    Mesh_ComputeNormals    (Mesh*);
    void    Mesh_SplitNormals      (Mesh*, float minDot);
    Mesh*   Mesh_Box               (int res);
    Mesh*   Mesh_BoxSphere         (int res);
    Mesh*   Mesh_Plane             (Vec3f origin, Vec3f du, Vec3f dv, int resU, int resV);
  ]]
end

do -- Global Symbol Table
  Mesh = {
    Create            = libphx.Mesh_Create,
    Acquire           = libphx.Mesh_Acquire,
    Free              = libphx.Mesh_Free,
    Load              = libphx.Mesh_Load,
    Clone             = libphx.Mesh_Clone,
    ToBytes           = libphx.Mesh_ToBytes,
    FromBytes         = libphx.Mesh_FromBytes,
    FromObj           = libphx.Mesh_FromObj,
    FromSDF           = libphx.Mesh_FromSDF,
    AddIndex          = libphx.Mesh_AddIndex,
    AddMesh           = libphx.Mesh_AddMesh,
    AddQuad           = libphx.Mesh_AddQuad,
    AddTri            = libphx.Mesh_AddTri,
    AddVertex         = libphx.Mesh_AddVertex,
    AddVertexRaw      = libphx.Mesh_AddVertexRaw,
    GetVersion        = libphx.Mesh_GetVersion,
    IncVersion        = libphx.Mesh_IncVersion,
    GetBound          = libphx.Mesh_GetBound,
    GetCenter         = libphx.Mesh_GetCenter,
    GetIndexCount     = libphx.Mesh_GetIndexCount,
    GetIndexData      = libphx.Mesh_GetIndexData,
    GetRadius         = libphx.Mesh_GetRadius,
    GetVertex         = libphx.Mesh_GetVertex,
    GetVertexCount    = libphx.Mesh_GetVertexCount,
    GetVertexData     = libphx.Mesh_GetVertexData,
    ReserveIndexData  = libphx.Mesh_ReserveIndexData,
    ReserveVertexData = libphx.Mesh_ReserveVertexData,
    Validate          = libphx.Mesh_Validate,
    Draw              = libphx.Mesh_Draw,
    DrawBind          = libphx.Mesh_DrawBind,
    DrawBound         = libphx.Mesh_DrawBound,
    DrawUnbind        = libphx.Mesh_DrawUnbind,
    DrawNormals       = libphx.Mesh_DrawNormals,
    Center            = libphx.Mesh_Center,
    Invert            = libphx.Mesh_Invert,
    RotateX           = libphx.Mesh_RotateX,
    RotateY           = libphx.Mesh_RotateY,
    RotateZ           = libphx.Mesh_RotateZ,
    RotateYPR         = libphx.Mesh_RotateYPR,
    Scale             = libphx.Mesh_Scale,
    ScaleUniform      = libphx.Mesh_ScaleUniform,
    Transform         = libphx.Mesh_Transform,
    Translate         = libphx.Mesh_Translate,
    ComputeAO         = libphx.Mesh_ComputeAO,
    ComputeOcclusion  = libphx.Mesh_ComputeOcclusion,
    ComputeNormals    = libphx.Mesh_ComputeNormals,
    SplitNormals      = libphx.Mesh_SplitNormals,
    Box               = libphx.Mesh_Box,
    BoxSphere         = libphx.Mesh_BoxSphere,
    Plane             = libphx.Mesh_Plane,
  }

  if onDef_Mesh then onDef_Mesh(Mesh, mt) end
  Mesh = setmetatable(Mesh, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Mesh')
  local mt = {
    __index = {
      managed           = function (self) return ffi.gc(self, libphx.Mesh_Free) end,
      acquire           = libphx.Mesh_Acquire,
      free              = libphx.Mesh_Free,
      clone             = libphx.Mesh_Clone,
      toBytes           = libphx.Mesh_ToBytes,
      addIndex          = libphx.Mesh_AddIndex,
      addMesh           = libphx.Mesh_AddMesh,
      addQuad           = libphx.Mesh_AddQuad,
      addTri            = libphx.Mesh_AddTri,
      addVertex         = libphx.Mesh_AddVertex,
      addVertexRaw      = libphx.Mesh_AddVertexRaw,
      getVersion        = libphx.Mesh_GetVersion,
      incVersion        = libphx.Mesh_IncVersion,
      getBound          = libphx.Mesh_GetBound,
      getCenter         = libphx.Mesh_GetCenter,
      getIndexCount     = libphx.Mesh_GetIndexCount,
      getIndexData      = libphx.Mesh_GetIndexData,
      getRadius         = libphx.Mesh_GetRadius,
      getVertex         = libphx.Mesh_GetVertex,
      getVertexCount    = libphx.Mesh_GetVertexCount,
      getVertexData     = libphx.Mesh_GetVertexData,
      reserveIndexData  = libphx.Mesh_ReserveIndexData,
      reserveVertexData = libphx.Mesh_ReserveVertexData,
      validate          = libphx.Mesh_Validate,
      draw              = libphx.Mesh_Draw,
      drawBind          = libphx.Mesh_DrawBind,
      drawBound         = libphx.Mesh_DrawBound,
      drawUnbind        = libphx.Mesh_DrawUnbind,
      drawNormals       = libphx.Mesh_DrawNormals,
      center            = libphx.Mesh_Center,
      invert            = libphx.Mesh_Invert,
      rotateX           = libphx.Mesh_RotateX,
      rotateY           = libphx.Mesh_RotateY,
      rotateZ           = libphx.Mesh_RotateZ,
      rotateYPR         = libphx.Mesh_RotateYPR,
      scale             = libphx.Mesh_Scale,
      scaleUniform      = libphx.Mesh_ScaleUniform,
      transform         = libphx.Mesh_Transform,
      translate         = libphx.Mesh_Translate,
      computeAO         = libphx.Mesh_ComputeAO,
      computeOcclusion  = libphx.Mesh_ComputeOcclusion,
      computeNormals    = libphx.Mesh_ComputeNormals,
      splitNormals      = libphx.Mesh_SplitNormals,
    },
  }

  if onDef_Mesh_t then onDef_Mesh_t(t, mt) end
  Mesh_t = ffi.metatype(t, mt)
end

return Mesh
