---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2019/1/8 0008 10:27
---
DbUtil = {}
DbUtil.GAME_DATA = 1
DbUtil.REWARD_DATA = 5

DbUtil.GetDataCaches = {}

function DbUtil:getPlayerData(player)
    DBManager:getPlayerData(player.userId, DbUtil.GAME_DATA)
    DBManager:getPlayerData(player.userId, DbUtil.REWARD_DATA)
    local cache = {
        { DataType = DbUtil.GAME_DATA, HasGet = false },
        { DataType = DbUtil.REWARD_DATA, HasGet = false }
    }
    DbUtil.GetDataCaches[tostring(player.userId)] = cache
end

function DbUtil:onPlayerGetDataFinish(player, data, subKey)
    local cache = DbUtil.GetDataCaches[tostring(player.userId)]
    if not cache then
        cache = {
            { DataType = DbUtil.GAME_DATA, HasGet = false },
            { DataType = DbUtil.REWARD_DATA, HasGet = false }
        }
    end
    for _, tag in pairs(cache) do
        if tag.DataType == subKey then
            tag.HasGet = true
            break
        end
    end
    DbUtil.GetDataCaches[tostring(player.userId)] = cache
    player:initDataFromDB(data, subKey)
end

function DbUtil:onPlayerQuit(player)
    DbUtil.GetDataCaches[tostring(player.userId)] = nil
end

function DbUtil:savePlayerData(player, immediate)
    if player == nil then
        return
    end
    DbUtil:SavePlayerGameData(player, immediate)
    DbUtil:SavePlayerRewardData(player, immediate)
end

function DbUtil:CanSavePlayerData(player, subKey)
    local cache = DbUtil.GetDataCaches[tostring(player.userId)]
    if not cache then
        return false
    end
    for _, tag in pairs(cache) do
        if tag.DataType == subKey then
            return tag.HasGet
        end
    end
    return false
end

function DbUtil:SavePlayerGameData(player, immediate)
    if not DbUtil:CanSavePlayerData(player, DbUtil.GAME_DATA) then
        return
    end
    local data = {}
    data.level = player.level
    data.money = player.money
    data.cur_exp = player.cur_exp
    data.armor_value = player.armor_value
    data.yaoshi = player.yaoshi
    data.chests = player.chests
    data.chest_integral = player.chest_integral
    data.equip_guns = player.equip_guns
    data.equip_props = player.equip_props
    data.equip_blocks = player.equip_blocks
    data.cur_is_random = player.cur_is_random
    data.cur_map_id = player.cur_map_id
    data.mode_first = player.mode_first
    data.mode_first_day_id = player.mode_first_day_id
    data.vip_time = player.vip_time
    DBManager:savePlayerData(player.userId, DbUtil.GAME_DATA, json.encode(data), immediate)
end

function DbUtil:SavePlayerRewardData(player, immediate)
    if not DbUtil:CanSavePlayerData(player, DbUtil.REWARD_DATA) then
        return
    end
    local data = {}
    data.rewards = player.rewards
    DBManager:savePlayerData(player.userId, DbUtil.REWARD_DATA, json.encode(data), immediate)
end

return DbUtil