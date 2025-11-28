Wait(1000)

local RESOURCE_NAME = GetCurrentResourceName()
local CURRENT_VERSION = GetResourceMetadata(RESOURCE_NAME, 'version', 0)
local GITHUB_PATH = (
    'https://raw.githubusercontent.com/0tto92/script-versions/refs/heads/main/%s'
):format(RESOURCE_NAME)

---@param errorCode integer
---@param resultData string
---@param resultHeaders table<string, string>
---@param errorData string
PerformHttpRequest(GITHUB_PATH, function(errorCode, resultData, resultHeaders, errorData)
    if not resultData then
        return print('^1Version check failed: ^3The resource name was changed.^0')
    end

    local resultText = resultData:gsub('\n', '')
    if CURRENT_VERSION ~= resultText then
        print('^1-------------[' .. RESOURCE_NAME .. ']-------------')
        print('^3New Version Available: ' .. resultText)
        print('^3Current Version: ' .. CURRENT_VERSION)
        print('^1-------------[' .. RESOURCE_NAME .. ']-------------^0')
    end
end, 'GET')
