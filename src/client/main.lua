local NOTIFY <const> = require 'src.client.editables.notify'
local CONFIG <const> = require 'src.shared.config'

local CALENDAR_ACCENT_COLOR <const> = CONFIG.calendar.accentColor
local CALENDAR_THEME <const> = CONFIG.calendar.theme
local COMMAND <const> = CONFIG.calendar.command
local RADIAL_MENU <const> = CONFIG.radialMenu
local TREE_COORDS <const> = CONFIG.spawnTrees.coords
local TREE_MODEL <const> = CONFIG.spawnTrees.model
local INTERACTION <const> = CONFIG.interaction

local SPAM_COOLDOWN = false
local CALENDER_OPEN = false

local IsControlJustPressed = IsControlJustPressed

---@param entity integer
local function createTreeCamera(entity)
    local treeCoords = GetEntityCoords(entity)
    local treeHeading = GetEntityHeading(entity)

    local camOffset = GetOffsetFromEntityInWorldCoords(entity, -1.5, -3.4, 2.4)
    local camRotation = vec3(-20.0, 0.0, treeHeading)

    TREE_CAMERA = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(TREE_CAMERA, camOffset.x, camOffset.y, camOffset.z)
    SetCamRot(TREE_CAMERA, camRotation.x, camRotation.y, camRotation.z, 2)
    SetCamFov(TREE_CAMERA, 50.0)
    SetCamActive(TREE_CAMERA, true)
    RenderScriptCams(true, true, 1200, true, false)
end

---@param entity integer|nil
local function showCalendar(entity)
    if CALENDER_OPEN then
        return
    end

    if SPAM_COOLDOWN then
        return NOTIFY:SendNotify({
            title = locale('notify.title'),
            description = locale('notify.spam_cooldown'),
            type = 'error'
        })
    end

    SPAM_COOLDOWN = true
    SetTimeout(2000, function()
        SPAM_COOLDOWN = false
    end)

    local openedDays, currentDay = lib.callback.await(
        'advent_calendar:getData',
        false
    )

    if not currentDay then
        return NOTIFY:SendNotify({
            title = locale('notify.title'),
            description = locale('notify.not_christmas'),
            type = 'error'
        })
    end

    if #openedDays >= 24 then
        return NOTIFY:SendNotify({
            title = locale('notify.title'),
            description = locale('notify.all_opened'),
            type = 'info'
        })
    end

    if entity then
        createTreeCamera(entity)
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showCalendar',
        data = {
            openedDays = openedDays,
            theme = CALENDAR_THEME,
            accentColor = CALENDAR_ACCENT_COLOR,
            currentDay = currentDay,
            locales = {
                main_text = locale('calendar.main_text'),
                secondary_text = locale('calendar.secondary_text')
            }
        },
    })

    CALENDER_OPEN = true
end

RegisterNUICallback('dayOpened', function(data, cb)
    TriggerServerEvent('advent_calendar:dayOpened', data.day)
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    CALENDER_OPEN = false

    if TREE_CAMERA then
        RenderScriptCams(false, true, 1200, true, false)
        DestroyCam(TREE_CAMERA, false)
        TREE_CAMERA = nil
    end

    cb('ok')
end)

CreateThread(function()
    if COMMAND.enabled then
        RegisterCommand(COMMAND.name, function()
            return showCalendar()
        end, false)
    end

    if RADIAL_MENU.enabled then
        RADIAL_MENU:addItem(locale(RADIAL_MENU.locale), COMMAND.name)
    end

    for treeIndex, treeCoords in pairs(TREE_COORDS) do
        local treeEntity = FUNCTIONS:CreateObject(
            TREE_MODEL,
            treeCoords,
            false
        )

        FUNCTIONS:CreateInteractionPoint({
            name = ('calendar_tree_%s'):format(treeIndex),
            type = INTERACTION.type,
            distance = INTERACTION.distance,
            coords = treeCoords,
            entity = treeEntity,
            target = {
                label = locale(INTERACTION.target.locale),
                icon = INTERACTION.target.icon,
                distance = INTERACTION.target.distance
            },
            textUI = {
                label = locale(INTERACTION.textUI.locale),
                position = INTERACTION.textUI.position,
                icon = INTERACTION.textUI.icon,
                distance = INTERACTION.textUI.distance
            },
            marker = {
                enabled = INTERACTION.marker.enabled,
                distance = INTERACTION.marker.distance,
                color = INTERACTION.marker.color,
                scale = INTERACTION.marker.scale,
                offset = INTERACTION.marker.offset,
                type = INTERACTION.marker.type,
                options = INTERACTION.marker.options
            },
            onInteract = function()
                showCalendar(treeEntity)
            end,
            canInteract = function()
                return not CALENDER_OPEN
            end
        })
    end
end)

lib.locale()
