fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'RiverFreez'
description 'Mini job pizza'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    '@vPrompt/vprompt.lua',
    'client/cl_pizza.lua'
}

server_scripts {
    'server/sv_pizza.lua'
}

dependencies {
    'vPrompt',
    'es_extended'
}