---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2018/9/19 15:11
---

GameGunsForgeNpc = class()

function GameGunsForgeNpc:ctor(config)
    self.vec3 = VectorUtil.newVector3(tonumber(config.x), tonumber(config.y), tonumber(config.z))
    self.yaw = config.yaw
    self.name = config.name
    self.actor = config.actor
    self:onCreate()
end

function GameGunsForgeNpc:onCreate()
    self.entityId = EngineWorld:addSessionNpc(self.vec3, self.yaw, 6, self.name, self.actor, "body")
    EngineWorld:getWorld():setSessionNpcEffect(self.entityId, "flag_halo_1.effect")
end

return GameGunsForgeNpc