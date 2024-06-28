--[[pod_format="raw",created="2024-06-26 12:33:32",modified="2024-06-28 12:55:46",revision=686]]
include("json.lua")
include("basexx.lua")
include("textwrap.lua")

local function get_boot_file()
	local url = "https://raw.githubusercontent.com/TunayAdaKaracan/arc-system-loader/main/boot.lua"
	local data = fetch(url)
	return data
end

local function install_loader()
	local file = get_boot_file()
	-- First create the systems folder to hold installed ones
	mkdir("/systems")
	
	-- Not sure why can't directly transfer but this is the way
	cp("/system", "/original")
	cp("/original", "/systems/picotron")
	
	-- Rename boot.lua to sysboot.lua and delete old file
	cp("/systems/picotron/boot.lua", "/systems/picotron/sysboot.lua")
	rm("/systems/picotron/boot.lua")
	
	-- Create /system folder in host so it will stay same between starts.
	rm("/system")
	cp("/original", "/system")
	rm("/original")
	
	-- Rename loaded boot.lua to sysboot.lua as well.
	cp("/system/boot.lua", "/system/sysboot.lua")
	rm("/system/boot.lua")
	
	-- Finally save system loader as boot.lua
	store("/system/boot.lua", file)
	
	store_metadata("/systems", {system="picotron"})
end

local function attach_system_selector()
	local container = gui:attach({
		x = 64-30,
		y = 20,
		width = 60,
		height=100,
		draw = function(self)
			-- I have zero idea why this is even required at all to work properly.
		end
	})
	local pulldown = container:attach_pulldown({
		x = 0,
		y = 0,
		width = 50,
		height=1000
	})
	container:attach_scrollbars()
	
	local systems = ls("/systems")
	for system in all(systems) do
		pulldown:attach_pulldown_item({
			label = system,
			stay_open = true,
			action = function(self)
				store_metadata("/systems", {system=system})
			end
		})
	end
end

local function attach_update_button()
	gui:attach_button({
		x=64-20,
		y=60,
		label="Update",
		click=function(self)
			store("/system/boot.lua", get_boot_file())
			gui:detach(self)
			is_up_to_date = true
			attach_system_selector()
		end
	})
end

is_installed = (ls("/systems")~=nil)
is_up_to_date_checked = false
is_up_to_date = nil

gui = create_gui()

if not is_installed then
	gui:attach_button({
		x=64-22,
		y=60,
		label="Install",
		click=function(self)
			install_loader()
			gui:detach(self)
			is_installed = true
		end
	})
end

function _init()
	window({
		width = 128,
		height = 128,
		resizeable = false,
		title = "Arc Installer"
	})
end

function _draw()
	cls(5)
	gui:draw_all()
	if not is_installed then
		print("Arc is not installed.")
		return
	end	
	
	if not is_up_to_date_checked then
		print("Checking boot.lua version")
		return
	end
	
	if not is_up_to_date then
		print("File is not up to date")
		return
	end
	
	print("Select your system.\nCurrent system: "..fetch_metadata("/systems").system)
end

function _update()
	if is_installed and not is_up_to_date_checked then
		is_up_to_date = get_boot_file() == fetch("/system/boot.lua")
		is_up_to_date_checked = true
		
		if not is_up_to_date then
			attach_update_button()
		else
			attach_system_selector()
		end
	end
	gui:update_all()
end