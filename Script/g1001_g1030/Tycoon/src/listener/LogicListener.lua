---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by work.
--- DateTime: 2018/7/9 11:03
---
require "data.GameSkill"

LogicListener = {}

function LogicListener:init()
    EntityItemSpawnEvent.registerCallBack(self.onEntityItemSpawn)
    ItemSkillAttackEvent.registerCallBack(self.onItemSkillAttack)
end

function LogicListener.onEntityItemSpawn(itemId, itemMeta, behavior)
    if itemId == 65 then
        return true
    end
    return false
end

function LogicListener.onItemSkillAttack(entityId, itemId, position)
    if GameMatch:isGameRunning() == false then
        return false
    end

    local player = PlayerManager:getPlayerByEntityId(entityId)
    if player == nil then
        return
    end
    local skill = SkillConfig:getSkill(tonumber(itemId), tonumber(player.occupationId))
    if skill ~= nil then
        GameSkill.new(skill, player, position)
    end
end

return LogicListener