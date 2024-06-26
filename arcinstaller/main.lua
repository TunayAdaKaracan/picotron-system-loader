--[[pod_format="raw",created="2024-06-26 12:33:32",modified="2024-06-26 18:23:27",revision=30]]
include("json.lua")
include("basexx.lua")

local url = "https://api.github.com/repos/TunayAdaKaracan/picotron-system-loader/contents/boot.lua"
local data = json.decode(fetch(url))
local file = basexx.from_base64(data["content"], "\n")

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