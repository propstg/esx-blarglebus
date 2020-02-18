fx_version 'adamant'
game 'gta5'

name 'esx-blarglebus'
description 'Blarglebottoms Bus Route'

shared_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
}

server_scripts {
    'config/config.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

client_scripts {
    'config/unloadType.lua',
    'config/busType.lua',
    'config/routes/*.lua',
    'config/config.lua',
    'client/*.lua',
}

files {
    'html/*.*'
}

dependencies {
    'es_extended'
}
