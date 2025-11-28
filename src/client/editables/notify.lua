local CONFIG = require 'src.shared.config'

local GetResourceState = GetResourceState

local function isNotifySelected(script)
    local notify = CONFIG.notify
    if notify == 'custom' and script == 'custom' then
        return true
    end

    if notify ~= 'auto' then
        if GetResourceState(notify) ~= 'started' then
            lib.print.error(string.format('%s must be started when notify type (%s) is selected', notify, notify))
            return false
        end
    end

    return notify == script or (notify == 'auto' and GetResourceState(script) == 'started')
end

return {
    ---@param self table
    ---@param source number
    ---@param data table
    ---@return nil
    SendNotify = function(self, data)
        if isNotifySelected('custom') then
            -- CUSTOM NOTIFY CODE HERE
        end

        if isNotifySelected('okokNotify') then
            return exports['okokNotify']:Alert(
                data.title,
                data.description,
                data.duration or 7000,
                data.type,
                true
            )
        end

        if isNotifySelected('ox_lib') then
            return lib.notify({
                title = data.title,
                description = data.description,
                type = data.type,
                duration = data.duration or 7000
            })
        end
    end,
}
