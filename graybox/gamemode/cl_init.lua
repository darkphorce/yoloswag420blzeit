
--[[
	Gray Box (c) 2013 by Bobblehead, Bob Blackmon. http://steamcommunity.com/id/bobblackmon/

	Feel free to modify, distribute, and reinvent.
	Do not sell my code without permission. That's not cool.
	If you had to pay for this gamemode then you were conned. I advise you demand your money back.

	Enjoy!
]]

--=INCLUDE SHARED=--
	include("shared.lua")
	-----
	include("sh_player.lua")
	include("sh_rounds.lua")

--=INCLUDE CLIENT=--
	--include("cl_file.lua")

--===--

local ply = LocalPlayer()

function GM:PlayerInitialSpawn(ply)
	hook.Call("PlayerDefinition",GAMEMODE,ply)
end


--=FONTS=--
	function CreateNewFont(name,fd) --Creates a font with settings from size 8 to 64 going up by steps of two. To use the font use the font name followed by the size you want.
		for i=8, 64, 2 do
			surface.CreateFont( name..i, {
				font 		= fd.font or "Arial",
				size 		= i,
				weight 		= fd.weight or 500,
				blursize 	= fd.blursize or 0,
				scanlines 	= fd.scanlines or 0,
				antialias 	= fd.antialias or true,
				underline 	= fd.underline or false,
				italic 		= fd.italic or false,
				strikeout 	= fd.strikeout or false,
				symbol 		= fd.symbol or false,
				rotary 		= fd.rotary or false,
				shadow 		= fd.shadow or false,
				additive 	= fd.additive or false,
				outline 	= fd.outline or false
			})
		end
	end
--===--


--=CONFIG=--
	local OwnerMenu
	local UNSORTED_ELEMENTS = {}
	function GM:OpenConfigMenu() --DO NOT OVERRIDE UNLESS YOU HAVE A REASON.
		local ConvarsToChange = {}
		if OwnerMenu and (OwnerMenu != NULL) and (OwnerMenu:IsVisible()) then return end
		if not LocalPlayer():IsOwner() then return end
		
		local CancelButton
		local SaveButton
		local ButtonPanel
		local OptionsPanel
		local WelcomeText
		local HelpTxt
		local ElementsList
		local Collapse
		local CategoryList
		local x,y,w,h,_
		
		local function SaveConfigSettings()
			for k,v in pairs(ConvarsToChange)do
				net.Start("ConfigSetting")
					net.WriteString(v.ConVar)
					net.WriteString(v.Value)
				net.SendToServer()
			end
			for k,v in pairs(CategoryList:GetItems())do
				net.Start("ConfigSetting")
					net.WriteString(v.ConVar)
					if v.GetChecked then
						net.WriteString(tostring(v:GetChecked()))
					else
						net.WriteString(tostring(v:GetValue()))
					end
				net.SendToServer()
			end
			LocalPlayer():Notify("Your settings have been saved.", NOTIFY_HINT, 10)
		end
		
		local function AddConVarToChange(convar,value)
			table.insert(ConvarsToChange, {ConVar=convar, Value=tostring(value)})
		end

		OwnerMenu = vgui.Create('DFrame')
		OwnerMenu:SetSize(ScrW() * 0.8, ScrH() * 0.7)
		OwnerMenu:Center()
		OwnerMenu:SetTitle(GAMEMODE.Name..' Server Settings')
		OwnerMenu:SetSizable(true)
		--OwnerMenu:ShowCloseButton(false)
		OwnerMenu:SetBackgroundBlur(true)
		OwnerMenu:MakePopup()

		WelcomeText = vgui.Create('DLabel', OwnerMenu)
		WelcomeText:SetText('Welcome to '..GAMEMODE.Name.."!")
		WelcomeText:SetFont("ChatFont")
		WelcomeText:SizeToContents()
		WelcomeText:CenterHorizontal()
		x,y = WelcomeText:GetPos()
		w,h = WelcomeText:GetSize()
		WelcomeText:SetPos(x-10,22+10+h/2) --titlebar = 22
		
		HelpTxt = vgui.Create('DLabel', OwnerMenu)
		HelpTxt:SetText('(You can open this menu again with F7.) ')
		HelpTxt:SetFont("TargetIDSmall")
		HelpTxt:SizeToContents()
		HelpTxt:CenterHorizontal()
		x,_ = HelpTxt:GetPos()
		_,y = WelcomeText:GetPos()
		h = WelcomeText:GetTall()
		HelpTxt:SetPos(x-10,y+h+10) --spacer of 10 from welcome.

		SaveButton = vgui.Create('DButton', OwnerMenu)
		SaveButton:SetSize(120, 25)
		x,y = OwnerMenu:GetSize()
		x = x/2-120-2.5+(25/2) --1/4 the width, centered
		y = y-25-10 --bottom of the menu, spacer of 10
		SaveButton:SetPos(x, y)
		SaveButton:SetText('Save and Close')
		SaveButton.DoClick = function() OwnerMenu:Close(); SaveConfigSettings() end

		CancelButton = vgui.Create('DButton', OwnerMenu)
		CancelButton:SetSize(120, 25)
		x,_ = OwnerMenu:GetSize()
		x = (x/2)+2.5+(25/2) --3/4 the width, centered
		CancelButton:SetPos(x, y)
		CancelButton:SetText('Cancel')
		CancelButton.DoClick = function() OwnerMenu:Close() end
		
		ElementsList = vgui.Create("DPanelList", OwnerMenu)
		_,y = HelpTxt:GetPos()
		h = HelpTxt:GetTall()
		ElementsList:SetPos(10,y+h+10+5)
		w,h = OwnerMenu:GetSize()
		ElementsList:SetSize(w-20, h-y-20-25-10-10-10)
		ElementsList:SetSpacing( 10 )
		ElementsList:EnableHorizontal( false )
		ElementsList:EnableVerticalScrollbar( true )
		
		hook.Call("ConfigElements", GAMEMODE, ElementsList)
		
		Collapse = vgui.Create( "DCollapsibleCategory" )
		Collapse:SetPos(0,0)
		Collapse:SetPadding(10)
		w,h = ElementsList:GetSize()
		Collapse:SetSize(w-10, 300)
		Collapse:SetExpanded(false)
		Collapse:SetLabel("Other Settings")
		
		CategoryList = vgui.Create( "DPanelList" )
		CategoryList:SetAutoSize( true )
		CategoryList:SetSpacing( 10 )
		CategoryList:EnableHorizontal( false )
		CategoryList:EnableVerticalScrollbar( true )
		for k,v in pairs(UNSORTED_ELEMENTS)do
			CategoryList:AddItem(v())
		end
		Collapse:SetContents(CategoryList)
		
		if #UNSORTED_ELEMENTS != 0 then
			ElementsList:AddItem(Collapse)
		else
			Collapse:SetVisible(false)
		end	
		
	end
	usermessage.Hook("FirstStart", GM.OpenConfigMenu)
	concommand.Add("gm_serverconfig", GM.OpenConfigMenu)
	
	--[[---------------------------
	GM:ConfigElements(DForm)
	Args: 1 = The list to add your elements to
	Desc: Use this hook to add derma elements to the owner config menu. Make the elements and use DPanelList:AddItem() to add them to the config menu.
	Other: The argument is a DPanelList. For info, see http://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/indexcc5c.html
	-----------------------------]]
	function GM:ConfigElements(DPanelList)
		--An example of how to add items. You should probably keep this.
		local Collapse
		local CategoryList
		local List
		local x,y,w,h,_
		
		Collapse = vgui.Create( "DCollapsibleCategory" )
		Collapse:SetPos(0,0)
		Collapse:SetPadding(10)
		w,h = DPanelList:GetSize()
		Collapse:SetSize(w-10, 180)
		Collapse:SetExpanded(false)
		Collapse:SetLabel("Give or Revoke Ownership")
		
		CategoryList = vgui.Create( "DPanelList" )
		CategoryList:SetAutoSize( true )
		CategoryList:SetSpacing( 10 )
		CategoryList:EnableHorizontal( false )
		CategoryList:EnableVerticalScrollbar( true )
		Collapse:SetContents(CategoryList)
		
		List = vgui.Create("DListView")
		List:SetSize(w-20,180)
		List:AddColumn("Player")
		List:AddColumn("SteamID")
		List:AddColumn("Is Owner?")
		List:SetMultiSelect(false)
		function List:OnRowSelected( line )
			local DropDown = DermaMenu() -- Creates the menu
			if self:GetLine(line):GetValue(3) == "Yes" then
				DropDown:AddOption("Revoke Ownership", function() RunConsoleCommand("gm_removeowner" , self:GetLine(line):GetValue(1)); timer.Simple(.4,List.Refresh); LocalPlayer():Notify("You have given "..self:GetLine(line):GetValue(1).." ownership status.", NOTIFY_GENERIC, 15) end )
			else
				DropDown:AddOption("Give Ownership", function() RunConsoleCommand("gm_addowner" , self:GetLine(line):GetValue(1)); timer.Simple(.4,List.Refresh); LocalPlayer():Notify("You have revoked "..self:GetLine(line):GetValue(1).."'s ownership status.", NOTIFY_GENERIC, 15) end )
			end
			DropDown:AddOption("Cancel", function() end)
			DropDown:Open() -- Open the menu AFTER adding your options
		end
		function List:Refresh()
			List:Clear()
			for k,v in pairs(player.GetHumans())do
				local x = v:IsOwner()
				if x then x = "Yes" else x = "No" end
				List:AddLine(v:Nick(), v:SteamID(), x)
			end
		end
		List:Refresh()
		
		CategoryList:AddItem(List)--Add the list to the collapsable category.
		
		DPanelList:AddItem(Collapse)--Add the collapsable category to the Config Menu.
		
	end
	
	hook.Add("Think", "F7ConfigOpen", function(ply,bind)
		if input.IsKeyDown(KEY_F7) then
			hook.Call("OpenConfigMenu",GAMEMODE)
		end
	end)
	
	function AddConfigElement(func)--Adds an element to the Config. Easy to use, but it's not sorted into categories.
		--func must be a function that returns a panel object.
		--Supported classes are DCheckBoxLabel, DNumberWang, DTextEntry, DComboBox, DScratch, DNumSlider 
		table.insert(UNSORTED_ELEMENTS, func)
	end

	--Example Use of AddConfigElement(func)
	--[[
	
		AddConfigElement(function(DPanelList)
			local CheatsCheckBox = vgui.Create("DCheckBoxLabel")
			CheatsCheckBox:SetText( "Disallow Bot Movement?" )
			CheatsCheckBox.ConVar = "bot_zombie" --THIS VARIABLE MUST EXIST OR NOTHING WILL HAPPEN.
			CheatsCheckBox:SetValue( GetConVarNumber(CheatsCheckBox.ConVar) )
			CheatsCheckBox:SizeToContents()
			return CheatsCheckBox
		end)
		
		AddConfigElement(function(DPanelList)
			
			local slide = vgui.Create("DNumSlider")
			slide:SetSize(100,50)
			slide:SetText("Gravity")
			slide:SetDecimals(0)
			slide:SetMin(0)
			slide:SetMax(1000)
			slide.ConVar = "sv_gravity"
			slide:SetValue(GetConVarNumber(slide.ConVar))
			
			return slide
			
		end)
	
	]]
--===--