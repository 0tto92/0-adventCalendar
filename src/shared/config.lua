return {
    framework = 'auto', -- auto / esx / qb / qbx / custom
    notify = 'auto',    -- auto / ox_lib / okokNotify / custom
    inventory = 'auto', -- auto / esx / ox_inventory / qb-inventory / core_inventory / qs-inventory / custom

    interaction = {
        type = 'textUI', -- target / textUI

        textUI = {
            distance = 2.5,
            locale = 'textUI.open_calendar',
            position = 'right-center',
            icon = 'fa-solid fa-gift'
        },

        target = {
            script = 'auto', -- auto / ox_target / qb-target / custom
            locale = 'target.open_calendar',
            icon = 'fa-solid fa-gift',
            distance = 2.5
        },

        marker = {
            enabled = true,
            distance = 10.0,
            color = { r = 20, g = 200, b = 20, a = 50 },
            offset = vec3(0.0, 0.0, 2.6),
            scale = vec3(0.3, 0.2, 0.2),
            type = 2,
            options = {
                bobUpAndDown = true,
                faceCamera = false,
                rotate = true
            }
        },
    },

    spawnTrees = {
        enabled = true,
        model = `prop_xmas_tree_int`,
        coords = {
            vec4(166.070, -982.164, 29.359, 0.000)
        }
    },

    calendar = {
        accentColor = '#a855f7',
        theme = 'dark', -- dark / light
        command = {
            enabled = true,
            name = 'advent_calendar'
        },
    },

    radialMenu = {
        enabled = true,
        locale = 'radial_menu.open_calendar',
        addItem = function(self, label, command)
            lib.addRadialItem({
                id = 'advent_calendar',
                icon = 'fa-solid fa-gift',
                label = label,
                onSelect = function()
                    ExecuteCommand(command)
                end
            })
        end,
    },
}
