local INVENTORY <const> = require 'src.server.editables.inventory'
local DATABASE <const> = require 'src.server.editables.database'
local LOGGER <const> = require 'src.server.editables.log'
local REWARDS <const> = require 'src.server.data.rewards'
local CONFIG <const> = require 'src.shared.config'

local PATHS <const> = {
    'custom',
    'esx',
    'qbx',
    'qb'
}

local OPENED_DAYS = {}

if CONFIG.framework == 'auto' then
    for i = 1, #PATHS do
        FRAMEWORK = require('src.server.editables.framework.' .. PATHS[i])
        if type(FRAMEWORK) == 'table' then
            lib.print.debug('Framework found', PATHS[i])
            break
        end
    end
else
    FRAMEWORK = require('src.server.editables.framework.' .. CONFIG.framework)
    if not FRAMEWORK then
        lib.print.error(('%s must be started when framework type (%s) is selected'):format(CONFIG.framework,
            CONFIG.framework))
        return false
    end
end

---@return table
function GetFramework()
    return FRAMEWORK
end

lib.callback.register('advent_calendar:getData', function(playerSource)
    local currentMonth = os.date('%m')
    -- if currentMonth ~= 12 then
    --     return {}, false
    -- end

    local playerIdentifier = FRAMEWORK:GetPlayerIdentifier(playerSource)
    if not playerIdentifier then return {}, false end

    local currentDay = os.date('%d')
    local openedDays = DATABASE:GetOpenedDays(playerIdentifier)
    return openedDays, 10
end)

RegisterNetEvent('advent_calendar:dayOpened', function(day)
    local playerSource = source

    if not day or (day < 1 or day > 24) then
        return
    end

    local currentMonth = os.date('%m')
    local currentDay = os.date('%d')
    if currentMonth ~= 12 or currentDay < day then
        return LOGGER:ExploitLog(
            playerSource,
            'Player tried to open invalid day',
            ('  \n> **Opened Day**: %s  \n> **Current Day**: %s'):format(
                day,
                currentDay
            )
        )
    end

    local playerIdentifier = FRAMEWORK:GetPlayerIdentifier(playerSource)
    if not playerIdentifier then return end

    local success = DATABASE:OpenDay(playerIdentifier, day)
    if not success then return end

    local generatedLoot = FUNCTIONS:GenerateLoot(
        REWARDS.items,
        100.00,
        REWARDS.maxItems
    )

    for i = 1, #generatedLoot do
        INVENTORY:AddItem(
            playerSource,
            generatedLoot[i][1],
            generatedLoot[i][2]
        )
    end

    LOGGER:RewardLog(
        playerSource,
        'Player opened calendar day!',
        ('  \n> **Day**: %s  \n> **Items**: %s'):format(
            day,
            json.encode(generatedLoot)
        )
    )
end)

CreateThread(function()
    DATABASE:Initialize()
end)
