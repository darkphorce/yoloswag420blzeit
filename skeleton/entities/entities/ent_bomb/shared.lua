 	
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
	self.Entity:SetModel("models/Items/ammocrate_smg1.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
end

function ENT:OnTakeDamage()
	Msg( "Bomb Initialized" )
	ents.Create("env_explosion")
	Entity:Remove()
end