local CONFIG = require 'src.shared.config'

local function isTargetSelected(script)
    local target = CONFIG.interaction.target.script
    if target == 'custom' and script == 'custom' then
        return true
    end

    if target ~= 'auto' then
        if GetResourceState(target) ~= 'started' then
            lib.print.error(string.format('%s must be started when dispatch type (%s) is selected',
                target, target))
            return false
        end
    end

    return target == script or (target == 'auto' and GetResourceState(script) == 'started')
end

local function createOptions(target, data)
    local options = {}
    if target == 'ox_target' then
        for i = 1, #data.options do
            options[i] = {
                label = data.options[i].label,
                name = data.options[i].name,
                distance = data.options[i].distance,
                icon = data.options[i].icon,
                items = data.options[i].items,
                groups = data.options[i].groups,
                onSelect = function(_data)
                    if type(data.options[i].onSelect) == 'function' then
                        return data.options[i].onSelect(_data)
                    end
                end,
                canInteract = function(_entity, _distance, _coords, _name, _bone)
                    if type(data.options[i].canInteract) == 'function' then
                        return data.options[i].canInteract({
                            entity = _entity,
                            distance = _distance,
                            coords = _coords,
                            name = _name,
                            bone = _bone
                        })
                    end

                    return true
                end,
            }
        end
    end

    if target == 'qb-target' then
        for i = 1, #data.options do
            options[i] = {
                label = data.options[i].label,
                name = data.options[i].name,
                icon = data.options[i].icon,
                item = data.options[i].items,
                job = data.options[i].groups,
                action = function(_entity)
                    if type(data.options[i].onSelect) == 'function' then
                        return data.options[i].onSelect({
                            entity = _entity
                        })
                    end
                end,
                canInteract = function(_entity, _distance, _data)
                    if type(data.options[i].canInteract) == 'function' then
                        return data.options[i].canInteract({
                            entity = _entity,
                            distance = _distance,
                            data = _data
                        })
                    end

                    return true
                end,
            }
        end
    end

    if target == 'custom' then
        -- CUSTOM TARGET CODE HERE
    end

    return options
end

return {
    ---@param self table
    ---@param data table
    AddBoxZone = function(self, data)
        if isTargetSelected('ox_target') then
            local options = createOptions('ox_target', data)

            return exports.ox_target:addBoxZone({
                name = data.name,
                coords = data.coords.xyz,
                rotation = data.coords.w,
                size = data.size,
                debug = data.debug,
                options = options
            })
        end

        if isTargetSelected('qb-target') then
            local options = createOptions('qb-target', data)
            local targetName = data.name or (data.options[1].name or lib.string.random('.', 4))

            return exports['qb-target']:AddBoxZone(
                targetName,
                data.coords.xyz,
                data.size.x,
                data.size.y,
                {
                    name = targetName,
                    heading = data.coords.w,
                    debugPoly = data.debug,
                    minZ = data.coords.z - (data.size.z / 2),
                    maxZ = data.coords.z + (data.size.z / 2),
                }, {
                    options = options,
                    distance = data.options[1].distance or 2.0,
                }
            )
        end

        if isTargetSelected('custom') then
            -- CUSTOM TARGET CODE HERE
        end
    end,

    ---@param self table
    ---@param entities string|table
    ---@param data table
    AddModel = function(self, entities, data)
        if isTargetSelected('ox_target') then
            local options = createOptions('ox_target', data)
            return exports.ox_target:addModel(entities, options)
        end

        if isTargetSelected('qb-target') then
            local options = createOptions('qb-target', data)
            exports['qb-target']:AddTargetModel(entities, {
                options = options,
                distance = data.options[1].distance or 2.0,
            })
        end

        if isTargetSelected('custom') then
            -- CUSTOM TARGET CODE HERE
        end
    end,

    ---@param self table
    ---@param entities string|table
    ---@param data table
    AddLocalEntity = function(self, entities, data)
        if isTargetSelected('ox_target') then
            local options = createOptions('ox_target', data)
            return exports.ox_target:addLocalEntity(entities, options)
        end

        if isTargetSelected('qb-target') then
            local options = createOptions('qb-target', data)
            exports['qb-target']:AddTargetEntity(entities, {
                options = options,
                distance = data.options[1].distance or 2.0,
            })
        end

        if isTargetSelected('custom') then
            -- CUSTOM TARGET CODE HERE
        end
    end,

    ---@param self table
    ---@param entities string|table
    ---@param optionNames string|table
    RemoveLocalEntity = function(self, entities, optionNames)
        if isTargetSelected('ox_target') then
            return exports.ox_target:removeLocalEntity(entities, optionNames)
        end

        if isTargetSelected('qb-target') then
            return exports['qb-target']:RemoveTargetEntity(entities, optionNames)
        end

        if isTargetSelected('custom') then
            -- CUSTOM TARGET CODE HERE
        end
    end,

    ---@param self table
    ---@param name string
    RemoveZone = function(self, name)
        if isTargetSelected('ox_target') then
            return exports.ox_target:removeZone(name)
        end

        if isTargetSelected('qb-target') then
            return exports['qb-target']:RemoveZone(name)
        end

        if isTargetSelected('custom') then
            -- CUSTOM TARGET CODE HERE
        end
    end,

    ---@param self table
    ---@param state boolean
    SetTargetState = function(self, state)
        if isTargetSelected('ox_target') then
            return exports.ox_target:disableTargeting(not state)
        end

        if isTargetSelected('qb-target') then
            return exports['qb-target']:AllowTargeting(state)
        end

        if isTargetSelected('custom') then
            -- CUSTOM TARGET CODE HERE
        end
    end,
}
