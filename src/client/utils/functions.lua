local TARGET <const> = require 'src.client.editables.target'

local INTERACTIONS = {}

FUNCTIONS = {
    ---@param self table
    ---@param model string
    ---@param coords vector3 | vector4
    ---@param isNetworked boolean
    ---@return boolean
    CreateObject = function(self, model, coords, isNetworked)
        model = type(model) == 'string' and GetHashKey(model) or model
        if not IsModelValid(model) then
            lib.print.error(model, 'is not valid model')
            return false
        end

        lib.requestModel(model, 5000)
        local object = CreateObjectNoOffset(
            model,
            coords.x,
            coords.y,
            coords.z,
            isNetworked or false,
            true,
            false
        )

        lib.waitFor(function()
            if DoesEntityExist(object) then
                return true
            end
        end, 'Unable to create object', 5000)

        SetEntityAsMissionEntity(object, true, true)
        FreezeEntityPosition(object, true)

        if coords.w then
            SetEntityHeading(object, coords.w)
        end

        SetModelAsNoLongerNeeded(model)
        return object
    end,

    ---@param self table
    ---@param coords vector3
    ---@param sprite number
    ---@param color number
    ---@param scale integer
    ---@param name string
    ---@return number
    CreateBlip = function(self, coords, sprite, color, scale, name)
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, scale)
        SetBlipColour(blip, color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(name)
        EndTextCommandSetBlipName(blip)

        return blip
    end,

    ---@param self table
    ---@param data table
    ---@return boolean
    CreateInteractionPoint = function(self, data)
        if INTERACTIONS[data.name] then
            print(('Interaction point %s already exist'):format(data.name))

            return false
        end

        if data.entity and data.type == 'target' then
            TARGET:AddLocalEntity(data.entity, {
                options = {
                    {
                        name = data.name,
                        label = data.target.label,
                        icon = data.target.icon,
                        distance = data.target.distance,
                        onSelect = data.onInteract
                    }
                },
            })
        end

        local point = lib.points.new({
            coords = data.coords,
            distance = data.marker.distance,
            onEnter = function(self)
                if data.type == 'textUI' and self.currentDistance <= data.textUI?.distance then
                    lib.showTextUI(data.textUI.label, {
                        position = data.textUI.position,
                        icon = data.textUI.icon,
                    })

                    INTERACTIONS[data.name].textUI = true
                end
            end,
            onExit = function()
                if data.type == 'textUI' and INTERACTIONS[data.name].textUI then
                    INTERACTIONS[data.name].textUI = false
                    lib.hideTextUI()
                end
            end,
            nearby = function(self)
                if not INTERACTIONS[data.name] then
                    return
                end

                local markerCoords = vec3(
                    self.coords.x + (data.marker?.offset?.x or 0.0),
                    self.coords.y + (data.marker?.offset?.y or 0.0),
                    self.coords.z + (data.marker?.offset?.z or 0.0)
                )

                local markerColor = data.marker?.color or { r = 255, g = 255, b = 255, a = 100 }
                local markerScale = data.marker?.scale or vec3(1.0, 1.0, 1.0)
                local markerType = data.marker?.type or 1
                local markerOptions = data.marker?.options or {
                    bobUpAndDown = false,
                    faceCamera = true,
                    rotate = false
                }

                if data.marker?.enabled and self.currentDistance <= data.marker?.distance then
                    DrawMarker(2, markerCoords.x, markerCoords.y, markerCoords.z, 0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0, markerScale.x, markerScale.y, markerScale.z,
                        markerColor.r, markerColor.g, markerColor.b, markerColor.a,
                        markerOptions.bobUpAndDown, markerOptions.faceCamera, markerType,
                        markerOptions.rotate, nil, nil, false)
                end

                if data.type == 'textUI' then
                    if self.currentDistance <= data.textUI.distance then
                        if not INTERACTIONS[data.name].textUI then
                            lib.showTextUI(data.textUI.label, {
                                position = data.textUI.position,
                                icon = data.textUI.icon,
                            })

                            INTERACTIONS[data.name].textUI = true
                        end

                        if IsControlJustReleased(0, 38) then
                            if INTERACTIONS[data.name].textUI then
                                INTERACTIONS[data.name].textUI = false
                                lib.hideTextUI()
                            end

                            CreateThread(function()
                                if not data.canInteract or data.canInteract() then
                                    return data.onInteract()
                                end
                            end)
                        end
                    else
                        if INTERACTIONS[data.name].textUI then
                            INTERACTIONS[data.name].textUI = false
                            lib.hideTextUI()
                        end
                    end
                end
            end
        })

        INTERACTIONS[data.name] = point
    end,

    ---@param self table
    ---@param name string
    ---@return boolean
    RemoveInteractionPoint = function(self, name)
        local point = INTERACTIONS[name]
        if not point then
            print(string.format(
                'Unable to find interaction point %s',
                name
            ))

            return false
        end

        point:remove()
        INTERACTIONS[name] = nil
        return true
    end,
}
