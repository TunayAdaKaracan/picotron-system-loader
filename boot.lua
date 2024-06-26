--[[
	Arc Loader by Kutup Tilkisi
]]

-- TODO: system selector
local selected_system = "picotron"

local function prepare_system(system_name)
	local path = "/systems/"..system_name.."/"
	local files = ls(path)
	
	for fileindex=0, #files do
		local file = files[fileindex]
		cp(path..file, "/system/"..file)
	end
end

local function run_system(system)
	prepare_system(system)
	
	local booter, err = load(fetch("/system/sysboot.lua"))
	if not booter then
		io.write("Can't load sysboot.lua from "..system..". Err: "..err)

		if system != "picotron" then
			run_system("picotron")
		end
	end
	-- Will never return. No problem
	booter()
end

run_system(selected_system)
