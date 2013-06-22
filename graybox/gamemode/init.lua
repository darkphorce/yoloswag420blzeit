
--[[
	Gray Box (c) 2013 by Bobblehead, Bob Blackmon. http://steamcommunity.com/id/bobblackmon/

	Feel free to modify, distribute, and reinvent.
	Do not sell my code without permission. That's not cool.
	If you had to pay for this gamemode then you were conned. I advise you demand your money back.

	Enjoy!
]]

--=ADDCSLUAFILE=--
	AddCSLuaFile("cl_init.lua")
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("sh_player.lua")
	AddCSLuaFile("sh_rounds.lua")
	
--=INCLUDE SHARED=--
	include("shared.lua")
	-----
	include("sh_player.lua")
	include("sh_rounds.lua")
	
--=INCLUDE SERVER=--
	include("sv_gamemodefile.lua")
	
--===--

--=GLOBAL SERVER VARS=--
	
--===--

--=GAMEMODE FIRST RUN=--
	function FirstRunSetup(ply)
		hook.Remove("PlayerInitialSpawn", "SB_FirstRunSetup")
		timer.Simple(1,function()
			umsg.Start("FirstStart", ply)
			umsg.End()
		end)
		ply:SetServerOwner(true)
	end
	function FirstRunGamemode()
		if not file.Exists(GAMEMODE.Name.."/serverinfo.txt", "DATA") then
			MsgN("First time running "..GAMEMODE.Name.." detected. Creating data folders...")
			file.CreateDir(GAMEMODE.Name)
			local fd = {}
			fd.CVars = {sv_cheats=0}
			file.Write(GAMEMODE.Name.."/serverinfo.txt", util.TableToKeyValues(fd))
			SetGlobalBool("FirstRun", true)
			MsgN("Done!")
			if  game.IsDedicated() or (not game.SinglePlayer()) then
				MsgN("////////////////////////////////////////////////////////////////////////////////////////////////////////")
				MsgN("////////////////////////////////////////Welcome to "..GAMEMODE.Name.."!/////////////////////////////////////////")
				MsgN("//////////////////Join the server to complete the setup and claim the server as owner.//////////////////")
				MsgN("////////////////////////////////////////////////////////////////////////////////////////////////////////")
				hook.Add("PlayerInitialSpawn", "SB_FirstRunSetup", FirstRunSetup)
			else
				hook.Add("PlayerInitialSpawn", "SB_FirstRunSetup", FirstRunSetup)
			end
		else 
			SetGlobalBool("FirstRun", false)
		end
	end
	hook.Add("Initialize", "SB_FirstTimeRun", FirstRunGamemode)
	
	local meta = FindMetaTable("Player")
	function meta:SetServerOwner(b)
		self:SetNWBool("IsOwner",b)
		self:SetPData("IsOwner", b)
		if b then
			self:SendLua("notification.AddLegacy(\"You've been added as an owner of the server.\", NOTIFY_HINT, 15)")
		else
			self:SendLua("notification.AddLegacy(\"You've been removed as an owner of the server.\", NOTIFY_HINT, 15)")
		end
	end
	concommand.Add("gm_addowner", function(ply, command, args)
		if ply:IsOwner() then
			if IsValid(FindPlayer(args[1])) then
				FindPlayer(args[1]):SetServerOwner(true)
			else
				ply:Notify("That player does not exist.", NOTIFY_ERROR, 5)
			end
		else
			ply:SendLua("notification.AddLegacy(\"You are not an owner.\", NOTIFY_ERROR, 5)")
		end
	end)
	concommand.Add("gm_removeowner", function(ply, command, args)
		if ply:IsOwner() then
			if IsValid(FindPlayer(args[1])) then
				FindPlayer(args[1]):SetServerOwner(false)
			else
				ply:Notify("That player does not exist.", NOTIFY_ERROR, 5)
			end
		else
			ply:SendLua("notification.AddLegacy(\"You are not an owner.\", NOTIFY_ERROR, 5)")
		end
	end)
	local function OwnerCheck(ply)
		local istrue = ply:IsOwner()
		ply:SetNWBool("IsOwner", istrue)
	end
	hook.Add("PlayerInitialSpawn", "OwnerCheck", OwnerCheck)
--===--

function GM:Initialize()
	MsgN("SimpleBase initializing...")
		
		AddDonatorRank("donator")
		
	MsgN("SimpleBase sucessfully initialized on server.")
end

function GM:PlayerInitialSpawn(ply) --Do not override. Use hooks instead.
	hook.Call("PlayerDefinition", GAMEMODE, ply)
	ply:SetNWBool("IsOwner", ply:IsOwner()) --backup.
	-- if string.find(ply:Nick(), "Bob") then
		-- timer.Simple(.1, function() hook.Call("PlayerSpectate", GAMEMODE, ply) end)
	-- end
end

--[[--------------------------
GM:PlayerSpectate(ply)
Args: 1 = Player
Desc: Call this hook to make the player start spectating. Add to this hook to change how they do that. I sugguest overriding this function with your own spectate function. 
----------------------------]]
function GM:PlayerSpectate(ply)

	ply:StripWeapons()
	ply:SetTeam(TEAM_SPECTATOR)
	ply.SpectatedPlayer = table.Random(player.GetBots())
	ply:SpectateEntity(ply.SpectatedPlayer) --Spectate a random player.
	ply.SpectateMode = OBS_MODE_CHASE
	ply:Spectate(ply.SpectateMode)
	
	hook.Add("KeyPress", "GB_SpectateKeys", function(ply,key)
		if ply:Team() == TEAM_SPECTATOR then
			if key == IN_RELOAD then
				if ply.SpectateMode == OBS_MODE_CHASE then
					ply.SpectateMode = OBS_MODE_IN_EYE
				elseif ply.SpectateMode == OBS_MODE_IN_EYE then
					ply.SpectateMode = OBS_MODE_CHASE
				end
				ply:Spectate(ply.SpectateMode)
			elseif key == IN_DUCK then
				ply.SpectateMode = OBS_MODE_ROAMING
				ply:SpectateEntity(nil)
				ply:Spectate(OBS_MODE_ROAMING)
			elseif key == IN_ATTACK then
				local plys = {}
				for k,v in pairs(player.GetAll())do
					if not(ply:UniqueID() == v:UniqueID()) then
						table.insert(plys, v)
					end
				end
				if ply.SpectateMode == OBS_MODE_ROAMING then
					ply.SpectatedPlayer = table.Random(player.GetBots())
					ply:SpectateEntity(ply.SpectatedPlayer)
					ply.SpectateMode = OBS_MODE_CHASE
					ply:Spectate(OBS_MODE_CHASE)
				else
					local k = table.GetNextKey(plys, table.KeyFromValue(plys, ply.SpectatedPlayer or table.Random(plys)))
					if k > #plys then
						k = 1
					end
					if plys[k]:IsValid() then
						ply.SpectatedPlayer = plys[k]
						ply:SpectateEntity(ply.SpectatedPlayer)
					else
						ply.SpectateMode = OBS_MODE_ROAMING
						ply:SpectateEntity(nil)
						ply:Spectate(OBS_MODE_ROAMING)
					end
				end
			elseif key == IN_ATTACK2 then
				local plys = {}
				for k,v in pairs(player.GetAll())do
					if not(ply:UniqueID() == v:UniqueID()) then
						table.insert(plys, v)
					end
				end
				if ply.SpectateMode == OBS_MODE_ROAMING then
					ply.SpectatedPlayer = table.Random(player.GetBots())
					ply:SpectateEntity(ply.SpectatedPlayer)
					ply.SpectateMode = OBS_MODE_CHASE
					ply:Spectate(OBS_MODE_CHASE)
				else
					local k = table.GetPreviousKey(plys, table.KeyFromValue(plys, ply.SpectatedPlayer or table.Random(plys)))
					if k < 1 then
						k = #plys
					end
					if plys[k]:IsValid() then
						ply.SpectatedPlayer = plys[k]
						ply:SpectateEntity(ply.SpectatedPlayer)
					else
						ply.SpectateMode = OBS_MODE_ROAMING
						ply:SpectateEntity(nil)
						ply:Spectate(OBS_MODE_ROAMING)
					end
				end
			end
		end
	end)
	
end

util.AddNetworkString("ConfigSetting")
net.Receive("ConfigSetting", function(len, ply)
	if ply:IsOwner() then
		local cvar, value = net.ReadString(), net.ReadString()
		if (value == "true" or value == "1") then 
			value = 1
		elseif (value == "false" or value == "0")then
			value = 0
		end
		RunConsoleCommand(cvar, value)
		for k,v in pairs(player.GetHumans())do
			if v:IsOwner() then
				v:ChatPrint(ply:Nick().." set "..cvar.." to "..tostring(value)..".")
			else
				v:ChatPrint("(Someone) set "..cvar.." to "..tostring(value)..".")
			end
		end
		
		config.AddCVar(cvar,value)
	else
		ply:Kick("Only owners can modify config settings!")
	end
end)
