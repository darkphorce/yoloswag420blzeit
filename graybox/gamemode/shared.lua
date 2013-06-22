
--[[
	Gray Box (c) 2013 by Bobblehead, Bob Blackmon. http://steamcommunity.com/id/bobblackmon/

	Feel free to modify, distribute, and reinvent.
	Do not sell my code without permission. That's not cool.
	If you had to pay for this gamemode then you were conned. I advise you demand your money back.

	Enjoy!
]]

--This file is first to be included.

--=GAMEMODE DEFINITION=--
	GM.Name = "Gray Box"
	GM.Author = "Bobblehead"
	GM.Email = "bob.blackmon@ymail.com"
	GM.Website = "http://deadmansgaming.com/"
	
	DeriveGamemode("base")
--===--

--=TEAMS=--
	TEAM_SPECTATOR = 1
	team.SetUp(TEAM_SPECTATOR, "Spectators", Color(128,128,128,255))
--===--

--=GLOBAL VARIABLES=--
	DONATOR_RANKS = {}
	
	ROUND = {} --Rounds Definition
	CURRENT_ROUND = 1 --The current round. Dynamic variable.
	CURRENT_STATE = 1 --The current round state. Dynamic variable.
	--include("sh_rounds.lua")
--===--

function AddDonatorRank(rank)
	table.insert(DONATOR_RANKS, rank)
end

function table.GetNextKey(tbl,key)
	local rkey = 1
	
	for k,v in ipairs(tbl)do
		if not type(k) == "number" then continue end
		if k > key then
			rkey = k
			break
		end
	end
	return rkey
end

function table.GetPreviousKey(tbl,key)
	local rkey = #tbl
	
	for k=#tbl, 1, -1 do --Whole numbers only.
		if tbl[k] == nil then continue end
		if k < key then
			rkey = k
			break
		end
	end
	return rkey
end