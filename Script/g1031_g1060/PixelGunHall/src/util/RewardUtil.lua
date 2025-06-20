---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2019/1/8 0008 17:40
---
RewardUtil = {}
RewardUtil.RewardType = {
    GUN_CHIP = 1,
    PROP_CHIP = 2,
    LOTTERY_CHEST = 3,
    FRAGMENT_PROGRESS = 4,
}

function RewardUtil:tryConsumeRewards(player)
    local canReward = DbUtil:CanSavePlayerData(player, DbUtil.GAME_DATA) 
        and DbUtil:CanSavePlayerData(player, DbUtil.ARMORY_DATA)
        and DbUtil:CanSavePlayerData(player, DbUtil.REWARD_DATA)
        and DbUtil:CanSavePlayerData(player, DbUtil.MODE_DATA)

    if not canReward then
        return
    end
    for _, reward in pairs(player.rewards) do
        if reward.Type == RewardUtil.RewardType.GUN_CHIP then
            RewardUtil:addPlayerGunChip(player, reward.Id, reward.Count)
        end
        if reward.Type == RewardUtil.RewardType.PROP_CHIP then
            RewardUtil:addPlayerPropChip(player, reward.Id, reward.Count)
        end
        if reward.Type == RewardUtil.RewardType.LOTTERY_CHEST then
            RewardUtil:addPlayerLotteryChest(player, reward.Id, reward.Count)
        end
        if reward.Type == RewardUtil.RewardType.FRAGMENT_PROGRESS then
            RewardUtil:addPlayerFragmentProgress(player, reward.Id, reward.Count)
        end
    end
    player.rewards = {}
end

function RewardUtil:addPlayerGunChip(player, id, count)
    GameChestLottery:onPlayerRewardGunChip(player, id, count)
end

function RewardUtil:addPlayerPropChip(player, id, count)
    GameChestLottery:onPlayerRewardPropChip(player, id, count)
end

function RewardUtil:addPlayerLotteryChest(player, id, count)
    GameChestLottery:addPlayerLotteryChest(player, id, count)
end

function RewardUtil:addPlayerFragmentProgress(player, id, count)
    if player.fragment_jindu then
        local newSign = true
        for _, item in pairs(player.fragment_jindu) do
            if tostring(id) == tostring(item.map_id) then
                item.jindu = item.jindu + count
                newSign = false
                break
            end
        end
        if newSign then
            local newItem = {}
            newItem.map_id = tostring(id)
            newItem.jindu = 1
            newItem.has_get = false
            table.insert(player.fragment_jindu, newItem)
        end

        for _, item in pairs(player.fragment_jindu) do
            -- UI has decorated the max jindu 3
            if item.jindu >= 3 and item.has_get == false then
                local gunId, fragment_num = ModeSelectMapConfig:getFragment(id)
                if gunId and fragment_num and gunId > 0 and fragment_num > 0 then
                    self:addPlayerGunChip(player, gunId, fragment_num)
                    item.has_get = true
                end
            end
        end
    end
end

return RewardUtil