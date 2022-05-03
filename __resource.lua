fx_version "cerulean"

game "gta5"

description 'ESX Supreme Master Jobs'
author 'SupremeBoy#2186'

version '1.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config/*.lua',
	'server/*.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config/*.lua',
	'client/*.lua'
}