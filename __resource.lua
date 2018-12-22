resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Blarglebottoms Bus Route'

server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config/config.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config/unloadType.lua',
    'config/routes/airport.lua',
    'config/routes/metro.lua',
    'config/routes/scenic.lua',
    'config/config.lua',
    'client/bus.lua',
    'client/blips.lua',
    'client/markers.lua',
    'client/peds.lua',
    'client/main.lua'
}

dependencies {
    'es_extended'
}
