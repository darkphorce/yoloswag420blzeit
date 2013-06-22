
--[[
	Gray Box (c) 2013 by Bobblehead, Bob Blackmon. http://steamcommunity.com/id/bobblackmon/

	Feel free to modify, distribute, and reinvent.
	Do not sell my code without permission. That's not cool.
	If you had to pay for this gamemode then you were conned. I advise you demand your money back.

	Enjoy!
]]

--[[---------------------------
GM:PlayerDefinition(ply)
Args: 1 = Player
Use: Called in PlayerInitialSpawn. Put all your default player variables here.
-----------------------------]]
function GM:PlayerDefinition(ply)

	ply:SetNWBool("IsOwner",false) --if you override this function, make sure to keep this line.
	
end

local meta = FindMetaTable("Player")

function meta:IsOwner()
	if CLIENT then
		return self:GetNWBool("IsOwner",false)
	else
		return (self:GetPData("IsOwner", false))
	end
end

function meta:IsDonator()
	if ulib then
		return table.HasValue(DONATOR_RANKS, self:GetUserGroup())
	end --Add more later.
end

function FindPlayer(target)
	local realtarget = {}
	for k,v in pairs(player.GetAll())do
		if string.find(v:Nick(), target) then
			realtarget[#realtarget+1] = v
		end
	end
	if #realtarget == 1 then
		return realtarget[#realtarget]
	else
		return realtarget
	end
end
player.FindByName = FindPlayer --2 ways to call this

if SERVER then
	function meta:Notify(msg, kind, time)
		if not msg then
			ErrorNoHalt("Error: No message given. Check sh_player.lua for meta:Notify()")
			debug.Trace()
			msg = "An error has occured. No message was given."
		end
		local message = [[notification.AddLegacy("]]..msg..[[", ]]..(tostring(kind) or tostring(NOTIFY_GENERIC))..[[, ]]..(tostring(time) or tostring(5))..[[)]] --kind has to be a NOTIFY_ enum.
		self:SendLua(message)
		self:SendLua("MsgN(\""..msg.."\")")
	end
else
	function meta:Notify(msg, kind, time)
		if not msg then
			ErrorNoHalt("Error: No message given. Check sh_player.lua for meta:Notify()")
			debug.Trace()
			msg = "An error has occured. No message was given."
		end
		notification.AddLegacy(msg, (kind or NOTIFY_GENERIC), (time or 5)) --kind has to be a NOTIFY_ enum.
		MsgN(msg)
	end
end