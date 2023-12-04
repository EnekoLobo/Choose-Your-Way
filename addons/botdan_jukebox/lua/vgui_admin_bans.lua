JukeBox.VGUI.Pages.AdminBans = {}

function JukeBox.VGUI.Pages.AdminBans:CreatePanel( parent )
	parent.Top = vgui.Create( "DPanel", parent )
	parent.Top:Dock( TOP )
	parent.Top:SetTall( 42 )
	parent.Top.Paint = function( self, w, h )
		draw.RoundedBox( 12, 5, 10, h, h-20, Color( 255, 255, 255 ) )
		draw.RoundedBox( 12, 5+200, 10, h, h-20, Color( 255, 255, 255 ) )
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 14, "jukebox/search.png", JukeBox.Colours.Base, 0 )
		if (parent.Top.Search.Issue == 0) then
			draw.SimpleText( "There's a total of "..parent.Scroll.Count.." bans.", "JukeBox.Font.16", 260, h/2, Color( 200, 200, 200 ), 0, 1 )
		elseif (parent.Top.Search.Issue == 1) then
			draw.SimpleText( "Search found "..parent.Scroll.Count.." bans.", "JukeBox.Font.16", 260, h/2, Color( 200, 200, 200 ), 0, 1 )
		elseif (parent.Top.Search.Issue == 2) then
			draw.SimpleText( "Search returned no results.", "JukeBox.Font.16", 260, h/2, Color( 200, 200, 200 ), 0, 1 )
		end
	end

	parent.Top.Search = vgui.Create( "DTextEntry", parent.Top )
	parent.Top.Search:Dock( LEFT )
	parent.Top.Search:DockMargin( 28, 10, 0, 10 )
	parent.Top.Search:SetWide( 200 )
	parent.Top.Search:SetFont( "JukeBox.Font.16" )
	parent.Top.Search:SetDrawBorder( false )
	parent.Top.Search.Issue = 0
	parent.Top.Search.OnChange = function( self, w, h )
		if self:GetValue() != "" then
			parent.Scroll:SearchBans( self:GetValue() )
			self.Issue = 1
		else
			parent.Scroll:UpdateBans()
			self.Issue = 0
		end
	end
	parent.Top.Search.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color(30, 130, 255), JukeBox.Colours.Base)
	end
	
	parent.Top.AddBan = vgui.Create( "DButton", parent.Top )
	parent.Top.AddBan:Dock( RIGHT )
	parent.Top.AddBan:DockMargin( 0, 6, 10, 6 )
	parent.Top.AddBan:SetWide( 115 )
	parent.Top.AddBan:SetText( "" )
	parent.Top.AddBan.DoClick = function()
		JukeBox.VGUI.Pages.AdminBans:AddBan( parent )
	end
	parent.Top.AddBan.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 16, "jukebox/edit.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( "Add a Ban", "JukeBox.Font.20", 30, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	
	parent.Header = vgui.Create( "DPanel", parent )
	parent.Header:Dock( TOP )
	parent.Header:SetTall( 40 )
	parent.Header.Paint = function( self, w, h )
		draw.SimpleText( "NAME", "JukeBox.Font.18", 70, h/2, Color( 200, 200, 200 ), 0, 1 )
		draw.SimpleText( "STEAMID", "JukeBox.Font.18", w*0.3, h/2, Color( 200, 200, 200 ), 0, 1 )
		draw.SimpleText( "REQUEST BAN", "JukeBox.Font.18", w-350, h/2, Color( 200, 200, 200 ), 1, 1 )
		draw.SimpleText( "QUEUE BAN", "JukeBox.Font.18", w-200, h/2, Color( 200, 200, 200 ), 1, 1 )
		draw.SimpleText( "ACTIONS", "JukeBox.Font.18", w-35, h/2, Color( 200, 200, 200 ), 2, 1 )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
	end
	
	parent.Scroll = vgui.Create( "DScrollPanel", parent )
	parent.Scroll:Dock( FILL )
	parent.Scroll.Count = 0
	parent.Scroll.VBar:SetWide( 10 )
	parent.Scroll.Paint = function( self, w, h )
	
	end
	parent.Scroll.VBar.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	parent.Scroll.VBar.btnGrip.Paint = function( self, w, h )
		draw.RoundedBox( w/2, 0, 0, w, h, JukeBox.Colours.Light )
	end
	parent.Scroll.VBar.btnUp.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 0 )
	end
	parent.Scroll.VBar.btnDown.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 180 )
	end
	function parent.Scroll:SearchBans( value )
		self:Clear()
		if table.Count( JukeBox.BansList ) <= 0 then
			self.Count = 0
		else
			local searchtable = {}
			self.Count = 0
			for id, info in pairs( JukeBox.BansList ) do
				local nstr = string.find( string.lower(tostring(info.name)), string.lower(value), 1, true )
				local astr = string.find( string.lower(info.steamid64), string.lower(value), 1, true )
				if nstr or astr or gstr then
					table.insert( searchtable, info )
				end
			end
			for id, info in SortedPairsByMemberValue( searchtable, "name", false ) do
				self.Count = self.Count+1
				JukeBox.VGUI.Pages.AdminBans:CreateSongCard( parent, info )
			end
			if table.Count( searchtable ) <= 0 then
				parent.Top.Search.Issue = 2
			else
				parent.Top.Search.Issue = 1
			end
		end
	end	
	function parent.Scroll:UpdateBans()
		self:Clear()
		self.Count = 0
		if table.Count( JukeBox.BansList ) <= 0 then

		else
			for id, info in SortedPairsByMemberValue( JukeBox.BansList, "name", false ) do
				JukeBox.VGUI.Pages.AdminBans:CreateSongCard( parent, info )
				self.Count = self.Count+1
			end
		end
	end
	parent.Scroll:UpdateBans()
	hook.Add( "JukeBox_BansUpdated", "JukeBox_VGUI_BansUpdate", function() 
		if ValidPanel( parent ) then		
			parent.Scroll:UpdateBans()
		end
	end )
	
	--JukeBox.VGUI.Pages.AdminBans:CreateSongCard( parent, { name = "BOT Dan", steamid = "STEAM_0:1:46920108", steamid64 = "76561198054105945", requestban = true, queueban = false, } )
end

function JukeBox.VGUI.Pages.AdminBans:CreateSongCard( parent, info )
	if not info.requestban and not info.queueban then return end
	local card = vgui.Create( "DPanel", parent )
	card:SetTall( 40 )
	card:Dock( TOP )
	card:DockMargin( 15, 0, 20, 0 )
	card.Chosen = false
	function card:SetChosen( bool )
		card.Chosen = bool
	end
	card.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		elseif self.Chosen then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 5 ) )
		end
		draw.SimpleText( info.name, "JukeBox.Font.20", 50, h/2, Color( 255, 255, 255 ), 0, 1 )
		draw.SimpleText( info.steamid64, "JukeBox.Font.20", (w-30)*0.3, h/2, Color( 255, 255, 255 ), 0, 1 )
		JukeBox.VGUI.VGUI:DrawEmblem( w-330, h/2, 20, info.requestban and "jukebox/tick.png" or "jukebox/cross.png", Color( 255, 255, 255 ), 0 )
		JukeBox.VGUI.VGUI:DrawEmblem( w-180, h/2, 20, info.queueban and "jukebox/tick.png" or "jukebox/cross.png", Color( 255, 255, 255 ), 0 )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
	end
	
	card.Avatar = vgui.Create( "AvatarImage", card )
	card.Avatar:Dock( LEFT )
	card.Avatar:DockMargin( 5, 5, 5, 5 )
	card.Avatar:SetWide( 30 )
	card.Avatar:SetSteamID( info.steamid64 )
	
	card.PlayerButton = vgui.Create( "DButton", card )
	card.PlayerButton:Dock( RIGHT )
	card.PlayerButton:DockMargin( 0, 5, 10, 5 )
	card.PlayerButton:SetWide( 30 )
	card.PlayerButton:SetText( "" )
	card.PlayerButton.DoClick = function()
		JukeBox.VGUI.Pages.AdminBans:ShowBanInfo( parent, info )
	end
	card.PlayerButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 16, "jukebox/edit.png", Color( 255, 255, 255 ), 0 )
	end
	
	parent.Scroll:AddItem( card )
end

function JukeBox.VGUI.Pages.AdminBans:ShowBanInfo( parent, info )	
	local bg = vgui.Create( "DFrame" )
	bg:SetSize( ScrW(), ScrH() )
	bg:Center()
	bg:SetTitle( " " )
	bg:ShowCloseButton( false )
	bg:SetDraggable( false )
	bg:DockPadding( 0, 0, 0, 0 )
	bg:MakePopup()
	bg.Paint = function( self, w, h )
		Derma_DrawBackgroundBlur( self, CurTime() )
	end
	
	local popup = vgui.Create( "DPanel", bg )
	popup:SetSize( 500, 350 )
	popup:Center()
	popup.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
	end
	
	popup.TopBar = vgui.Create( "DPanel", popup )
	popup.TopBar:Dock( TOP )
	popup.TopBar:SetTall( 28 )
	popup.TopBar:DockPadding( 4, 4, 4, 4 )
	popup.TopBar.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		draw.SimpleText( "JukeBox - Ban Info", "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	popup.TopBar.CloseButton = vgui.Create( "DButton", popup.TopBar )
	popup.TopBar.CloseButton:Dock( RIGHT )
	popup.TopBar.CloseButton:SetWide( 50 )
	popup.TopBar.CloseButton:SetText( "" )
	popup.TopBar.CloseButton.DoClick = function()
		--info.requestban = popup.QueueBan.Enabled
		--info.requestban = popup.RequestBan.Enabled
		--JukeBox.VGUI.Pages.AdminBans:SaveChanges( parent, info )
		bg:Remove()
	end
	popup.TopBar.CloseButton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 57, 43 ) )
		if not JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255 ), 0 )
	end
	
	--[[
	popup.Warning = vgui.Create( "DPanel", popup )
	popup.Warning:Dock( TOP )
	popup.Warning:DockMargin( 0, 1, 0, 0 )
	popup.Warning:SetTall( 32 )
	popup.Warning.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Issue )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, JukeBox.Colours.Issue )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 255, 255, 255, 10 ) )
		draw.RoundedBox( 0, 2, 2, w-4, h-4, JukeBox.Colours.Issue )
		
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 18, "jukebox/warning.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( "All changes made here are saved once this window is closed!", "JukeBox.Font.18", h, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	]]--
	
	popup.Content = vgui.Create( "DPanel", popup )
	popup.Content:DockMargin( 0, 1, 0, 0 )
	popup.Content:DockPadding( 5, 5, 5, 5 )
	popup.Content:Dock( FILL )
	popup.Content.Progress = 1
	popup.Content.ProgressData = ""
	popup.Content.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	popup.BannerText = vgui.Create( "DLabel", popup.Content )
	popup.BannerText:Dock( TOP )
	popup.BannerText:SetText( "Banned by:" )
	popup.BannerText:SetTextColor( Color( 255, 255, 255, 255 ) )
	popup.BannerText:SetFont( "JukeBox.Font.22.Bold" )
	
	popup.BannerArea = vgui.Create( "DPanel", popup.Content )
	popup.BannerArea:Dock( TOP )
	popup.BannerArea:SetTall( 72 )
	popup.BannerArea:DockPadding( 4, 4, 4, 4 )
	popup.BannerArea:DockMargin( 0, 0, 0, 10 )
	popup.BannerArea.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 255, 255, 255, 10 ) )
		draw.RoundedBox( 0, 2, 2, w-4, h-4, Color( 50, 50, 50, 255 ) )
		
		draw.SimpleText( info.bannername or "[Unknown]", "JukeBox.Font.18.Bold", 72, 64/3, Color( 255, 255, 255 ), 0, 1 )
		draw.SimpleText( info.bannersid or "[Unknown]", "JukeBox.Font.18", 72, 64/3*2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	if info.bannersid then
		popup.BannerArea.CopySteamID = vgui.Create( "DButton", popup.BannerArea )
		popup.BannerArea.CopySteamID:SetSize( 160, 30 )
		popup.BannerArea.CopySteamID:Dock( RIGHT )
		popup.BannerArea.CopySteamID:DockMargin( 10, 17, 6, 17 )
		popup.BannerArea.CopySteamID:SetText( "" )
		popup.BannerArea.CopySteamID.Text = "Copy SteamID"
		popup.BannerArea.CopySteamID.DoClick = function()
			SetClipboardText( info.bannersid )
		end
		popup.BannerArea.CopySteamID.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
			else
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/edit.png", Color( 255, 255, 255 ), 0 )
			draw.SimpleText( self.Text, "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
		end
	end
	
	popup.BannerArea.Avatar = vgui.Create( "AvatarImage", popup.BannerArea )
	popup.BannerArea.Avatar:Dock( LEFT )
	popup.BannerArea.Avatar:SetWide( 64 )
	if info.bannersid then
		popup.BannerArea.Avatar:SetSteamID( info.bannersid, 64 )
	end
	
	popup.BannedText = vgui.Create( "DLabel", popup.Content )
	popup.BannedText:Dock( TOP )
	popup.BannedText:SetText( "Banned User:" )
	popup.BannedText:SetTextColor( Color( 255, 255, 255, 255 ) )
	popup.BannedText:SetFont( "JukeBox.Font.22.Bold" )
	
	popup.UserArea = vgui.Create( "DPanel", popup.Content )
	popup.UserArea:Dock( TOP )
	popup.UserArea:DockPadding( 4, 4, 4, 4 )
	popup.UserArea:SetTall( 72 )
	popup.UserArea.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Issue )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, JukeBox.Colours.Issue )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 255, 255, 255, 10 ) )
		draw.RoundedBox( 0, 2, 2, w-4, h-4, JukeBox.Colours.Issue )
		
		draw.SimpleText( info.name or "[Unknown]", "JukeBox.Font.18.Bold", 72, 64/3, Color( 255, 255, 255 ), 0, 1 )
		draw.SimpleText( info.steamid64, "JukeBox.Font.18", 72, 64/3*2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.UserArea.CopySteamID = vgui.Create( "DButton", popup.UserArea )
	popup.UserArea.CopySteamID:SetSize( 160, 30 )
	popup.UserArea.CopySteamID:Dock( RIGHT )
	popup.UserArea.CopySteamID:DockMargin( 10, 17, 6, 17 )
	popup.UserArea.CopySteamID:SetText( "" )
	popup.UserArea.CopySteamID.Text = "Copy SteamID"
	popup.UserArea.CopySteamID.DoClick = function()
		SetClipboardText( info.steamid64 )
	end
	popup.UserArea.CopySteamID.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/edit.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( self.Text, "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.UserArea.Avatar = vgui.Create( "AvatarImage", popup.UserArea )
	popup.UserArea.Avatar:Dock( LEFT )
	popup.UserArea.Avatar:SetWide( 64 )
	popup.UserArea.Avatar:SetSteamID( info.steamid64, 64 )
	
	popup.RequestArea = vgui.Create( "DPanel", popup.Content )
	popup.RequestArea:Dock( TOP )
	popup.RequestArea:DockMargin( 0, 10, 0, 0 )
	popup.RequestArea:SetTall( 24 )
	popup.RequestArea.Paint = function( self, w, h )
		draw.SimpleText( "Banned from making requests", "JukeBox.Font.18", 80, h/2-2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.RequestBan = vgui.Create( "DButton", popup.RequestArea )
	popup.RequestBan:Dock( LEFT )
	popup.RequestBan:SetWide( 70 )
	popup.RequestBan:SetTall( 24 )
	popup.RequestBan.Enabled = tobool( info.requestban )
	popup.RequestBan:SetText( "" )
	popup.RequestBan.DoClick = function( self )
		self.Enabled = !self.Enabled
	end
	popup.RequestBan.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( "Enabled", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( "Enable", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	popup.QueueArea = vgui.Create( "DPanel", popup.Content )
	popup.QueueArea:Dock( TOP )
	popup.QueueArea:DockMargin( 0, 6, 0, 0 )
	popup.QueueArea:SetTall( 24 )
	popup.QueueArea.Paint = function( self, w, h )
		draw.SimpleText( "Banned from queueing songs", "JukeBox.Font.18", 80, h/2-2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.QueueBan = vgui.Create( "DButton", popup.QueueArea )
	popup.QueueBan:Dock( LEFT )
	popup.QueueBan:SetWide( 70 )
	popup.QueueBan:SetTall( 24 )
	popup.QueueBan.Enabled = tobool( info.queueban )
	popup.QueueBan:SetText( "" )
	popup.QueueBan.DoClick = function( self )
		self.Enabled = !self.Enabled
	end
	popup.QueueBan.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( "Enabled", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( "Enable", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	popup.BottomBar = vgui.Create( "DPanel", popup.Content )
	popup.BottomBar:Dock( BOTTOM )
	popup.BottomBar:SetTall( 30 )
	popup.BottomBar:DockMargin( 0, 0, 0, 5 )
	popup.BottomBar.Paint = function( self, w, h ) end
	
	popup.AcceptButton = vgui.Create( "DButton", popup.BottomBar )
	popup.AcceptButton:SetWide( 140 )
	popup.AcceptButton:Dock( LEFT )
	popup.AcceptButton:SetVisible( true )
	popup.AcceptButton:DockMargin( 10, 0, 0, 0 )
	popup.AcceptButton:SetText( "" )
	popup.AcceptButton.Text = "Update Ban"
	popup.AcceptButton.DoClick = function()
		info.queueban = popup.QueueBan.Enabled
		info.requestban = popup.RequestBan.Enabled
		JukeBox.VGUI.Pages.AdminBans:SaveChanges( parent, info )
		bg:Remove()
	end
	popup.AcceptButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( self.Text, "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.RemoveButton = vgui.Create( "DButton", popup.BottomBar )
	popup.RemoveButton:SetWide( 145 )
	popup.RemoveButton:Dock( LEFT )
	popup.RemoveButton:SetVisible( true )
	popup.RemoveButton:DockMargin( 10, 0, 10, 0 )
	popup.RemoveButton:SetText( "" )
	popup.RemoveButton.Text = "Remove Ban"
	popup.RemoveButton.DoClick = function()
		info.queueban = false
		info.requestban = false
		JukeBox.VGUI.Pages.AdminBans:SaveChanges( parent, info )
		bg:Remove()
	end
	popup.RemoveButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Issue )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/cross.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( self.Text, "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.CancelButton = vgui.Create( "DButton", popup.BottomBar )
	popup.CancelButton:SetWide( 100 )
	popup.CancelButton:Dock( RIGHT )
	popup.CancelButton:SetVisible( true )
	popup.CancelButton:DockMargin( 0, 0, 10, 0 )
	popup.CancelButton:SetText( "" )
	popup.CancelButton.Text = "Close"
	popup.CancelButton.DoClick = function()
		--info.queueban = popup.QueueBan.Enabled
		--info.requestban = popup.RequestBan.Enabled
		--JukeBox.VGUI.Pages.AdminBans:SaveChanges( parent, info )
		bg:Remove()
	end
	popup.CancelButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	popup:Center()
end

function JukeBox.VGUI.Pages.AdminBans:AddBan( parent )
	local bg = vgui.Create( "DFrame" )
	bg:SetSize( ScrW(), ScrH() )
	bg:Center()
	bg:SetTitle( " " )
	bg:ShowCloseButton( false )
	bg:SetDraggable( false )
	bg:DockPadding( 0, 0, 0, 0 )
	bg:MakePopup()
	bg.Paint = function( self, w, h )
		Derma_DrawBackgroundBlur( self, CurTime() )
	end
	
	local popup = vgui.Create( "DPanel", bg )
	popup:SetSize( 500, 400 )
	popup:Center()
	popup.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
	end
	
	popup.TopBar = vgui.Create( "DPanel", popup )
	popup.TopBar:Dock( TOP )
	popup.TopBar:SetTall( 28 )
	popup.TopBar:DockPadding( 4, 4, 4, 4 )
	popup.TopBar.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		draw.SimpleText( "JukeBox - Ban Player", "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	popup.TopBar.CloseButton = vgui.Create( "DButton", popup.TopBar )
	popup.TopBar.CloseButton:Dock( RIGHT )
	popup.TopBar.CloseButton:SetWide( 50 )
	popup.TopBar.CloseButton:SetText( "" )
	popup.TopBar.CloseButton.DoClick = function()
		bg:Remove()
	end
	popup.TopBar.CloseButton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 57, 43 ) )
		if not JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255 ), 0 )
	end
	
	popup.Content = vgui.Create( "DPanel", popup )
	popup.Content:DockMargin( 0, 1, 0, 0 )
	popup.Content:DockPadding( 5, 5, 5, 5 )
	popup.Content:Dock( FILL )
	popup.Content.Progress = 1
	popup.Content.ProgressData = ""
	popup.Content.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	popup.ManualArea = vgui.Create( "DPanel", popup.Content )
	popup.ManualArea:Dock( BOTTOM )
	popup.ManualArea:SetTall( 150 )
	popup.ManualArea.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, JukeBox.Colours.Base )
	end
	
	popup.ManualArea.NamePanel = vgui.Create( "DPanel", popup.ManualArea )
	popup.ManualArea.NamePanel:Dock( TOP )
	popup.ManualArea.NamePanel:DockPadding( 252, 0, 12, 0 )
	popup.ManualArea.NamePanel:DockMargin( 0, 10, 0, 6 )
	popup.ManualArea.NamePanel.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 240, 0, w-240, h, Color( 255, 255, 255 ) )
		draw.SimpleText( "SteamID 64", "JukeBox.Font.18", 5, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.ManualArea.NameEntry = vgui.Create( "DTextEntry", popup.ManualArea.NamePanel )
	popup.ManualArea.NameEntry:Dock( FILL )
	popup.ManualArea.NameEntry.Val = ""
	popup.ManualArea.NameEntry.Error1 = true
	popup.ManualArea.NameEntry:SetFont( "JukeBox.Font.16" )
	popup.ManualArea.NameEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnChange( self )
		end
	end
	popup.ManualArea.NameEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base )
	end
	popup.ManualArea.NameEntry.OnChange = function( self )
		self.Val = self:GetValue()
		if self:GetValue() != "" and string.len(self:GetValue())==17 then
			self.Error1 = false
		else
			self.Error1 = true
		end
	end
	
	popup.ManualArea.RequestArea = vgui.Create( "DPanel", popup.ManualArea )
	popup.ManualArea.RequestArea:Dock( TOP )
	popup.ManualArea.RequestArea:DockMargin( 0, 0, 0, 0 )
	popup.ManualArea.RequestArea:DockPadding( 240, 0, 0, 0 )
	popup.ManualArea.RequestArea:SetTall( 24 )
	popup.ManualArea.RequestArea.Paint = function( self, w, h )
		draw.SimpleText( "Banned from making requests", "JukeBox.Font.18", 5, h/2-2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.ManualArea.RequestBan = vgui.Create( "DButton", popup.ManualArea.RequestArea )
	popup.ManualArea.RequestBan:Dock( LEFT )
	popup.ManualArea.RequestBan:SetWide( 70 )
	popup.ManualArea.RequestBan:SetTall( 24 )
	popup.ManualArea.RequestBan.Enabled = false
	popup.ManualArea.RequestBan:SetText( "" )
	popup.ManualArea.RequestBan.DoClick = function( self )
		self.Enabled = !self.Enabled
	end
	popup.ManualArea.RequestBan.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( "Enabled", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( "Enable", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	popup.ManualArea.QueueArea = vgui.Create( "DPanel", popup.ManualArea )
	popup.ManualArea.QueueArea:Dock( TOP )
	popup.ManualArea.QueueArea:DockMargin( 0, 6, 0, 0 )
	popup.ManualArea.QueueArea:DockPadding( 240, 0, 0, 0 )
	popup.ManualArea.QueueArea:SetTall( 24 )
	popup.ManualArea.QueueArea.Paint = function( self, w, h )
		draw.SimpleText( "Banned from queueing songs", "JukeBox.Font.18", 5, h/2-2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.ManualArea.QueueBan = vgui.Create( "DButton", popup.ManualArea.QueueArea )
	popup.ManualArea.QueueBan:Dock( LEFT )
	popup.ManualArea.QueueBan:SetWide( 70 )
	popup.ManualArea.QueueBan:SetTall( 24 )
	popup.ManualArea.QueueBan.Enabled = false
	popup.ManualArea.QueueBan:SetText( "" )
	popup.ManualArea.QueueBan.DoClick = function( self )
		self.Enabled = !self.Enabled
	end
	popup.ManualArea.QueueBan.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( "Enabled", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( "Enable", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	popup.Scroll = vgui.Create( "DScrollPanel", popup.Content )
	popup.Scroll:Dock( FILL )
	popup.Scroll.Count = 0
	popup.Scroll.VBar:SetWide( 10 )
	popup.Scroll.Paint = function( self, w, h )
	
	end
	popup.Scroll.VBar.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	popup.Scroll.VBar.btnGrip.Paint = function( self, w, h )
		draw.RoundedBox( w/2, 0, 0, w, h, JukeBox.Colours.Light )
	end
	popup.Scroll.VBar.btnUp.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 0 )
	end
	popup.Scroll.VBar.btnDown.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 180 )
	end
	
	function popup.Scroll:CreatePlayerCard( ply )
		local name = ply:Nick()
		local steamid = ply:SteamID()
		local steamid64 = ply:SteamID64()
		local card = vgui.Create( "DPanel", popup.Scroll )
		card:SetTall( 40 )
		card:Dock( TOP )
		card:DockMargin( 15, 0, 20, 0 )
		card.Chosen = false
		function card:SetChosen( bool )
			card.Chosen = bool
		end
		card.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
			elseif self.Chosen then
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 5 ) )
			end
			draw.SimpleText( name, "JukeBox.Font.20", 40, h/2, Color( 255, 255, 255 ), 0, 1 )
			draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
		end
		
		card.Avatar = vgui.Create( "AvatarImage", card )
		card.Avatar:Dock( LEFT )
		card.Avatar:DockMargin( 5, 5, 5, 5 )
		card.Avatar:SetWide( 30 )
		card.Avatar:SetPlayer( ply )
		
		card.PlayerButton = vgui.Create( "DButton", card )
		card.PlayerButton:Dock( RIGHT )
		card.PlayerButton:DockMargin( 0, 5, 10, 5 )
		card.PlayerButton:SetWide( 30 )
		card.PlayerButton:SetText( "" )
		card.PlayerButton.DoClick = function()
			popup.ManualArea.NameEntry:SetText( steamid64 )
		end
		card.PlayerButton.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Definition )
			else
				draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 16, "jukebox/edit.png", Color( 255, 255, 255 ), 0 )
		end
		
		popup.Scroll:AddItem( card )
	end
	for k, v in pairs( player.GetAll() ) do
		popup.Scroll:CreatePlayerCard( v )
	end
	
	popup.ActionButtons = vgui.Create( "DPanel", popup.ManualArea )
	popup.ActionButtons:Dock( BOTTOM )
	popup.ActionButtons:SetTall( 30 )
	popup.ActionButtons:DockMargin( 10, 0, 10, 10 )
	popup.ActionButtons.Paint = function( self, w, h )
		
	end
	
	popup.ActionButtons.Accept = vgui.Create( "DButton", popup.ActionButtons )
	popup.ActionButtons.Accept:Dock( LEFT )
	popup.ActionButtons.Accept:DockMargin( 0, 0, 10, 0 )
	popup.ActionButtons.Accept:SetWide( 145 )
	popup.ActionButtons.Accept:SetText( "" )
	popup.ActionButtons.Accept.DoClick = function( self )
		local start, finish = string.find( popup.ManualArea.NameEntry:GetValue(), "%d+" )
		local length = string.len( popup.ManualArea.NameEntry:GetValue() )
		if start and start == 1 and finish and finish == 17 and length == 17 then
			local info = {}
			info.steamid64 = popup.ManualArea.NameEntry:GetValue()
			info.requestban = popup.ManualArea.RequestBan.Enabled
			info.queueban = popup.ManualArea.QueueBan.Enabled
			local ply = player.GetBySteamID64( info.steamid64 )
			if ply then
				info.name = ply:Nick()
				info.steamid = ply:SteamID()
			end
			JukeBox.VGUI.Pages.AdminBans:SaveChanges( parent, info )
			bg:Remove()
		else
			
		end
	end
	popup.ActionButtons.Accept.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( "Update Ban", "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.ActionButtons.Cancel = vgui.Create( "DButton", popup.ActionButtons )
	popup.ActionButtons.Cancel:SetWide( 100 )
	popup.ActionButtons.Cancel:Dock( RIGHT )
	popup.ActionButtons.Cancel:SetVisible( true )
	popup.ActionButtons.Cancel:DockMargin( 0, 0, 10, 0 )
	popup.ActionButtons.Cancel:SetText( "" )
	popup.ActionButtons.Cancel.Text = "Cancel"
	popup.ActionButtons.Cancel.DoClick = function()
		bg:Remove()
	end
	popup.ActionButtons.Cancel.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
end

function JukeBox.VGUI.Pages.AdminBans:SaveChanges( parent, info )
	JukeBox:UpdateBan( info )
	JukeBox.VGUI.VGUI:MakeNotification( "Ban changes saved!", JukeBox.Colours.Accept, "JukeBox/tick.png", "BANS", true )
end


JukeBox.VGUI:RegisterPage( "ADMIN", "Bans", "Bans", "jukebox/admin.png", function( parent ) JukeBox.VGUI.Pages.AdminBans:CreatePanel( parent ) end, true )