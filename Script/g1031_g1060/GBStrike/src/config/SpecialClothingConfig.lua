---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2018/11/9 15:36
---
SpecialClothingConfig = {}
SpecialClothingConfig.specialClothing = {}

function SpecialClothingConfig:init(specialClothing)
    self:initSpecialClothing(specialClothing)
end

function SpecialClothingConfig:initSpecialClothing(specialClothing)
    for i, v in pairs(specialClothing) do
        local item = {}
        item.clothingId = v.clothingId
        item.actor = v.actor
        item.type = v.type
        table.insert(self.specialClothing, item)
    end
end

function SpecialClothingConfig:getSameTypeActor(teamId)
    local actors = {}
    for i, v in pairs(self.specialClothing) do
        if v.type == tostring(teamId) then
            table.insert(actors, v)
        end
    end
    return actors
end

return SpecialClothingConfig