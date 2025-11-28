if IsDuplicityVersion() ~= 1 then
    return
end

local WEBHOOKS = require 'src.server.data.webhooks'

return {
    GetPlayerIdentifiers = function(self, source)
        local identifiers = '\n **Player Identifiers**'
        identifiers = identifiers .. '\n > **steam:** ' .. GetPlayerName(source)

        local playerIdentifiers = GetPlayerIdentifiers(source)
        for _, identifier in pairs(playerIdentifiers) do
            local i, j = identifier:find(':')

            if identifier:sub(1, j) == 'discord:' then
                identifiers = identifiers .. '\n > **' ..
                    identifier:sub(1, j) .. '** <@' ..
                    identifier:sub(j + 1, identifier:len()) .. '>'

                goto skip
            end

            identifiers = identifiers .. '\n > **' ..
                identifier:sub(1, j) .. '** ' ..
                identifier:sub(j + 1, identifier:len())

            ::skip::
        end

        return identifiers
    end,

    SendLog = function(self, source, webhook, title, description, color, username)
        local identifiers = self:GetPlayerIdentifiers(source)
        return PerformHttpRequest(
            webhook,
            function(err, text, headers)
                -- print(err, text, headers)
            end,
            'POST',
            json.encode(
                {
                    username = username,
                    embeds = {
                        {
                            color = color,
                            title = title,
                            description = description .. identifiers
                        }
                    }
                }
            ),
            {
                ['Content-Type'] = 'application/json'
            }
        )
    end,

    ExploitLog = function(self, source, title, description)
        local webhook = WEBHOOKS['exploit']
        return self:SendLog(source, webhook.url, title, description, webhook.color, webhook.username)
    end,

    RewardLog = function(self, source, title, description)
        local webhook = WEBHOOKS['reward']
        return self:SendLog(source, webhook.url, title, description, webhook.color, webhook.username)
    end,
}
