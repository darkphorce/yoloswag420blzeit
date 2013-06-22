
--[[
	Gray Box (c) 2013 by Bobblehead, Bob Blackmon. http://steamcommunity.com/id/bobblackmon/

	Feel free to modify, distribute, and reinvent.
	Do not sell my code without permission. That's not cool.
	If you had to pay for this gamemode then you were conned. I advise you demand your money back.

	Enjoy!
]]

config = {}
GMFile = {}
GMFile.Path=GM.Name.."/serverinfo.txt"
GMFile.Table={} --util.KeyValuesToTable(file.Read(GAMEMODE.Name.."/serverinfo.txt", "DATA")) Omit. Set it yourself.
GMFile.Save=function(data) file.Write(GAMEMODE.Name.."/serverinfo.txt", util.TableToKeyValues(data or GMFile.Table)) end
GMFile.Read=function() return util.KeyValuesToTable(file.Read(GAMEMODE.Name.."/serverinfo.txt", "DATA") or "")end

--[[Example File Table:
	GMFile.Table = {}
		GMFile.Table.CVars = {} --This is reserved for convars set with the config menu or with config.AddCVar().
			GMFile.Table.CVars["sv_cheetas"] = 1
			GMFile.Table.CVars["sv_cheats"] = 0
		GMFile.Table.SpawnPoses = {}
			GMFile.Table.SpawnPoses[1] = Vector(50,25,25)
			GMFile.Table.SpawnPoses[2] = Vector(0,25,25)
			GMFile.Table.SpawnPoses[3] = Vector(300,2,93)

]]

function config.AddCVar(cvar,value)
	local FileTable = GMFile.Read()
	PrintTable(GMFile.Read())
	PrintTable(GMFile.Read().cvars)
	FileTable.cvars[cvar] = value
	GMFile.Table = FileTable
	GMFile.Save()
end

function config.AddItem(key,value)
	local FileTable = GMFile.Read()
	FileTable[key]=value
	GMFile.Table = FileTable
	GMFile.Save()
end

function config.GetItem(key,default)
	local FileTable = GMFile.Read()
	key = string.lower(key)
	if FileTable[key] then
		return FileTable[key]
	else
		return default
	end
end

hook.Add("Initialize", "GRAY_BOX_CVAR_APPLIER", function()
	local FileTable = GMFile.Read()
	for cvar,value in pairs(FileTable.CVars or {})do
		RunConsoleCommand(cvar, value)
	end
end)