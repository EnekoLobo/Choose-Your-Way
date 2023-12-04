JukeBox.VGUI.Pages.IdlePlay = {}

function JukeBox.VGUI.Pages.IdlePlay:CreatePanel( parent )
	parent.Description = vgui.Create( "DLabel", parent )
	parent.Description:Dock( TOP )
	parent.Description:SetText( "Songs that are ticked in green will be chosen at random to play while the JukeBox is in \"idle\" mode.\nLeave no songs ticked for the JukeBox to choose randomly." )
	parent.Description:SetFont( "JukeBox.Font.20" )
	parent.Description:DockMargin( 10, 10, 10, 0 )
	parent.Description:SetTall( 40 )
	parent.Description:SetWrap( true )
	
	parent.Top = vgui.Create( "DPanel", parent )
	parent.Top:Dock( TOP )
	parent.Top:SetTall( 42 )
	parent.Top.Paint = function( self, w, h )
		draw.RoundedBox( 12, 5, 10, h, h-20, Color( 255, 255, 255 ) )
		draw.RoundedBox( 12, 5+200, 10, h, h-20, Color( 255, 255, 255 ) )
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 14, "jukebox/search.png", JukeBox.Colours.Base, 0 )
		if (parent.Top.Search.Issue == 0) then
			draw.SimpleText( "There's a total of "..parent.Scroll.Count.." songs.", "JukeBox.Font.16", 260, h/2, Color( 200, 200, 200 ), 0, 1 )
		elseif (parent.Top.Search.Issue == 1) then
			draw.SimpleText( "Search found "..parent.Scroll.Count.." songs.", "JukeBox.Font.16", 260, h/2, Color( 200, 200, 200 ), 0, 1 )
		elseif (parent.Top.Search.Issue == 2) then
			draw.SimpleText( "Search returned no results.", "JukeBox.Font.16", 260, h/2, Color( 200, 200, 200 ), 0, 1 )
		end
	end
	
	parent.Top.Sort = vgui.Create( "DPanel", parent.Top )
	parent.Top.Sort:Dock( RIGHT )
	parent.Top.Sort:DockPadding( 10, 10, 10, 10 )
	parent.Top.Sort:SetWide( 200 )
	parent.Top.Sort.Paint = function( self, w, h )
		draw.SimpleText( "Sort By: ", "JukeBox.Font.16", w/2-10, h/2, Color( 200, 200, 200 ), 2, 1 )
	end
	
	parent.Top.Sort.Dropdown = vgui.Create( "DComboBox", parent.Top.Sort )
	parent.Top.Sort.Dropdown.Type = "artist"
	parent.Top.Sort.Dropdown:Dock( RIGHT )
	parent.Top.Sort.Dropdown:SetWide( 100 )
	parent.Top.Sort.Dropdown:SetValue( "Artist" )
	parent.Top.Sort.Dropdown:AddChoice( "Song Name" )
	parent.Top.Sort.Dropdown:AddChoice( "Artist" )
	parent.Top.Sort.Dropdown:AddChoice( "Length" )
	parent.Top.Sort.Dropdown.OnSelect = function( panel, index, value )
		if value == "Song Name" then
			parent.Top.Sort.Dropdown.Type = "name"
		elseif value == "Artist" then
			parent.Top.Sort.Dropdown.Type = "artist"
		elseif value == "Length" then
			parent.Top.Sort.Dropdown.Type = "length"
		end
		if parent.Top.Search:GetValue() != "" then
			parent.Scroll:SearchSongs( parent.Top.Search:GetValue() )
			parent.Top.Search.Issue = 1
		else
			parent.Scroll:UpdateSongs()
			parent.Top.Search.Issue = 0
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
			parent.Scroll:SearchSongs( self:GetValue() )
			self.Issue = 1
		else
			parent.Scroll:UpdateSongs()
			self.Issue = 0
		end
	end
	parent.Top.Search.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color(30, 130, 255), JukeBox.Colours.Base)
	end
	
	parent.Header = vgui.Create( "DPanel", parent )
	parent.Header:Dock( TOP )
	parent.Header:SetTall( 40 )
	parent.Header.Paint = function( self, w, h )
		draw.SimpleText( "SONG", "JukeBox.Font.18", 20, h/2, Color( 200, 200, 200 ), 0, 1 )
		draw.SimpleText( "ARTIST", "JukeBox.Font.18", w/2.5, h/2, Color( 200, 200, 200 ), 0, 1 )
		draw.SimpleText( "LENGTH", "JukeBox.Font.18", w*0.75-26, h/2, Color( 200, 200, 200 ), 0, 1 )
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
	
	function parent.Scroll:SearchSongs( value )
		self:Clear()
		if table.Count( JukeBox.SongList ) <= 0 then
			self.Count = 0
		else
			local searchtable = {}
			self.Count = 0
			for id, info in pairs( JukeBox.SongList ) do
				local nstr = string.find( string.lower(info.name), string.lower(value), 1, true )
				local astr = string.find( string.lower(info.artist), string.lower(value), 1, true )
				if nstr or astr or gstr then
					table.insert( searchtable, info )
				end
			end
			for id, info in SortedPairsByMemberValue( searchtable, parent.Top.Sort.Dropdown.Type, false ) do
				self.Count = self.Count+1
				JukeBox.VGUI.Pages.IdlePlay:CreateSongCard( parent, info )
			end
			if table.Count( searchtable ) <= 0 then
				parent.Top.Search.Issue = 2
			else
				parent.Top.Search.Issue = 1
			end
		end
	end
	
	function parent.Scroll:UpdateSongs()
		self:Clear()
		self.Count = 0
		if table.Count( JukeBox.SongList ) <= 0 then

		else
			for id, info in SortedPairsByMemberValue( JukeBox.SongList, parent.Top.Sort.Dropdown.Type, false ) do
				JukeBox.VGUI.Pages.IdlePlay:CreateSongCard( parent, info )
				self.Count = self.Count+1
			end
			--[[ -- For testing purposes only
			for i=1, 100 do
				local info = {}
				info.name = "Test Song #"..self.Count
				info.artist = "Test Artist #"..self.Count
				info.length = 254
				info.id = "TXv87EJLbSg"
				JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
				self.Count = self.Count+1
			end
			]]--
		end
	end
	parent.Scroll:UpdateSongs()
	hook.Add( "JukeBox_AllSongsUpdated", "JukeBox_VGUI_QueueUpdate", function() 
		if ValidPanel( parent ) then
			if parent.Top.Search:GetValue() != "" then
				parent.Scroll:SearchSongs( parent.Top.Search:GetValue() )
				parent.Top.Search.Issue = 1
			else
				parent.Scroll:UpdateSongs()
				parent.Top.Search.Issue = 0
			end
		end
	end )
	
	--for i=1, 100 do
	--	JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, "Song name", "Artist", "00000000000", "1:27" )
	--end
end

function JukeBox.VGUI.Pages.IdlePlay:CreateSongCard( parent, info )
	local name = info.name
	local artist = info.artist
	local id = info.id
	local length = info.length
	
	local card = vgui.Create( "DPanel", parent )
	card:SetTall( 40 )
	card:Dock( TOP )
	card:DockMargin( 15, 0, 20, 0 )
	card.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		end
		draw.SimpleText( name, "JukeBox.Font.20", 10, h/2, Color( 255, 255, 255 ), 0, 1 )
		draw.SimpleText( artist, "JukeBox.Font.20", w/2.5, h/2, Color( 255, 255, 255 ), 0, 1 )
		local time =  string.FormattedTime( length )
		draw.SimpleText( time.h!=0 and Format("%02i:%02i:%02i", time.h, time.m, time.s) or Format("%02i:%02i", time.m, time.s), "JukeBox.Font.20", (w+20)*0.75, h/2, Color( 255, 255, 255 ), 1, 1 )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
	end

	card.EditButton = vgui.Create( "DButton", card )
	card.EditButton:Dock( RIGHT )
	card.EditButton:DockMargin( 0, 5, 10, 5 )
	card.EditButton:SetWide( 30 )
	card.EditButton:SetText( "" )
	card.EditButton.Toggled = (JukeBox.IdleSongList[id] == true and true or false)
	card.EditButton.DoClick = function()
		card.EditButton.Toggled = !card.EditButton.Toggled
		JukeBox:UpdateIdleSong( id, card.EditButton.Toggled )
	end
	card.EditButton.Paint = function( self, w, h )
		if self.Toggled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 16, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
	end
	
	parent.Scroll:AddItem( card )
end

if JukeBox.Settings.EnableIdlePlay then
	JukeBox.VGUI:RegisterPage( "ADMIN", "Idleplay", "Idleplay", "jukebox/admin.png", function( parent ) JukeBox.VGUI.Pages.IdlePlay:CreatePanel( parent ) end, true )
end