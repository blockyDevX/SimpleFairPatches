---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2018/11/5 0005 11:15
---
SweepstakesUtil = {}
SweepstakesUtil.prob = {}
SweepstakesUtil.alias = {}

function SweepstakesUtil:init(data, prob, alias)
    local nums = #data
    local small = {}
    local large = {}
    for i = 1, nums do
        --扩大倍数，使每列高度可为1
        data[i] = data[i] * nums
        --分到两个数组，便于组合
        if data[i] < 1 then
            table.insert(small, i)
        else
            table.insert(large, i)
        end
    end
    --将超过1的色块与原色拼凑成1
    while #small > 0 and #large > 0 do
        local n_index = table.remove(small, 1)
        local a_index = table.remove(large, 1)
        prob[n_index] = data[n_index];
        alias[n_index] = a_index;
        --重新调整大色块
        data[a_index] = data[a_index] + data[n_index] - 1;
        if data[a_index] < 1 then
            table.insert(small, a_index)
        else
            table.insert(large, a_index)
        end
    end
    --将超过1的色块与原色拼凑成1
    while #large > 0 do
        local n_index = table.remove(large, 1)
        prob[n_index] = 1;
    end
    --一般是精度问题才会执行这一步
    while #small > 0 do
        local n_index = table.remove(small, 1)
        prob[n_index] = 1;
    end
    return prob, alias
end

function SweepstakesUtil:generation(prob, alias)
    if prob == nil or alias == nil then
        return 1
    end
    local nums = #prob
    local MAX_P = 100000; --假设最小的几率是十万分之一
    local coin_toss = math.random(1, MAX_P) / MAX_P; --抛出硬币
    local col = math.random(1, nums) --随机落在一列
    local b_head = coin_toss < prob[col] --判断是否落在原色
    if b_head then
        return col
    else
        return alias[col]
    end
end

function SweepstakesUtil:initRandomSeed(remark, data) 
    self.prob[remark], self.alias[remark] = self:init(data, {}, {})
end

function SweepstakesUtil:get(remark)
    return self:generation(self.prob[remark], self.alias[remark])
end

function SweepstakesUtil:setRandomSeed()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
end

return SweepstakesUtil