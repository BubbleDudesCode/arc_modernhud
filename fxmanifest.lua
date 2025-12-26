fx_version 'cerulean'
game 'gta5'

author 'Arcadeon'
description 'Arcadeon Modern Hud'
version '1.0.0'

ui_page 'web/dist/index.html'

shared_script 'shared/config.lua'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'web/dist/index.html',
    'web/dist/assets/*'
}
