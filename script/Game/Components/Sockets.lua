local Entity = require('Game.Entity')
local Socket = require('Game.Socket')

local function iterateSocketsByType (s)
  s.i = s.i + 1
  while s.entity.sockets[s.i] do
    if s.entity.sockets[s.i].child and
       s.entity.sockets[s.i].type == s.type then
       break
     end
     s.i = s.i + 1
   end
  return s.entity.sockets[s.i] and s.entity.sockets[s.i].child
end

function Entity:addSocket (type, pos, external)
  insert(self.sockets, Socket(type, pos, external))
end

function Entity:addSockets ()
  assert(not self.sockets)
  self.sockets = {}

  -- TODO : This is just a temporary hack. We should probably create a
  --        dedicated structure for 'aggregate statistics' of entity; this
  --        will be useful in LOD simulation
  self.socketRangeMin = 1e6
  self.socketRangeMax = 0
  self.socketSpeedMin = 1e6
  self.socketSpeedMax = 0
end

function Entity:getSockets ()
  assert(self.sockets)
  return self.sockets
end

function Entity:hasSockets ()
  return self.sockets ~= nil
end

function Entity:iterSocketsByType (type)
  assert(self.sockets)
  return iterateSocketsByType, { entity = self, type = type, i = 0 }
end

function Entity:plug (child)
  assert(self.sockets)
  local type = child:getSocketType()
  for i, socket in ipairs(self.sockets) do
    if socket.type == type and socket.child == nil then
      socket.child = child
      self:attach(child, socket.pos, Quat.Identity())

      if type == SocketType.Turret then
        self.socketRangeMin = min(self.socketRangeMin, child.projRange)
        self.socketRangeMax = max(self.socketRangeMax, child.projRange)
        self.socketSpeedMin = min(self.socketSpeedMin, child.projSpeed)
        self.socketSpeedMax = max(self.socketSpeedMax, child.projSpeed)
      end

      return true
    end
  end
  return false
end

function Entity:unplug (socketIndex)
  assert(self.sockets)
  assert(self.sockets[socketIndex])
  assert(self.sockets[socketIndex].child)
  assert(false, 'NYI: Entity.unplug')
end

--[[

  function Ship:aimAt (target, firing, fallback)
    local turrets = self:getChildrenByType('Turret')
    for i = 1, #turrets do
      turrets[i].firing = turrets[i]:aimAtTarget(target) and firing or 0
    end
  end

  function Ship:init ()
    local hardpoints = proto.hardpoints

    -- TODO JP : Refactor as ship:attachModule (ThrusterType / TurretType / etc)
    do
      -- Attach turrets
      for i = 1, #hardpoints.turret do
        local pos = hardpoints.turret[i]
        local e = Entities.Turret(rng, self:getScale())
        self:attach(e, pos, Quat(0, 0, 0, 1))
        self.weaponRangeMin = min(self.weaponRangeMin, e.projRange)
        self.weaponRangeMax = max(self.weaponRangeMax, e.projRange)
      end
    end
    Profiler.End()
  end

--]]
