---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaolai.
--- DateTime: 2018/11/16 14:45
---

GunsConfig = {}
GunsConfig.guns = {}

function GunsConfig:init(config)
    self:initGuns(config)
end

function GunsConfig:initGuns(config)
    for id, gun in pairs(config) do
        local item = {}
        item.id = id
        item.itemId = tonumber(gun.itemId)
        item.name = gun.name
        item.image = gun.image
        item.type = tonumber(gun.type)
        item.knockback = tonumber(gun.knockback)
        item.attack = tonumber(gun.attack)
        item.range = tonumber(gun.range)
        item.speed = tonumber(gun.speed)
        item.bulletId = tonumber(gun.bulletId)
        item.maxBullet = tonumber(gun.maxBullet)
        item.bulletPerShoot = tonumber(gun.bulletPerShoot)
        item.initialItemId = tonumber(gun.initialItemId)
        item.missAttack = tonumber(gun.missAttack)
        self.guns[id] = item
    end
    self:prepareGuns()
end

function GunsConfig:prepareGuns()
    for i, gun in pairs(self.guns) do
        HostApi.setGunSetting(self.newGunSetting(gun))
    end
end

function GunsConfig.newGunSetting(gun)
    local setting = GunPluginSetting.new()
    setting.gunId = gun.itemId
    setting.gunType = gun.type
    setting.maxBulletNum = gun.maxBullet
    setting.damage = gun.attack
    setting.knockback = gun.knockback
    setting.bulletId = gun.bulletId
    setting.shootRange = gun.range
    setting.cdTime = gun.speed
    setting.bulletPerShoot = gun.bulletPerShoot
    return setting
end

function GunsConfig:getGunById(gunid)
    for id, gun in pairs(self.guns) do
        if gun.id == gunid then
            return gun
        end
    end
end

function GunsConfig:getGunByItemId(item)
    for id, gun in pairs(self.guns) do
        if gun.itemId == tonumber(item) then
            return gun
        end
    end
end

return GunsConfig