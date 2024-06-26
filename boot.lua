--[[
	Arc Loader by Kutup Tilkisi
]]

-- TODO: system selector
local selected_system = "ultrasystem"


-- from api.lua#_rm
local function delete(path)
	local attribs = fstat(path)

	if (not attribs) then
		-- does not exist
		return
	end

	if (attribs == "folder") then
		local l = ls(path)
		for _, fn in pairs(l) do
			delete(path.."/"..fn)
		end

		-- remove metadata (not listed)
		delete(path.."/.info.pod")
	end


	-- delete single file / now-empty folder
	return _fdelete(path)
end

local function copy_system(path)
	local source_path, target_path = "/systems/"..selected_system..path, "/system"..path
	local attribs = fstat(source_path)

	if attribs == "folder" then
		mkdir(target_path)

		-- TODO: Copy over folder metadatas
		-- Right now causes an unknown crash. No log. Can't solve
		-- cp(source_path."/.info.pod", target_path."/.info.pod")
		
		local l = ls(source_path)
		for k, fn in pairs(l) do	
			copy_system(path.."/"..fn)
		end
		return
	end

	cp(source_path, target_path)
end

local function prepare_system()
	-- Create a temporary folder to store our bootloader
	mkdir("/arcloadertemp")
	cp("/system/boot.lua", "/arcloadertemp/boot.lua")

	-- Delete entire system for a fresh start
	-- TODO: Diff files? Causes too much delay to delete each file & folder
	delete("/system")
	
	-- Copy entire /system/selected_system to /system
	copy_system("")
	
	-- Copy our bootloader back to system main file
	cp("/arcloadertemp/boot.lua", "/system/boot.lua")

	-- It is required for default picotron startup. Version check creates an error.
	cp("/systems/"..selected_system.."/.info.pod", "/system/.info.pod")

	-- Delete our temporary folder.
	delete("/arcloadertemp")
end

local function run_system()
	prepare_system()

	local sysboot_src = fetch("/system/sysboot.lua")

	if type(sysboot_src) ~= "string" then
		-- TODO: See why io.write is not reachable within this file.
		-- Maybe it is related to system settings?
		io.write(pod(sysboot_src))
	end

	local booter, err = load(sysboot_src)
	if not booter then
		if system != "picotron" then
			run_system("picotron")
		end
	end

	-- Will never return. No problem
	booter()
end

run_system()
