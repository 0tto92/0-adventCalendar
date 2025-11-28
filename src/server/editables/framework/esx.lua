-- NOTE: IF YOU ARE USING extendedmode CHANGE 'es_extended' TO 'extendedmode'
-- CHANGE 'OLD_ESX' TO true IF YOU ARE USING OLDER VERSION OF ES_EXTENDED

if GetResourceState('es_extended') ~= 'started' then
    return nil
end

local CONFIG = require 'src.shared.config'
local ESX = exports['es_extended']:getSharedObject()
local OLD_ESX = false

return {
    ---@param self table
    ---@param playerId number
    ---@return table
    GetPlayerFromId = function(self, playerId)
        return ESX.GetPlayerFromId(playerId)
    end,

    ---@param self table
    ---@param playerId number
    ---@return string
    GetPlayerFullName = function(self, playerId)
        local player = self:GetPlayerFromId(playerId)
        return player.getName()
    end,

    ---@param self table
    ---@param playerId number
    ---@return string
    GetPlayerIdentifier = function(self, playerId)
        local player = self:GetPlayerFromId(playerId)
        return player.getIdentifier()
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@return integer
    GetBankBalance = function(self, playerId, account)
        local player = self:GetPlayerFromId(playerId)
        return player.getAccount(account).money or 0
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@param amount integer
    ---@param reason string
    RemoveBankBalance = function(self, playerId, account, amount, reason)
        local player = self:GetPlayerFromId(playerId)
        return player.removeAccountMoney(account, amount, reason)
    end,

    ---@param self table
    ---@param playerId number
    ---@param account string
    ---@param amount integer
    ---@param reason string
    AddBankBalance = function(self, playerId, account, amount, reason)
        local player = self:GetPlayerFromId(playerId)
        return player.addAccountMoney(account, amount, reason)
    end,

    ---@param self table
    ---@param playerId number
    ---@return boolean
    IsPlayerPolice = function(self, playerId)
        local player = self:GetPlayerFromId(playerId)
        local playerJob = player.getJob()
        return CONFIG.policeJobs[playerJob?.name]
    end,

    ---@param self table
    ---@return number
    GetOfficerCount = function(self)
        if OLD_ESX then
            local officerAmount = 0

            local players = ESX.GetPlayers()
            for i = 1, #players, 1 do
                local player = ESX.GetPlayerFromId(players[i])
                local playerJob = player?.job?.name

                if CONFIG.policeJobs[playerJob] then
                    officerAmount += 1
                end
            end

            return officerAmount
        end

        local officerAmount = 0
        for job, _ in pairs(CONFIG.policeJobs) do
            officerAmount += #ESX.GetExtendedPlayers('job', job)
        end

        return officerAmount
    end
}
