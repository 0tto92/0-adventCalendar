if GetResourceState('qbx_core') ~= 'started' then
    return nil
end

local CONFIG = require 'src.shared.config'

return {
    ---@param self table
    ---@param playerId number
    ---@return table
    GetPlayerFromId = function(self, playerId)
        return exports.qbx_core:GetPlayer(playerId)
    end,

    ---@param self table
    ---@param playerId number
    ---@return string
    GetPlayerFullName = function(self, playerId)
        local player = self:GetPlayerFromId(playerId)
        return player?.PlayerData?.charinfo.firstname .. ' ' .. player?.PlayerData?.charinfo.lastname
    end,

    ---@param self table
    ---@param playerId number
    ---@return string
    GetPlayerIdentifier = function(self, playerId)
        local player = self:GetPlayerFromId(playerId)
        local playerCid = player?.PlayerData?.citizenid
        local charCid = player?.PlayerData?.charinfo?.cid
        return playerCid .. '-' .. charCid
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@return integer
    GetBankBalance = function(self, playerId, account)
        return exports.qbx_core:GetMoney(playerId, account)
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@param amount integer
    ---@param reason string
    RemoveBankBalance = function(self, playerId, account, amount, reason)
        return exports.qbx_core:RemoveMoney(playerId, account, amount, reason)
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@param amount integer
    ---@param reason string
    AddBankBalance = function(self, playerId, account, amount, reason)
        return exports.qbx_core:AddMoney(playerId, account, amount, reason)
    end,

    ---@param self table
    ---@param playerId number
    ---@return boolean
    IsPlayerPolice = function(self, playerId)
        local player = self:GetPlayerFromId(playerId)
        local playerJob = player.PlayerData?.job
        return CONFIG.policeJobs[playerJob?.name]
    end,

    ---@param self table
    ---@return number
    GetOfficerCount = function(self)
        local officerAmount = 0
        for job, _ in pairs(CONFIG.policeJobs) do
            local count, _ = exports.qbx_core:GetDutyCountJob(job)
            officerAmount += count
        end

        return officerAmount
    end
}
