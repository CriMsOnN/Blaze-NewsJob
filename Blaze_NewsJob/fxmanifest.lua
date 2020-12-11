fx_version 'adamant'

game 'gta5'

description 'News Job'

version '1.0.0'

client_scripts {
    'shared/config.lua',
    'client/main.lua',
    'client/ped.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
    'shared/config.lua',
    'server/main.lua'
}