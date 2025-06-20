---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2019/1/8 14:43
---

PropConfig = {}

local PropConfigs = {}

function PropConfig:init(props)
    self:initProp(props)
end

function PropConfig:initProp(props)
    for Id, prop in pairs(props) do
        local propItemId = tonumber(prop.ItemId)
        local item =
        {
            propId = tonumber(Id),
            itemId = tonumber(prop.ItemId),
            name = prop.Name,
            image = prop.Image,
            damage = tonumber(prop.Damage)
        }
        PropConfigs[propItemId] = item
    end
end

function PropConfig:getPropByItemId(id)
    local prop = PropConfigs[id]
    if prop ~= nil then
        return prop
    end
    return
end

function PropConfig:getCurHandDamage(player)
    local itemId = player:getHeldItemId()
    local prop = PropConfigs[itemId]
    if prop == nil then
        return 2
    end
    for _, equip_gun in pairs(player.equip_guns) do
        if equip_gun.ItemId == itemId then
            return prop.damage + equip_gun.AddDamage
        end
    end
    return prop.damage
end
