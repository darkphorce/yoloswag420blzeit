
--[[
	Gray Box (c) 2013 by Bobblehead, Bob Blackmon. http://steamcommunity.com/id/bobblackmon/

	Feel free to modify, distribute, and reinvent.
	Do not sell my code without permission. That's not cool.
	If you had to pay for this gamemode then you were conned. I advise you demand your money back.

	Enjoy!
]]

function AddRoundState(name, number)
	ROUND[name] = number
end

if SERVER then
	--[[--------------------------
	GM:SetRoundState(state)
	Args: 1 = Round State
	Desc: Call this hook to change the round state. Probably shouldn't override it.
	----------------------------]]
	function GM:SetRoundState(state)
		--Do Stuff Here. Do not override unless you mean it.
		
		CURRENT_STATE=state
		hook.Call("RoundStateChanged",GAMEMODE,state)--Keep these lines if you override it.
		BroadcastLua("GAMEMODE:RoundStateChanged("..state..")")--^^^
	end
	
	function ProgressRound() --Increases round state by 1 until it reaches more than there are states, then goes to 0.
		local state = CURRENT_STATE+1
		if state > table.Count(ROUND) then state, CURRENT_ROUND = 1, CURRENT_ROUND + 1 end
		hook.Call("SetRoundState", GAMEMODE, state)
	end
end

--[[--------------------------
GM:RoundStateChanged(state)
Args: 1 = Round State; 2 = Round Number
Desc: This hook is called when the round state changes.
----------------------------]]
function GM:RoundStateChanged(state)
	
end