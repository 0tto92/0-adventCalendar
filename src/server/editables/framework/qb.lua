if GetResourceState('qb-core') ~= 'started' then
    return nil
end

local CONFIG = require 'src.shared.config'
local QBCore = exports['qb-core']:GetCoreObject()

return {
    ---@param self table
    ---@param playerId number
    ---@return table
    GetPlayerFromId = function(self, playerId)
        return QBCore.Functions.GetPlayer(playerId)
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
        return player?.PlayerData?.cid
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@return integer
    GetBankBalance = function(self, playerId, account)
        local player = self:GetPlayerFromId(playerId)
        return Player.Functions.GetMoney(account) or 0
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@param amount integer
    ---@param reason string
    RemoveBankBalance = function(self, playerId, account, amount, reason)
        local player = self:GetPlayerFromId(playerId)
        return Player.Functions.RemoveMoney(account, amount)
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@param amount integer
    ---@param reason string
    AddBankBalance = function(self, playerId, account, amount, reason)
        local player = self:GetPlayerFromId(playerId)
        return Player.Functions.AddMoney(account, amount)
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

        local players = QBCore.Functions.GetQBPlayers()
        for i = 1, #players, 1 do
            local player = players[i]
            local playerJob = player?.PlayerData?.job?.name

            if CONFIG.policeJobs[playerJob] then
                officerAmount += 1
            end
        end

        return officerAmount
    end
}
