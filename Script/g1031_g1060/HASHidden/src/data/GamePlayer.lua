---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaolai.
--- DateTime: 2018/11/5 14:14
---

require "base.util.class"
require "base.data.BasePlayer"
require "config.ScoreConfig"
require "Match"
require "util.RewardUtil"
require "config.ActorNpcConfig"
require "config.SkillConfig"
require "config.TigerLotteryConfig"
require "util.LotteryUtil"

GamePlayer = class("GamePlayer",BasePlayer)

GamePlayer.ROLE_PENDING = 0  -- 待定
GamePlayer.ROLE_SEEK = 1   -- 搜寻者
GamePlayer.ROLE_HIDE = 2 -- 躲藏者

GamePlayer.HAVE_ACTOR_STATE = 2
GamePlayer.USE_ACTOR_STATE = 3
GamePlayer.NOT_HAVE_ACTOR_STATE = 4

function GamePlayer:init()
    self:initStaticAttr(0)
    self.config = {}
    self.hp = 0
    self.speed = 0
    self.maxHp = 0
    self.money = 0
    self.score = 0
    self.gameScore = 0
    self.multiSeek = 0
    self.isInGame = false
    self.isLife = true
    self.role = GamePlayer.ROLE_PENDING
    self.config = {}
    self.lotteryModel = {}
    self.attackCache = {}
    self.changeModelTimes = 0
    self.changeLotteryTimes = 0
    self.actorDisappearTimes = 0
    self.actorSignTimes = 0
    self.actorMaxTimes = -1
    self.isReport = false
    self.isReady = false
    self.isAddMoney = false
    self.ifBuyLotteryThird = false
    self.gunId = {}
    self.ifSelectLottery = false
    self.defense = 0
    self.gun = {}
    self.skill = {}
    self.curPlayerModel = {}
    self.canHit = true

    self.DBActors = {}
    self.hallMoney = {}
    self.thirdId = ""
    self.haveActorIds = {}

    self.addSpeed = false
    self.addSpeedTime = 0
    self.isWiner = 0
    self.hideTime = 0
    self.killNum = 0
    self.isSingleReward = false

    self:teleInitPos()
    self:clearInv()
    self:initScorePoint()
    self:setShowName(self:buildShowName())
    HostApi.changePlayerPerspece(self.rakssid, 0)
end

function GamePlayer:initDataFromDB(data, subkey)
    if #data ~= 0 then
        local json_data = json.decode(data)
        if subkey == 1 then
            self.DBActors = json_data.actors or {}
            local index = 1
            for k,v in pairs(self.DBActors) do
                if v == GamePlayer.USE_ACTOR_STATE then
                    self.ifBuyLotteryThird = true
                    self.thirdId = k
                elseif v == GamePlayer.HAVE_ACTOR_STATE then
                    self.haveActorIds[index] = k
                    index = index + 1
                end
            end
        end
        if subkey == 2 then
            self.hallMoney = json_data.money or 0
            self:setCurrency(self.hallMoney)
        end
    end
    LotteryUtil:setThirdData(self)
    LotteryUtil:sendLotteryData(self)
end

function GamePlayer:setWeekRank(id, rank, score)
    local npc = RankNpcConfig:getRankNpc(id)
    if npc then
        RankManager:addPlayerWeekRank(self, npc.key, rank, score, function(npc)
            npc:sendRankData(self)
        end, npc)
    end
end

function GamePlayer:setDayRank(id, rank, score)
    local npc = RankNpcConfig:getRankNpc(id)
    if npc then
        RankManager:addPlayerDayRank(self, npc.key, rank, score, function(npc)
            npc:sendRankData(self)
        end, npc)
    end
end

function GamePlayer:subGunFireCd()
    self.entityPlayerMP:subGunFireCd(self.gun.itemId, self.gun.speed)
end

function GamePlayer:teleInitPos()
    self.isInGame = false
    self:teleportPos(GameConfig.initPos)
end

function GamePlayer:teleRolePos()
    if self.role == GamePlayer.ROLE_SEEK then
        self:teleportPos(GameConfig:randomSeekPos())
    end
    if self.role == GamePlayer.ROLE_HIDE then
        self:teleportPos(GameConfig:randomHidePos())
    end
end

function GamePlayer:becomeRole(role)
    if self.isInGame then
        self.role = role
        MsgSender.sendMsgToTarget(self.rakssid, Messages:becomeRole(role))
        self.config = RoleConfig:getConfigByRole(self.role)
        self.hp = self.config.hp
        self.speed = self.config.speedlevel
        self:changeMaxHealth(self.config.hp)
        self:setHealth(self.config.hp)
        if role == GamePlayer.ROLE_SEEK then
            self:setAllowFlying(true)
            self.entityPlayerMP:setOccupation(1)
            self.gunId = self.config.gunId
            self.multiSeek = self.multiSeek + 1
            HostApi.changePlayerPerspece(self.rakssid, 0)
            HostApi.sendShowHideAndSeekBtnStatus(self.rakssid, false, false, false)
        end

        if role == GamePlayer.ROLE_HIDE then
            self.entityPlayerMP:setOccupation(2)
            self.defense = self.config.defense
            self.multiSeek = 0
            self:spawnLotteryResult()
            HostApi.changePlayerPerspece(self.rakssid, 1)
            HostApi.sendShowHideAndSeekBtnStatus(self.rakssid, true, true, true)
            MsgSender.sendCenterTipsToTarget(self.rakssid, 3, Messages:becomeHideHint())
        end
        return true
    end
    return false
end

function GamePlayer:setSkill(id)
    self.skill = SkillConfig:getSkill(id)
    if self.skill ~= nil then
        self:addItem(self.skill.itemId, 1, 0)
    end
end

function GamePlayer:attackMiss()
    local gun = GunsConfig:getGunByItemId(self:getHeldItemId())
    local hurt = gun.missAttack
    self:subHealth(hurt)
end

function GamePlayer:seekAddGun()
    for i, id in pairs(self.gunId) do
        local gun = GunsConfig:getGunById(id)
        self:addGunItem(gun.itemId, 1, gun.attack, gun.bulletId)
    end
end

function GamePlayer:spawnLotteryResult()
    local curPlayerModel = {}
    local third = {}
    for i = 1, 2 do
        self.lotteryModel = LotteryUtil:randomLottery()
        curPlayerModel[#curPlayerModel + 1] = self.lotteryModel
    end
    if self.ifBuyLotteryThird == false then
        third = ""
    else
        third = self.thirdId
    end
    self.changeModelTimes = self.changeModelTimes + 1
    HostApi.sendLotteryResult(self.rakssid, tostring(curPlayerModel[1].id), tostring(curPlayerModel[2].id), third)
end

function GamePlayer:choiceActor(resultId)
    local model = TigerLotteryConfig:getActorById(resultId)
    if model ~= nil then
        self.lotteryModel = model
        EngineWorld:changePlayerActor(self, model.actor_name)
        self.ifSelectLottery = true
    end
    GameMatch:showHide(self.rakssid)
end

function GamePlayer:showChangeModel()
    if self.role ~= GamePlayer.ROLE_HIDE then
        MsgSender.sendBottomTipsToTarget(self.rakssid, 3, Messages:changeActorByNoHide())
        return
    end
    local price = ChangePriceConfig:getPriceByTime(self.changeLotteryTimes + 1)
    if price == nil then
        price = ChangePriceConfig:getPriceByTime(self.actorMaxTimes)
    end
    if self.dynamicAttr.pioneer then
        self.entityPlayerMP:setChangePlayerActor(false, self.changeModelTimes + 1, price, self.lotteryModel.actor)
    else
        self.entityPlayerMP:setChangePlayerActor(false, self.changeModelTimes + 1, price, self.lotteryModel.actor)
    end
end

function GamePlayer:changeLottery()

    local price = ChangePriceConfig:getPriceByTime(self.changeLotteryTimes + 1)
    if price == nil then
        price = ChangePriceConfig:getPriceByTime(self.actorMaxTimes)
    end
    if self.dynamicAttr.pioneer then
        self.clientPeer:buyChangeActor(false, self.changeModelTimes + 1, price)
    else
        self.clientPeer:buyChangeActor(false, self.changeModelTimes + 1, price)
    end
end

function GamePlayer:sendBuildShowName(players)
    local name = self:buildShowName()
    for i, player in pairs(players) do
        if player.role == self.role then
            self:setShowName(name, player.rakssid)
        elseif player.role ~= self.role then
            self:setShowName(" ", player.rakssid)
        end
    end
end


function GamePlayer:buildShowName()
    local nameList = {}
    local nameListNum = 1

    -- title
    if self.staticAttr.title ~= nil then
        nameList[nameListNum] = self.staticAttr.title
        nameListNum = nameListNum + 1
    end

    if self.staticAttr.role ~= -1 then
        local clanTitle = TextFormat.colorGreen .. self.staticAttr.clanName
        if self.staticAttr.role == 0 then
            clanTitle = clanTitle .. TextFormat.colorWrite .. "[Member]"
        end
        if self.staticAttr.role == 10 then
            clanTitle = clanTitle .. TextFormat.colorRed .. "[Elder]"
        end
        if self.staticAttr.role == 20 then
            clanTitle = clanTitle .. TextFormat.colorOrange .. "[Chief]"
        end
        nameList[nameListNum] = clanTitle
        nameListNum = nameListNum + 1
    end

    local roleName = self:getRoleName()
    if #roleName ~= 0 then
        nameList[nameListNum] = roleName
        nameListNum = nameListNum + 1
    end

    -- pureName line
    local disName = TextFormat.colorWrite .. self.name;
    if self.staticAttr.lv > 0 then
        disName = TextFormat.colorGold .. "[Lv" .. tostring(self.staticAttr.lv) .. "]" .. TextFormat.colorWrite .. self.name
    end

    nameList[nameListNum] = disName
    nameListNum = nameListNum + 1

    --rebuild name
    local showName
    for i, v in pairs(nameList) do
        local lineName = v
        if (showName == nil) then
            showName = lineName
        else
            showName = showName .. "\n" .. lineName;
        end
    end

    return showName
end

function GamePlayer:getRoleName()
    if self.config == nil then
        return ""
    end
    if self.role == GamePlayer.ROLE_HIDE then
        return TextFormat.colorGreen .. "[" .. self.config.name .. "]"
    elseif self.role == GamePlayer.ROLE_SEEK then
        return TextFormat.colorRed .. "[" .. self.config.name .. "]"
    else
        return ""
    end
end

function GamePlayer:addSpeedTick()
    if self.addSpeed then
        self.addSpeedTime = self.addSpeedTime + 1 
        if self.addSpeedTime == 5 then
            self:setSpeedAddition(0)
            self.addSpeedTime = 0
            self.addSpeed = false
        end
    end
end

function GamePlayer:initScorePoint()
    self.scorePoints[ScoreID.LIVE] = 0
    self.scorePoints[ScoreID.KILL] = 0
end

function GamePlayer:setCameraLocked(isLocked)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setCameraLocked(isLocked)
    end
end

function GamePlayer:changeInvisible(rakssid, invisible)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeInvisible(rakssid, invisible)
    end
end

function GamePlayer:onLive(ticks)
    if self.role == GamePlayer.ROLE_HIDE then
        if ticks % 30 == 0 and self.isLife then
            self.score = self.score + ScoreConfig.LIVE
            self.gameScore = self.gameScore + ScoreConfig.LIVE
            self:addAppIntegral(ScoreConfig.LIVE)
        end
        if self.isLife then
            self.scorePoints[ScoreID.LIVE] = self.scorePoints[ScoreID.LIVE] + 1
        end
    end
end

function GamePlayer:onHurted(hurt)
    if self:getHealth() - hurt > 0 then
        self.entityPlayerMP:setOnHurt(GameConfig.showBloodTime * 1000)
    end
end

function GamePlayer:onAttack()
    if self.hp < self.maxHp then
        self.hp = self.hp
    end
end

function GamePlayer:getModelName()
    return self.lotteryModel.name
end

function GamePlayer:death()
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setEntityHealth(0)
    end
end

function GamePlayer:onWin()
    self.isWiner = 1
    self.score = self.score + ScoreConfig.WIN
    self.gameScore = self.gameScore + ScoreConfig.WIN
    self:addAppIntegral(ScoreConfig.WIN)
end

function GamePlayer:onKill()
    self.killNum = self.killNum + 1
    self.scorePoints[ScoreID.KILL] = self.scorePoints[ScoreID.KILL] + 1
    self.score = self.score + ScoreConfig.KILL
    self.gameScore = self.gameScore + ScoreConfig.KILL
    self:addAppIntegral(ScoreConfig.KILL)
end

function GamePlayer:addAppIntegral(integral)
    if self.role == GamePlayer.ROLE_HIDE then
        self.appIntegral = self.appIntegral + integral
    elseif self.role == GamePlayer.ROLE_SEEK then
        self.appIntegral = self.appIntegral + integral * 5
    end
end

function GamePlayer:overGame(win)
    local money = math.min(self.score, 50)
    self.hallMoney = self.hallMoney + money
    
    RankNpcConfig:savePlayerRankScore(self)
    if self.role == win then
        HostApi.sendGameover(self.rakssid, IMessages:msgGameOverWin(), GameOverCode.GameOver)
    else
        HostApi.sendGameover(self.rakssid, IMessages:msgGameOver(), GameOverCode.GameOver)
    end
end

function GamePlayer:addMoney(gold)
    self:addCurrency(gold)
end

function GamePlayer:onMoneyChange()
    self.hallMoney = self:getCurrency()
    DbUtil:savePlayerData(self, true)
end

function GamePlayer:onDie()
    if self.isLife then
        self.isLife = false
        self.hp = 0
        self:clearInv()
        self:reward(false, self.defaultRank, GameMatch:getLifeTeams() == 1)
        HostApi.broadCastPlayerLifeStatus(self.userId, self.isLife)
        if self.role == self.ROLE_HIDE then
            self.hideTime = os.clock()
            HostApi.changePlayerPerspece(self.rakssid, 0)
            HostApi.sendShowHideAndSeekBtnStatus(self.rakssid, false, false, false)
        end
    end
end

function GamePlayer:reward(isWin, rank, isEnd)

    if RewardManager:isUserRewardFinish(self.userId) then
        return
    end

    UserExpManager:addUserExp(self.userId, isWin, 2)

    if isWin then
        HostApi.sendPlaySound(self.rakssid, 10023)
    else
        HostApi.sendPlaySound(self.rakssid, 10024)
    end
    ReportManager:reportUserData(self.userId, self.scorePoints[ScoreID.KILL], rank, 1)
    if isEnd then
        return
    end
    RewardManager:getUserReward(self.userId, rank, function(data)
        if GameMatch:isGameOver() == false then
            self:sendPlayerSettlement()
        end
    end)

    self.isSingleReward = true
end

function GamePlayer:sendPlayerSettlement()
    local settlement = {}
    settlement.rank = RewardUtil:getPlayerRank(self)
    settlement.name = self.name
    settlement.isWin = 0
    settlement.points = self.scorePoints
    settlement.gold = self.gold
    settlement.available = self.available
    settlement.hasGet = self.hasGet
    settlement.vip = self.vip
    settlement.kills = self.kills
    settlement.adSwitch = self.adSwitch or 0
    if settlement.gold <= 0 then
        settlement.adSwitch = 0
    end
    self:addMoney(self.gold)
    self.isAddMoney = true
    RankNpcConfig:savePlayerRankScore(self)
    HostApi.sendPlayerSettlement(self.rakssid, json.encode(settlement), false)
end

return GamePlayer
