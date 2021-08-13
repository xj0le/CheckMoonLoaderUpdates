script_name("Check MoonLoader Updates")
script_author("j0le")

local DownloadStatus = require("moonloader").download_status
local GameKeys = require("game.keys")

function main()
	while isPlayerPlaying(PLAYER_HANDLE) == false do wait(1) end
	wait(1337)
	local FilePath = os.getenv("TEMP") .. "\\moonloader-version.json"
	downloadUrlToFile("http://blast.hk/moonloader/data/version-info.json", FilePath, function(Status)
		if Status == DownloadStatus.STATUS_ENDDOWNLOADDATA then
			local File = io.open(FilePath, "r")
			if File == true then
				local Information = decodeJson(File:read("*a"))
				if Information == true and Information.latest == true then
					local Version = tonumber(Information.latest)
					if Version > getMoonloaderVersion() then
						lua_thread.create(UI_Thread, Version)
					end
				end
			end
		end
	end)
	wait(-1)
end

function UI_Thread(NewVersion)
	setPlayerControl(PLAYER_HANDLE, false)
	setGxtEntry("CMLUTTL", "MoonLoader")
	setGxtEntry("CMLUMSG", string.format("MoonLoader Update is Available!~n~New Version: ~g~~h~.%03d~n~~w~Your Version: ~y~~h~.%03d~n~~w~Do you want to open the Download Page?", NewVersion, getMoonloaderVersion()))
	setGxtEntry("CMLUYES", "Yes")
	setGxtEntry("CMLUNO", "No")
	local UI = createMenu("CMLUTTL", 120, 110, 400, 1, true, true, 1)
	local Column = "DUMMY"
	setMenuColumn(UI, 0, "CMLUMSG", Column, Column, Column, Column, "CMLUYES", "CMLUNO", Column, Column, Column, Column, Column, Column)
	setActiveMenuItem(UI, 5)
	while true do
		wait(0)
		if isButtonPressed(PLAYER_HANDLE, GameKeys.player.ENTERVEHICLE) then
			break
		elseif isButtonPressed(PLAYER_HANDLE, GameKeys.player.SPRINT) then
			if getMenuItemSelected(UI) == 4 then
				local ffi = require("ffi")
				ffi.cdef 
				[[
					void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
					uint32_t __stdcall CoInitializeEx(void*, uint32_t);
				]]
				local Shell32 = ffi.load("Shell32")
				local Ole32 = ffi.load("Ole32")
				Ole32.CoInitializeEx(nil, 2 + 4)
				print(Shell32.ShellExecuteA(nil, "open", "http://blast.hk/moonloader", nil, nil, 1))
			end
			break
		end
	end
	wait(0)
	deleteMenu(UI)
	setPlayerControl(PLAYER_HANDLE, true)
	thisScript():unload()
end
