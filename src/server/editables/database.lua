local CONFIG <const> = require 'src.shared.config'
local TIMEOUT <const> = 150

local CACHE = {
    players = {}
}

return {
    ---@param self table
    Initialize = function(self)
        self:CreateTable()

        SetTimeout(500, function()
            self:CleanTable(30)
        end)
    end,

    ---@param self table
    CreateTable = function(self)
        exports.oxmysql:execute([[
            CREATE TABLE IF NOT EXISTS `advent_calendar` (
                id INT AUTO_INCREMENT PRIMARY KEY,
                identifier VARCHAR(64) NOT NULL,
                opened_days JSON NOT NULL DEFAULT (JSON_ARRAY()),
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY `unique_identifier` (`identifier`)
            )
        ]])

        if CONFIG.debug then
            lib.print.info('Database table "advent_calendar" is ready')
        end

        return true
    end,

    ---@param self table
    ---@param days integer
    CleanTable = function(self, days)
        exports.oxmysql:update_async(
            'DELETE FROM `advent_calendar` WHERE last_updated < NOW() - INTERVAL ? DAY',
            { days }
        )
    end,

    ---@param self table
    ---@param identifier string|integer
    ---@return table
    ---@return boolean
    GetOpenedDays = function(self, identifier)
        local cached = CACHE.players[identifier]
        if cached and (os.time() - cached.lastFetch < TIMEOUT) then
            return cached.data, true
        end

        local row = exports.oxmysql:single_async(
            'SELECT opened_days FROM advent_calendar WHERE identifier = ? LIMIT 1',
            { identifier }
        )

        local openedDays = row and json.decode(row.opened_days) or {}

        CACHE.players[identifier] = {
            data = openedDays or {},
            lastFetch = os.time()
        }

        return openedDays, false
    end,

    ---@param self table
    ---@param identifier string|integer
    ---@param day integer
    ---@return table
    OpenDay = function(self, identifier, day)
        if not identifier or not day then
            return false
        end

        local openedDays = self:GetOpenedDays(identifier)
        for i = 1, #openedDays do
            if openedDays[i] == day then
                return false
            end
        end

        table.insert(openedDays, day)

        exports.oxmysql:update_async(
            [[INSERT INTO advent_calendar (identifier, opened_days)
              VALUES (?, ?)
              ON DUPLICATE KEY UPDATE opened_days = VALUES(opened_days)]],
            { identifier, json.encode(openedDays) }
        )

        CACHE.players[identifier] = {
            data = openedDays,
            lastFetch = os.time()
        }

        return true, openedDays
    end
}
