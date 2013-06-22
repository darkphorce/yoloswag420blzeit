 	
ENT.Type 		= "anim"
ENT.Base 		= "base_entity"

ENT.PrintName	= "Bomb"
ENT.Author		= ""
ENT.Contact		= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

AddCSLuaFile( "shared.lua" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	Msg( "Bomb Initialized" )
	ents.Create("env_explosion")
	Entity:Remove()

end
