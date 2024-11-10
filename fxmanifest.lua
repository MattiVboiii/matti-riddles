fx_version("cerulean")
game("gta5")

author("MattiVboiii")
description("Simple & basic riddle script")
version("1.0.0")

lua54("yes")

ox_lib("locale")

shared_scripts({
	"@ox_lib/init.lua",
	"config.lua",
})

client_scripts({
	"client.lua",
})

server_scripts({
	"server.lua",
	"@oxmysql/lib/MySQL.lua",
})

files({
	"locales/*.json",
})
