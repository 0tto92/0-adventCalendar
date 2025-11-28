if IsDuplicityVersion() ~= 1 then
    return
end

local CONFIG = require 'src.shared.config'

local GetResourceState = GetResourceState

local function isInventorySelected(script)
    local inventory = CONFIG.inventory
    if inventory ~= 'auto' then
        local scriptName = inventory ~= 'esx' and inventory or 'es_extended'
        if GetResourceState(scriptName) ~= 'started' then
            lib.print.error(string.format('%s must be started when inventory type (%s) is selected', inventory, inventory))
            return false
        end
    end

    return inventory == script or (inventory == 'auto' and GetResourceState(script) == 'started')
end

return {
    ---@param self table
    ---@param inv number
    ---@param item string
    ---@param count number
    ---@return boolean
    AddItem = function(self, inv, item, count)
        if isInventorySelected('custom') then
            -- CODE HERE
        end

        if isInventorySelected('qs-inventory') then
            return exports['qs-inventory']:AddItem(inv, item, count)
        end

        if isInventorySelected('core_inventory') then
            return exports.core_inventory:addItem(inv, item, amount)
        end

        if isInventorySelected('ox_inventory') then
            return exports.ox_inventory:AddItem(inv, item, count)
        end

        if isInventorySelected('qb-inventory') then
            local QBCore = exports['qb-core']:GetCoreObject()
            TriggerClientEvent('qb-inventory:client:ItemBox', inv, QBCore.Shared.Items[item], 'add')
            return exports['qb-inventory']:AddItem(inv, item, count, nil, nil, '0-containerRobberyV2')
        end

        if isInventorySelected('esx') then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(inv)

            xPlayer.addInventoryItem(item, count)
            return true
        end
    end,

    ---@param self table
    ---@param inv number
    ---@param item string
    ---@param count number
    ---@return boolean
    RemoveItem = function(self, inv, item, count)
        if isInventorySelected('custom') then
            -- CODE HERE
        end

        if isInventorySelected('qs-inventory') then
            return exports['qs-inventory']:RemoveItem(inv, item, count)
        end

        if isInventorySelected('core_inventory') then
            return exports.core_inventory:removeItem(inv, item, amount)
        end

        if isInventorySelected('ox_inventory') then
            return exports.ox_inventory:RemoveItem(inv, item, count)
        end

        if isInventorySelected('qb-inventory') then
            local QBCore = exports['qb-core']:GetCoreObject()
            TriggerClientEvent('qb-inventory:client:ItemBox', inv, QBCore.Shared.Items[item], 'remove')
            return exports['qb-inventory']:RemoveItem(playerId, item, count, nil, nil, '0-containerRobberyV2')
        end

        if isInventorySelected('esx') then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(inv)

            xPlayer.removeInventoryItem(item, count)
            return true
        end
    end
}
