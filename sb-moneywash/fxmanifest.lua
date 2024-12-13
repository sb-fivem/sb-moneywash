fx_version 'cerulean'
game 'gta5'

author 'sb'
description 'Portable Money-Wash System'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/items.lua',
    'config.lua'  -- Make sure this is included as a shared script
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-inventory'
}
