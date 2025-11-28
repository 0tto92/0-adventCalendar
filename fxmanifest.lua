author '0ttoo'
description 'Advent Calendar'
version '1.0.0'

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'web/build/index.html'

client_scripts {
    '**/client/**.lua'
}

server_scripts {
    '**/server/**.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    '**/shared/**.lua'
}

files {
    'locales/*.json',
    'web/build/index.html',
    'web/build/**/*'
}

escrow_ignore {
    'locales/*.json',
    '**/config.lua',
    '**/editables/**.lua',
    '**/data/**.lua',

    -- '**/client/**.lua',
    -- '**/server/**.lua',
    -- '**/shared/**.lua',
}
