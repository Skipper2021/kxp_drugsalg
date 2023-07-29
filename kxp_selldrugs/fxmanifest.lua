fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Kian x Poke'
description 'Avanceret drugsalg system.'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
}

escrow_ignore {
	'config.lua',
}
  
dependencies {
	'es_extended',
	'/assetpacks',
	'ox_target',
	'ox_lib',
}