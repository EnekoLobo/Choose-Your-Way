JukeBox.VGUI.Pages.AllSongs = {}

function JukeBox.VGUI.Pages.AllSongs:CreatePanel( parent )
	parent.Top = vgui.Create( "DPanel", parent )
	parent.Top:Dock( TOP )
	parent.Top:SetTall( 42 )
	parent.Top.Paint = function( self, w, h )
		draw.RoundedBox( 12, 5, 10, h, h-20, Color( 255, 255, 255 ) )
		draw.RoundedBox( 12, 5+200, 10, h, h-20, Color( 255, 255, 255 ) )
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 14, "jukebox/search.png", JukeBox.Colours.Base, 0 )
		if (parent.Top.Search.Issue == 0) then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#SEARCH_Total", parent.Scroll.Count ), "JukeBox.Font.16", 340, h/2, Color( 200, 200, 200 ), 0, 1 )
		elseif (parent.Top.Search.Issue == 1) then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#SEARCH_Results", parent.Scroll.Count ), "JukeBox.Font.16", 340, h/2, Color( 200, 200, 200 ), 0, 1 )
		elseif (parent.Top.Search.Issue == 2) then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#SEARCH_Results", 0 ), "JukeBox.Font.16", 340, h/2, Color( 200, 200, 200 ), 0, 1 )
		end
	end
	
	parent.Top.Sort = vgui.Create( "DPanel", parent.Top )
	parent.Top.Sort:Dock( RIGHT )
	parent.Top.Sort:DockPadding( 10, 10, 10, 10 )
	parent.Top.Sort:SetWide( 200 )
	parent.Top.Sort.Paint = function( self, w, h )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#ALLSONGS_SortBy" ), "JukeBox.Font.16", w/2-14, h/2, Color( 200, 200, 200 ), 2, 1 )
	end
	
	parent.Top.Sort.Dropdown = vgui.Create( "DComboBox", parent.Top.Sort )
	parent.Top.Sort.Dropdown.Type = "artist"
	parent.Top.Sort.Dropdown:Dock( RIGHT )
	parent.Top.Sort.Dropdown:SetWide( 100 )
	parent.Top.Sort.Dropdown:SetValue( JukeBox.Lang:GetPhrase( "#HEADING_Artist" ) )
	parent.Top.Sort.Dropdown:AddChoice( JukeBox.Lang:GetPhrase( "#HEADING_Song" ) )
	parent.Top.Sort.Dropdown:AddChoice( JukeBox.Lang:GetPhrase( "#HEADING_Artist" ) )
	parent.Top.Sort.Dropdown:AddChoice( JukeBox.Lang:GetPhrase( "#HEADING_Length" ) )
	parent.Top.Sort.Dropdown:AddChoice( JukeBox.Lang:GetPhrase( "#HEADING_Favourite" ) )
	parent.Top.Sort.Dropdown.OnSelect = function( panel, index, value )
		if index == 1 then
			parent.Top.Sort.Dropdown.Type = "name"
		elseif index == 2 then
			parent.Top.Sort.Dropdown.Type = "artist"
		elseif index == 3 then
			parent.Top.Sort.Dropdown.Type = "length"
		elseif index == 4 then
			parent.Top.Sort.Dropdown.Type = "fav"
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
	
	parent.Top.Refresh = vgui.Create( "DButton", parent.Top )
	parent.Top.Refresh:Dock( LEFT )
	parent.Top.Refresh:DockMargin( 24, 10, 10, 10 )
	parent.Top.Refresh:SetWide( 80 )
	parent.Top.Refresh:SetText( "" )
	parent.Top.Refresh.LastClick = 0
	parent.Top.Refresh.DoClick = function()
		if parent.Top.Refresh.LastClick < CurTime() then
			net.Start( "JukeBox_AllSongs" )
			net.SendToServer()
			parent.Scroll:Clear()
			parent.Scroll:SayLoadingResults()
			parent.Top.Refresh.LastClick = CurTime()+10
		else
			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#ALLSONGS_RefreshWait", math.Round(parent.Top.Refresh.LastClick-CurTime()) ), JukeBox.Colours.Issue, "jukebox/warning.png", "ALLSONGS", true )
		end
	end
	parent.Top.Refresh.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#ALLSONGS_Refresh" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	parent.Letters = vgui.Create( "DPanel", parent )
	parent.Letters:Dock( TOP )
	parent.Letters:SetTall( 42 )
	parent.Letters.Paint = function( self, w, h )
		
	end
	
	parent.Letters.Scroll = vgui.Create( "DPanel", parent.Letters )
	parent.Letters.Scroll:Dock( BOTTOM )
	parent.Letters.Scroll:SetTall( 10 )
	parent.Letters.Scroll.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	parent.Letters.Scroll.Grip = vgui.Create( "DButton", parent.Letters.Scroll )
	parent.Letters.Scroll.Grip:SetPos( 10, 0 )
	parent.Letters.Scroll.Grip:SetWide( 0 )
	parent.Letters.Scroll.Grip:SetTall( 10 )
	parent.Letters.Scroll.Grip:SetText( "" )
	parent.Letters.Scroll.Grip.Dragging = false
	parent.Letters.Scroll.Grip.HoldPos = 0
	parent.Letters.Scroll.Grip.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
	end
	parent.Letters.Scroll.Grip.OnMousePressed = function( self )
		if self.Dragging then return end
		
		self:MouseCapture( true )
		self.Dragging = true
		
		local x, y = gui.MouseX(), 0
		local x, y = self:ScreenToLocal( x, y )
		
		self.HoldPos = x
	end
	parent.Letters.Scroll.Grip.OnMouseReleased = function( self )
		self.Dragging = false
		self:MouseCapture( false )
	end
	parent.Letters.Scroll.Grip.OnCursorMoved = function( self, x, y )
		if !self.Dragging then return end
		local x, y = gui.MouseX(), 0
		local x, y = parent.Letters.Scroll:ScreenToLocal( x-self.HoldPos, y )
		
		local track = parent.Letters.Scroll:GetWide()-10-self:GetWide()
		
		if x<10 then
			x = 10
		elseif x>track then
			x = track
		end
		
		local percent = (x-10)/(track-10)
		local overhang = parent.Letters.ScrollPanel:GetWide()-parent.Letters.Scroll:GetWide()
		
		parent.Letters.ScrollPanel:SetPos( -overhang*percent, 0 )
		
		self:SetPos( x, 0 )
	end
	
	parent.Letters.Scroll.Left = vgui.Create( "DButton", parent.Letters.Scroll )
	parent.Letters.Scroll.Left:Dock( LEFT )
	parent.Letters.Scroll.Left:SetWide( 10 )
	parent.Letters.Scroll.Left:SetText( "" )
	parent.Letters.Scroll.Left.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 90 )
	end
	parent.Letters.Scroll.Left.DoClick = function()
		local x = parent.Letters.Scroll.Grip:GetPos()
		x=x-36
	
		local track = parent.Letters.Scroll:GetWide()-10-parent.Letters.Scroll.Grip:GetWide()
		
		if x<10 then
			x = 10
		elseif x>track then
			x = track
		end
		
		local percent = (x-10)/(track-10)
		local overhang = parent.Letters.ScrollPanel:GetWide()-parent.Letters.Scroll:GetWide()
		
		parent.Letters.ScrollPanel:SetPos( -overhang*percent, 0 )
		
		parent.Letters.Scroll.Grip:SetPos( x, 0 )
	end
	
	parent.Letters.Scroll.Right = vgui.Create( "DButton", parent.Letters.Scroll )
	parent.Letters.Scroll.Right:Dock( RIGHT )
	parent.Letters.Scroll.Right:SetWide( 10 )
	parent.Letters.Scroll.Right:SetText( "" )
	parent.Letters.Scroll.Right.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 270 )
	end
	parent.Letters.Scroll.Right.DoClick = function()
		local x = parent.Letters.Scroll.Grip:GetPos()
		x=x+36
	
		local track = parent.Letters.Scroll:GetWide()-10-parent.Letters.Scroll.Grip:GetWide()
		
		if x<10 then
			x = 10
		elseif x>track then
			x = track
		end
		
		local percent = (x-10)/(track-10)
		local overhang = parent.Letters.ScrollPanel:GetWide()-parent.Letters.Scroll:GetWide()
		
		parent.Letters.ScrollPanel:SetPos( -overhang*percent, 0 )
		
		parent.Letters.Scroll.Grip:SetPos( x, 0 )
	end
	
	parent.Letters.ScrollPanel = vgui.Create( "DPanel", parent.Letters )
	parent.Letters.ScrollPanel:SetPos( 0, 0 )
	parent.Letters.ScrollPanel:SetSize( parent.Letters:GetWide(), parent.Letters:GetTall()-parent.Letters.Scroll:GetTall() )
	parent.Letters.ScrollPanel.Paint = function( self, w, h )
	
	end
	
	local button = vgui.Create( "DButton", parent.Letters.ScrollPanel )
	button:Dock( LEFT )
	button:DockMargin( 4, 2, 4, 2 )
	button.Active = true
	button:SetText( "" )
	button:SetWide( 50 )
	button.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) or self.Active then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( "ALL", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	button.DoClick = function( self )
		for k, v in pairs( parent.Letters.ScrollPanel:GetChildren() ) do
			v.Active = false
		end
		self.Active = true
		parent.Scroll.Letter = "ALL"
		if parent.Top.Search:GetValue() != "" then
			parent.Scroll:SearchSongs( parent.Top.Search:GetValue() )
			parent.Top.Search.Issue = 1
		else
			parent.Scroll:UpdateSongs()
			parent.Top.Search.Issue = 0
		end
	end
	
	local button = vgui.Create( "DButton", parent.Letters.ScrollPanel )
	button:Dock( LEFT )
	button:DockMargin( 4, 2, 4, 2 )
	button.Active = false
	button:SetText( "" )
	button:SetWide( 28 )
	button.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) or self.Active then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 18, "jukebox/favourite.png", Color( 255, 255, 255 ), 0 )
	end
	button.DoClick = function( self )
		for k, v in pairs( parent.Letters.ScrollPanel:GetChildren() ) do
			v.Active = false
		end
		self.Active = true
		parent.Scroll.Letter = "FAV"
		if parent.Top.Search:GetValue() != "" then
			parent.Scroll:SearchSongs( parent.Top.Search:GetValue() )
			parent.Top.Search.Issue = 1
		else
			parent.Scroll:UpdateSongs()
			parent.Top.Search.Issue = 0
		end
	end
	
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i=1, string.len(alphabet) do
		local button = vgui.Create( "DButton", parent.Letters.ScrollPanel )
		button:Dock( LEFT )
		button:DockMargin( 4, 2, 4, 2 )
		button.Active = false
		button:SetText( "" )
		button:SetWide( 28 )
		button.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) or self.Active then
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
			else
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
			end
			draw.SimpleText( string.sub(alphabet, i, i), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
		button.DoClick = function( self )
			for k, v in pairs( parent.Letters.ScrollPanel:GetChildren() ) do
				v.Active = false
			end
			self.Active = true
			parent.Scroll.Letter = string.sub(alphabet, i, i)
			if parent.Top.Search:GetValue() != "" then
				parent.Scroll:SearchSongs( parent.Top.Search:GetValue() )
				parent.Top.Search.Issue = 1
			else
				parent.Scroll:UpdateSongs()
				parent.Top.Search.Issue = 0
			end
		end
	end
	local button = vgui.Create( "DButton", parent.Letters.ScrollPanel )
	button:Dock( LEFT )
	button:DockMargin( 4, 2, 4, 2 )
	button.Active = false
	button:SetText( "" )
	button:SetWide( 28 )
	button.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) or self.Active then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( "#", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	button.DoClick = function( self )
		for k, v in pairs( parent.Letters.ScrollPanel:GetChildren() ) do
			v.Active = false
		end
		self.Active = true
		parent.Scroll.Letter = "#"
		if parent.Top.Search:GetValue() != "" then
			parent.Scroll:SearchSongs( parent.Top.Search:GetValue() )
			parent.Top.Search.Issue = 1
		else
			parent.Scroll:UpdateSongs()
			parent.Top.Search.Issue = 0
		end
	end
	parent.Letters.ScrollPanel:SetWide( table.Count( parent.Letters.ScrollPanel:GetChildren() )*36+22 )
	
	function parent.Letters.ScrollPanel:PerformLayout()
		if parent.Letters.ScrollPanel:GetWide() > parent.Letters:GetWide() then
			parent.Letters.Scroll.Grip:SetWide( (parent.Letters:GetWide()-20)*(parent.Letters:GetWide()/parent.Letters.ScrollPanel:GetWide()))
		else
			parent.Letters.Scroll:SetVisible( false )
		end
	end
	
	parent.Header = vgui.Create( "DPanel", parent )
	parent.Header:Dock( TOP )
	parent.Header:DockPadding( 15, 0, 20, 0 )
	parent.Header:SetTall( 40 )
	parent.Header.Paint = function( self, w, h )
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#HEADING_Song" ), "JukeBox.Font.18", 20, h/2, Color( 200, 200, 200 ), 0, 1 )
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#HEADING_Artist" ), "JukeBox.Font.18", w/2.5, h/2, Color( 200, 200, 200 ), 0, 1 )
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#HEADING_Length" ), "JukeBox.Font.18", ScrW() > 800 and w-310 or w-160, h/2, Color( 200, 200, 200 ), 0, 1 )
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#HEADING_Actions" ), "JukeBox.Font.18", w-35, h/2, Color( 200, 200, 200 ), 2, 1 )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
	end
	
	parent.Scroll = vgui.Create( "DScrollPanel", parent )
	parent.Scroll:Dock( FILL )
	parent.Scroll.Count = 0
	parent.Scroll.Letter = "ALL"
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
			self:SayNoResults()
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
			local amount = table.Count( searchtable )
			for id, info in pairs( searchtable ) do
				info.fav = ((JukeBox.FavouritesList[info.id]==true) and 0 or 1)
			end
			for id, info in SortedPairsByMemberValue( searchtable, parent.Top.Sort.Dropdown.Type, false ) do
				if self.Letter != "ALL" and self.Letter != "FAV" then
					if self.Letter == "#" then
						if parent.Top.Sort.Dropdown.Type == "name" then
							if string.gsub(string.Left( info.name, 1 ), "[^%a]", "£") == "£" then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						else
							if string.gsub(string.Left( info.artist, 1 ), "[^%a]", "£") == "£" then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						end
					else
						if parent.Top.Sort.Dropdown.Type == "name" then
							if string.upper(string.Left( info.name, 1 )) == self.Letter then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						else
							if string.upper(string.Left( info.artist, 1 )) == self.Letter then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						end
					end
				elseif self.Letter == "FAV" then
					if info.fav == 0 then
						if self:DoMaxCheck( self.Count ) then return end
						JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
						self.Count = self.Count+1
					end
				else
					if self:DoMaxCheck( self.Count ) then return end
					JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
					self.Count = self.Count+1
				end
			end
			if table.Count( searchtable ) <= 0 then
				parent.Top.Search.Issue = 2
				self:SayNoResults()
			else
				parent.Top.Search.Issue = 1
			end
			timer.Simple( 1, function()
				if not ValidPanel( self ) then return end
				if self:GetCanvas():GetTall() < 0 then
					self:Clear()
					self:SayTooManyResults()
				end
			end )
		end
	end
	
	function parent.Scroll:SayTooManyResults( amount )
		local card = vgui.Create( "DPanel", self )
		card:Dock( TOP )
		card:SetTall( 100 )
		card:DockMargin( 15, 0, 20, 0 )
		card.Paint = function( self, w, h )
			JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, h*0.75, "jukebox/error.png", Color( 255, 255, 255 ), 0 )
		end
		
		local text = vgui.Create( "DLabel", card )
		text:Dock( FILL )
		text:DockMargin( 100, 0, 0, 0 )
		if amount then
			text:SetText( JukeBox.Lang:GetPhrase( "#ALLSONGS_TooManyCount", JukeBox:GetCookie( "JukeBox_MaxSongs" ) ) )
		else
			text:SetText( JukeBox.Lang:GetPhrase( "#ALLSONGS_TooMany" ) )
		end
		text:SetTextColor( Color( 255, 255, 255, 255 ) )
		text:SetFont( "JukeBox.Font.18" )
		
		self:AddItem( card )
	end
	
	function parent.Scroll:SayLoadingResults()
		local card = vgui.Create( "DPanel", self )
		card:Dock( TOP )
		card:SetTall( 100 )
		card:DockMargin( 15, 0, 20, 0 )
		card.Paint = function( self, w, h )
			JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, h*0.75, "jukebox/error.png", Color( 255, 255, 255 ), 0 )
		end
		
		local text = vgui.Create( "DLabel", card )
		text:Dock( FILL )
		text:DockMargin( 100, 0, 0, 0 )
		text:SetText( JukeBox.Lang:GetPhrase( "#ALLSONGS_Fetching" ) )
		text:SetTextColor( Color( 255, 255, 255, 255 ) )
		text:SetFont( "JukeBox.Font.18" )
		
		self:AddItem( card )
	end
	
	function parent.Scroll:SayNoResults()
		local card = vgui.Create( "DPanel", self )
		card:Dock( TOP )
		card:SetTall( 100 )
		card:DockMargin( 15, 0, 20, 0 )
		card.Paint = function( self, w, h )
			JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, h*0.75, "jukebox/error.png", Color( 255, 255, 255 ), 0 )
		end
		
		local text = vgui.Create( "DLabel", card )
		text:Dock( FILL )
		text:DockMargin( 100, 0, 0, 0 )
		text:SetText( JukeBox.Lang:GetPhrase( "#ALLSONGS_NoResults" ) )
		text:SetTextColor( Color( 255, 255, 255, 255 ) )
		text:SetFont( "JukeBox.Font.18" )
		
		self:AddItem( card )
	end
	
	function parent.Scroll:DoMaxCheck()
		if JukeBox:GetCookie( "JukeBox_MaxSongs" ) >= 1000 then
			return false
		elseif self.Count >= JukeBox:GetCookie( "JukeBox_MaxSongs" ) then
			--self:Clear()
			self:SayTooManyResults( true )
			return true
		else
			return false
		end
	end
	
	function parent.Scroll:UpdateSongs()
		self:Clear()
		self.Count = 0
		if table.Count( JukeBox.SongList ) <= 0 then
			self:SayNoResults()
		else
			local searchtable = JukeBox.SongList
			for id, info in pairs( searchtable ) do
				info.fav = ((JukeBox.FavouritesList[info.id]==true) and 0 or 1)
			end
			for id, info in SortedPairsByMemberValue( searchtable, parent.Top.Sort.Dropdown.Type, false ) do
				if self.Letter != "ALL" and self.Letter != "FAV" then
					if self.Letter == "#" then
						if parent.Top.Sort.Dropdown.Type == "name" then
							if string.gsub(string.Left( info.name, 1 ), "[^%a]", "£") == "£" then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						else
							if string.gsub(string.Left( info.artist, 1 ), "[^%a]", "£") == "£" then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						end
					else
						if parent.Top.Sort.Dropdown.Type == "name" then
							if string.upper(string.Left( info.name, 1 )) == self.Letter then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						else
							if string.upper(string.Left( info.artist, 1 )) == self.Letter then
								if self:DoMaxCheck( self.Count ) then return end
								JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
								self.Count = self.Count+1
							end
						end
					end
				elseif self.Letter == "FAV" then
					if info.fav == 0 then
						if self:DoMaxCheck( self.Count ) then return end
						JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
						self.Count = self.Count+1
					end
				else
					if self:DoMaxCheck( self.Count ) then return end
					JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
					self.Count = self.Count+1
				end
			end
			--[[ -- For testing purposes only
			for i=1, 150 do
				local info = {}
				info.name = "Test Song #"..self.Count
				info.artist = "Test Artist #"..self.Count
				info.length = 254
				info.id = "TXv87EJLbSg"
				JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
				self.Count = self.Count+1
			end
			]]--
			timer.Simple( 1, function()
				if not ValidPanel( self ) then return end
				if self:GetCanvas():GetTall() < 0 then
					self:Clear()
					self:SayTooManyResults()
				end
			end )
		end
	end
	parent.Scroll:UpdateSongs()
	hook.Add( "JukeBox_AllSongsUpdated", "JukeBox_VGUI_AllSongsUpdate", function()
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

end

function JukeBox.VGUI.Pages.AllSongs:CreateSongCard( parent, info )
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
		draw.SimpleText( JukeBox:MinWord( name, "JukeBox.Font.20", w-10-(w-(w/2.5))-20 ), "JukeBox.Font.20", 10, h/2, Color( 255, 255, 255 ), 0, 1 )
		draw.SimpleText( JukeBox:MinWord( artist, "JukeBox.Font.20", w-(w/2.5)-(ScrW() > 800 and 250 or 100)-30 ), "JukeBox.Font.20", w/2.5, h/2, Color( 255, 255, 255 ), 0, 1 )
		local time =  string.FormattedTime( length )
		draw.SimpleText( time.h!=0 and Format("%02i:%02i:%02i", time.h, time.m, time.s) or Format("%02i:%02i", time.m, time.s), "JukeBox.Font.20", ScrW() > 800 and w-250 or w-100, h/2, Color( 255, 255, 255 ), 1, 1 )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
	end
	
	card.PlayButton = vgui.Create( "DButton", card )
	card.PlayButton:Dock( RIGHT )
	card.PlayButton:DockMargin( 0, 5, 10, 5 )
	card.PlayButton:SetWide( ScrW() > 800 and 135 or 30 )
	card.PlayButton:SetText( "" )
	card.PlayButton.DoClick = function()
		if JukeBox.Settings.AllowLocalPlay then
			local dropdown = vgui.Create( "DMenu" )
			dropdown:SetPos( input.GetCursorPos() )
			dropdown:MakePopup()
			dropdown.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
			end
			local dropdownQueueButton = dropdown:AddOption( JukeBox.Lang:GetPhrase( "#ALLSONGS_Queue" ) )
			dropdownQueueButton:SetTextColor( Color( 255, 255, 255 ) )
			function dropdownQueueButton:DoClick()
				JukeBox.VGUI.Pages.AllSongs:QueuePopup( parent, name, artist, id, length )
			end
			dropdown:AddSpacer()
			local dropdownListenButton = dropdown:AddOption( JukeBox.Lang:GetPhrase( "#ALLSONGS_ListenLocal" ) )
			dropdownListenButton:SetTextColor( Color( 255, 255, 255 ) )
			function dropdownListenButton:DoClick()
				JukeBox:PlayListenLocally( id )
			end
		else
			JukeBox.VGUI.Pages.AllSongs:QueuePopup( parent, name, artist, id, length )
		end
	end
	card.PlayButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( ScrW() > 800 and h*0.75 or h/2, h/2, 16, "jukebox/play.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#ALLSONGS_Queue" ), "JukeBox.Font.20", h+4, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	card.FavButton = vgui.Create( "DButton", card )
	card.FavButton:Dock( RIGHT )
	card.FavButton:DockMargin( 0, 5, 5, 5 )
	card.FavButton:SetWide( 30 )
	card.FavButton:SetText( "" )
	card.FavButton.Toggled = ((JukeBox.FavouritesList[info.id]==true) and true or false)
	card.FavButton.DoClick = function()
		card.FavButton.Toggled = !card.FavButton.Toggled
		JukeBox:UpdateFavourite( id, card.FavButton.Toggled )
	end
	card.FavButton.Paint = function( self, w, h )
		if self.Toggled then
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Warning )
		else
			draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 16, "jukebox/favourite.png", Color( 255, 255, 255 ), 0 )
	end
	
	if JukeBox:IsManager( LocalPlayer() ) then
		card.EditButton = vgui.Create( "DButton", card )
		card.EditButton:Dock( RIGHT )
		card.EditButton:DockMargin( 0, 5, 5, 5 )
		card.EditButton:SetWide( 30 )
		card.EditButton:SetText( "" )
		card.EditButton.DoClick = function()
			JukeBox.VGUI.Pages.AllSongs:AdminEditArea( parent, info )
		end
		card.EditButton.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Warning )
			else
				draw.RoundedBox( h/2+1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 16, "jukebox/edit.png", Color( 255, 255, 255 ), 0 )
		end
	end
	
	parent.Scroll:AddItem( card )
end

function JukeBox.VGUI.Pages.AllSongs:QueuePopup( parent, name, artist, id, length )
	local per = 1
	if JukeBox.Settings.UseULXRanks then
		for k, v in pairs( JukeBox.Settings.RankDiscount ) do
			if LocalPlayer():IsUserGroup( k ) then
				per = v
				break
			end
		end
	end
	if JukeBox.Settings.UsePointshop then
		text = JukeBox.Lang:GetPhrase( "#ALLSONGS_ConfirmQueue", artist, name, math.Round( JukeBox.Settings.PointsCost * per ), JukeBox.Lang:GetPhrase( "#ALLSONGS_CostPS" ) )
	elseif JukeBox.Settings.UsePointshop2 then
		text = JukeBox.Lang:GetPhrase( "#ALLSONGS_ConfirmQueue", artist, name, math.Round( JukeBox.Settings.PointsCost * per ), JukeBox.Lang:GetPhrase( "#ALLSONGS_CostPS2" ) )
	elseif JukeBox.Settings.UseSHPointshop then
		text = JukeBox.Lang:GetPhrase( "#ALLSONGS_ConfirmQueue", artist, name, math.Round( JukeBox.Settings.PointsCost * per ), JukeBox.Lang:GetPhrase( "#ALLSONGS_CostSHPS" ) )
	elseif JukeBox.Settings.UseDarkRPCash then
		text = JukeBox.Lang:GetPhrase( "#ALLSONGS_ConfirmQueue", artist, name, "$"..math.Round( JukeBox.Settings.DarkRPCashCost * per ), JukeBox.Lang:GetPhrase( "#ALLSONGS_CostDRPCash" ) )
	elseif JukeBox.Settings.UseSimpleMoney then
		text = JukeBox.Lang:GetPhrase( "#ALLSONGS_ConfirmQueue", artist, name, "$"..math.Round( JukeBox.Settings.SimpleMoneyCost * per ), JukeBox.Lang:GetPhrase( "#ALLSONGS_CostSMCash" ) )
	else
		text = JukeBox.Lang:GetPhrase( "#ALLSONGS_ConfirmQueue", artist, name, JukeBox.Lang:GetPhrase( "#ALLSONGS_CostNothing" ), "" )
	end
	
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
	popup:SetSize( 400, 400 )
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
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#HEADING_Name" ).." - "..JukeBox.Lang:GetPhrase( "#ALLSONGS_Queue" ), "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
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
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	popup.Body = vgui.Create( "DLabel", popup.Content )
	popup.Body:SetFont( "JukeBox.Font.18" )
	popup.Body:SetTextColor( Color( 255, 255, 255 ) )
	popup.Body:SetText( text )
	popup.Body:SizeToContents()
	if not (popup:GetWide() > popup.Body:GetTall()+popup.TopBar:GetTall()+11+50) then
		popup:SetWide( popup.Body:GetWide()+10 )
	end
	popup:SetTall( popup.Body:GetTall()+popup.TopBar:GetTall()+11+50 )
	popup.Body:Dock( TOP )
	
	popup.BottomBar = vgui.Create( "DPanel", popup.Content )
	popup.BottomBar:Dock( BOTTOM )
	popup.BottomBar:SetTall( 30 )
	popup.BottomBar:DockMargin( 0, 0, 0, 5 )
	popup.BottomBar.Paint = function( self, w, h ) end
	
	popup.AcceptButton = vgui.Create( "DButton", popup.BottomBar )
	popup.AcceptButton:SetWide( 135 )
	popup.AcceptButton:Dock( LEFT )
	popup.AcceptButton:SetVisible( true )
	popup.AcceptButton:DockMargin( 10, 0, 0, 0 )
	popup.AcceptButton:SetText( "" )
	popup.AcceptButton.Text = "Accept Request"
	popup.AcceptButton.DoClick = function()
		JukeBox:QueueSong( id )
		bg:Remove()
		JukeBox.VGUI.VGUI:MakeNotification( "Song added to the Queue!", JukeBox.Colours.Accept, "jukebox/tick.png", "ALLSONGS", true )
	end
	popup.AcceptButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#ALLSONGS_Queue" ), "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.CancelButton = vgui.Create( "DButton", popup.BottomBar )
	popup.CancelButton:SetWide( 100 )
	popup.CancelButton:Dock( RIGHT )
	popup.CancelButton:SetVisible( true )
	popup.CancelButton:DockMargin( 0, 0, 10, 0 )
	popup.CancelButton:SetText( "" )
	popup.CancelButton.Text = JukeBox.Lang:GetPhrase( "#BUTTON_Cancel" )
	popup.CancelButton.DoClick = function()
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

function JukeBox.VGUI.Pages.AllSongs:CheckURL( parent, id )
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
		draw.SimpleText( "JukeBox - Check URL", "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
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
	popup.Content:DockPadding( 2, 2, 2, 0 )
	popup.Content:Dock( FILL )
	popup.Content.Progress = 1
	popup.Content.ProgressData = ""
	popup.Content.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	popup.HTML = vgui.Create( "DHTML", popup.Content )
	popup.HTML:Dock( FILL )
	popup.HTML.Progress = 1
	popup.HTML.Length = 0
	popup.HTML.LengthString = ""
	popup.HTML.ProgressData = ""
	popup.HTML:OpenURL( JukeBox.Settings.PlayerURL )
	timer.Simple( 1, function()
		if !IsValid( bg ) or !ValidPanel( bg ) then return end
		popup.HTML:RunJavascript( "player.loadVideoById(\"" .. id .. "\", 0, \"medium\");")
		popup.HTML:RunJavascript( "player.setVolume( 50 );")
	end )
	popup.HTML.PaintOver = function( self, w, h )
		if not JukeBox.VGUI.VGUI:GetHovered( self ) then return end
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 240 ) )
		if self.Progress == 1 then
			draw.SimpleText( "Checking YouTube URL and data...", "JukeBox.Font.20", w/2, h*0.25, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/loading.png", Color( 255, 255, 255 ), -CurTime()*100 )
		elseif self.Progress == 2 then
			draw.SimpleText( "Video exists", "JukeBox.Font.20", w/2, h*0.25, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
			draw.SimpleText( "Length: "..self.LengthString.." ("..self.Length.."s)", "JukeBox.Font.20", w/2, h*0.75, Color( 255, 255, 255 ), 1, 1 )
		elseif self.Progress == 3 then
			draw.SimpleText( "Video doesn't exist", "JukeBox.Font.20", w/2, h*0.25, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/cross.png", Color( 255, 255, 255 ), 0 )
		elseif self.Progress == 4 then
			draw.SimpleText( "Error contacting server", "JukeBox.Font.20", w/2, h*0.25, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/error.png", Color( 255, 255, 255 ), 0 )
			draw.SimpleText( "Error: "..self.ProgressData, "JukeBox.Font.20", w/2, h-20, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	popup.HTML.Cover = vgui.Create("DPanel", popup.HTML)
	popup.HTML.Cover:Dock( FILL )
	popup.HTML.Cover.Paint = function() end
	
	popup.BottomButton = vgui.Create( "DButton", popup.Content )
	popup.BottomButton:SetSize( 100, 40 )
	popup.BottomButton:Dock( BOTTOM )
	popup.BottomButton:SetVisible( true )
	popup.BottomButton:DockMargin( 75, 20, 75, 10 )
	popup.BottomButton:SetText( "" )
	popup.BottomButton.Text = "Close"
	popup.BottomButton.DoClick = function()
		popup.HTML:RunJavascript( "player.stopVideo();")
		bg:Remove()
	end
	popup.BottomButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	JukeBox:Fetch({request = "length", id = id},
		function(data)
			if !IsValid( bg ) or !ValidPanel( bg ) then return end
			if (!data.exists) then
				popup.HTML.Progress = 3
			else
				popup.HTML.Progress = 2
				popup.HTML.Length = data.duration
				 
				local time = string.FormattedTime( data.duration )
				popup.HTML.LengthString = time.h!=0 and Format("%02i:%02i:%02i", time.h, time.m, time.s) or Format("%02i:%02i", time.m, time.s)
			end
		end,
		function()
			if !IsValid( bg ) or !ValidPanel( bg ) then return end
			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#WEB_IssueGeneric" ), JukeBox.Colours.Issue, "jukebox/warning.png", "ALLSONGS", true )
			popup.HTML.Progress = 4
		end
	)
	-- REPLACED HTTP CODE WITH LOCAL FETCH REQUEST TO SERVER
	--
	-- http.Fetch( JukeBox.Settings.CheckerURL..id, 
	-- 	function( body )
	-- 		if !IsValid( bg ) or !ValidPanel( bg ) then return end
	-- 		local info = util.JSONToTable( body )
	-- 		if not info then
	-- 			popup.HTML.Progress = 4
	-- 		elseif info.videoExists then
	-- 			popup.HTML.Progress = 2
	-- 			popup.HTML.Length = info.videoLength
	-- 			popup.HTML.LengthString = info.videoLengthString
	-- 		else
	-- 			popup.HTML.Progress = 3
	-- 		end
	-- 	end,
	-- 	function( issue )
	-- 		if not ValidPanel( bg ) then return end
	-- 		popup.HTML.Progress = 4
	-- 	end )
end

function JukeBox.VGUI.Pages.AllSongs:AdminEditArea( parent, data )
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
	popup:SetSize( 640, 325 )
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
		draw.SimpleText( "JukeBox - Update Song", "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
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
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	popup.EditArea = vgui.Create( "DPanel", popup.Content )
	popup.EditArea:Dock( FILL )
	popup.EditArea:DockPadding( 50, 10, 50, 10 )
	popup.EditArea:SetTall( 276 )
	popup.EditArea.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, JukeBox.Colours.Base )
	end
	
	popup.EditArea.NamePanel = vgui.Create( "DPanel", popup.EditArea )
	popup.EditArea.NamePanel:Dock( TOP )
	popup.EditArea.NamePanel:DockPadding( 150, 0, 12, 0 )
	popup.EditArea.NamePanel:DockMargin( 0, 0, 0, 10 )
	popup.EditArea.NamePanel.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 138, 0, w-138, h, Color( 255, 255, 255 ) )
		draw.SimpleText( "Song name:", "JukeBox.Font.18", 5, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.EditArea.NameEntry = vgui.Create( "DTextEntry", popup.EditArea.NamePanel )
	popup.EditArea.NameEntry:Dock( FILL )
	popup.EditArea.NameEntry.Val = ""
	popup.EditArea.NameEntry.Error1 = true
	popup.EditArea.NameEntry:SetFont( "JukeBox.Font.16" )
	popup.EditArea.NameEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnChange( self )
		end
	end
	popup.EditArea.NameEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base )
	end
	popup.EditArea.NameEntry.OnChange = function( self )
		self.Val = self:GetValue()
		if self:GetValue() != "" then
			self.Error1 = false
		else
			self.Error1 = true
		end
	end
	
	popup.EditArea.ArtistPanel = vgui.Create( "DPanel", popup.EditArea )
	popup.EditArea.ArtistPanel:Dock( TOP )
	popup.EditArea.ArtistPanel:DockPadding( 150, 0, 12, 0 )
	popup.EditArea.ArtistPanel:DockMargin( 0, 0, 0, 10 )
	popup.EditArea.ArtistPanel.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 138, 0, w-138, h, Color( 255, 255, 255 ) )
		draw.SimpleText( "Artist:", "JukeBox.Font.18", 5, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.EditArea.ArtistEntry = vgui.Create( "DTextEntry", popup.EditArea.ArtistPanel )
	popup.EditArea.ArtistEntry:Dock( FILL )
	popup.EditArea.ArtistEntry.Val = ""
	popup.EditArea.ArtistEntry.Error1 = true
	popup.EditArea.ArtistEntry:SetFont( "JukeBox.Font.16" )
	popup.EditArea.ArtistEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnChange( self )
		end
	end
	popup.EditArea.ArtistEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base )
	end
	popup.EditArea.ArtistEntry.OnChange = function( self )
		self.Val = self:GetValue()
		if self:GetValue() != "" then
			self.Error1 = false
		else
			self.Error1 = true
		end
	end
	
	popup.EditArea.URLPanel = vgui.Create( "DPanel", popup.EditArea )
	popup.EditArea.URLPanel:Dock( TOP )
	popup.EditArea.URLPanel:DockPadding( 150, 0, 0, 0 )
	popup.EditArea.URLPanel:DockMargin( 0, 0, 0, 10 )
	popup.EditArea.URLPanel.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 138, 0, w-138-120-10, h, Color( 100, 100, 100 ) )
		draw.SimpleText( "YouTube ID:", "JukeBox.Font.18", 5, h/2, Color( 255, 255, 255 ), 0, 1 )
	end	
	
	popup.EditArea.URLEntry = vgui.Create( "DTextEntry", popup.EditArea.URLPanel )
	popup.EditArea.URLEntry:Dock( FILL )
	popup.EditArea.URLEntry.Val = ""
	popup.EditArea.URLEntry.Error1 = true
	popup.EditArea.URLEntry.Error2 = true
	popup.EditArea.URLEntry.URLID = nil
	popup.EditArea.URLEntry:SetDisabled( true )
	popup.EditArea.URLEntry:SetEditable( false )
	popup.EditArea.URLEntry:SetFont( "JukeBox.Font.18" )
	popup.EditArea.URLEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnChange( self )
		end
	end
	popup.EditArea.URLEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 100, 100 ) )
		if not self.Error1 and not self.Error2 and self.URLID then
			surface.SetFont( "JukeBox.Font.18" )
			local beg, en = string.find( self:GetValue(), self.URLID, 0, true )
			local subw, subh = surface.GetTextSize( string.sub( self:GetValue(), 1, beg-1 ) )
			local idw, idh = surface.GetTextSize( string.sub( self:GetValue(), beg, en ) )
			draw.RoundedBox( 4, subw+1, 2, idw+4, h-4, JukeBox.Colours.Accept )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	popup.EditArea.URLEntry.OnChange = function( self )
		self.Val = self:GetValue()
		if self:GetValue() and self:GetValue() != "" then
			self.Error1 = false
			if (string.len( self:GetValue() ) == 11) then
				self.URLID = self:GetValue()
				self.Error2 = false
				return
			else
				self.URLID = nil
				self.Error2 = true
			end
		else
			self.Error1 = true
			self.Error2 = true
		end
	end
	
	popup.EditArea.URLCheck = vgui.Create( "DButton", popup.EditArea.URLPanel )
	popup.EditArea.URLCheck:SetWide( 120 )
	popup.EditArea.URLCheck:Dock( RIGHT )
	popup.EditArea.URLCheck:DockMargin( 24, 0, 0, 0 )
	popup.EditArea.URLCheck:SetText( "" )
	popup.EditArea.URLCheck.DoClick = function( self )
		local dropdown = vgui.Create( "DMenu" )
		dropdown:SetPos( input.GetCursorPos() )
		dropdown:MakePopup()
		dropdown.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
		end
		local dropdownVoteButton = dropdown:AddOption( "JukeBox Pop-up" )
		dropdownVoteButton:SetTextColor( Color( 255, 255, 255 ) )
		function dropdownVoteButton:DoClick()
			JukeBox.VGUI.Pages.AllSongs:CheckURL( popup, popup.EditArea.URLEntry:GetValue() )
		end
		dropdown:AddSpacer()
		local dropdownForceButton = dropdown:AddOption( "Steam Overlay" )
		dropdownForceButton:SetTextColor( Color( 255, 255, 255 ) )
		function dropdownForceButton:DoClick()
			gui.OpenURL( "https://www.youtube.com/watch?v="..popup.EditArea.URLEntry:GetValue() )
		end
	end
	popup.EditArea.URLCheck.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( "Check YouTube ID", "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	--// LENGTH \\--
	popup.EditArea.TimePanel = vgui.Create( "DPanel", popup.EditArea )
	popup.EditArea.TimePanel:Dock( TOP )
	popup.EditArea.TimePanel:SetTall( 36 )
	popup.EditArea.TimePanel:DockPadding( 138, 0, 12, 0 )
	popup.EditArea.TimePanel:DockMargin( 0, 0, 0, 4 )
	popup.EditArea.TimePanel.Paint = function( self, w, h )
		--draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 0, 255 ) )
		draw.SimpleText( "Length:", "JukeBox.Font.18", 5, 24/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.EditArea.TimeMinsPanel = vgui.Create( "DPanel", popup.EditArea.TimePanel )
	popup.EditArea.TimeMinsPanel:Dock( LEFT )
	popup.EditArea.TimeMinsPanel:DockPadding( 12, 0, 12, 12)
	popup.EditArea.TimeMinsPanel:DockMargin( 0, 0, 12, 0 )
	popup.EditArea.TimeMinsPanel.Paint = function( self, w, h )
		draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		draw.SimpleText( "MINS", "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	popup.EditArea.TimeMinsEntry = vgui.Create( "DNumberWang", popup.EditArea.TimeMinsPanel )
	popup.EditArea.TimeMinsEntry:Dock( FILL )
	popup.EditArea.TimeMinsEntry:SetFont( "JukeBox.Font.18" )
	popup.EditArea.TimeMinsEntry:SetMin( 0 )
	popup.EditArea.TimeMinsEntry:SetMax( math.floor(JukeBox.Settings.MaxSongLength/60) )
	popup.EditArea.TimeMinsEntry.Val = 0
	popup.EditArea.TimeMinsEntry.Issue1 = true
	popup.EditArea.TimeMinsEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	popup.EditArea.TimeMinsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	popup.EditArea.TimeMinsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		popup.EditArea.TimePanel.Checks()
		popup.EditArea.StartTimePanel.Checks()
		popup.EditArea.EndTimePanel.Checks()
	end
	
	popup.EditArea.TimeSecsPanel = vgui.Create( "DPanel", popup.EditArea.TimePanel )
	popup.EditArea.TimeSecsPanel:Dock( LEFT )
	popup.EditArea.TimeSecsPanel:DockPadding( 12, 0, 12, 12)
	popup.EditArea.TimeSecsPanel.Paint = function( self, w, h )
		draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		draw.SimpleText( "SECS", "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	popup.EditArea.TimeSecsEntry = vgui.Create( "DNumberWang", popup.EditArea.TimeSecsPanel )
	popup.EditArea.TimeSecsEntry:Dock( FILL )
	popup.EditArea.TimeSecsEntry:SetFont( "JukeBox.Font.18" )
	popup.EditArea.TimeSecsEntry:SetMin( 0 )
	popup.EditArea.TimeSecsEntry:SetMax( 59 )
	popup.EditArea.TimeSecsEntry.Val = 0
	popup.EditArea.TimeSecsEntry.Issue1 = true
	popup.EditArea.TimeSecsEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	popup.EditArea.TimeSecsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	popup.EditArea.TimeSecsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		popup.EditArea.TimePanel.Checks()
		popup.EditArea.StartTimePanel.Checks()
		popup.EditArea.EndTimePanel.Checks()
	end
	
	function popup.EditArea.TimePanel.Checks()
		if popup.EditArea.TimeSecsEntry:GetValue()+popup.EditArea.TimeMinsEntry:GetValue()*60 > 0 then
			popup.EditArea.TimeSecsEntry.Issue1 = false
			popup.EditArea.TimeMinsEntry.Issue1  = false
		else
			popup.EditArea.TimeSecsEntry.Issue1 = true
			popup.EditArea.TimeMinsEntry.Issue1  = true
		end
	end
	
	--// START TIME \\--
	popup.EditArea.StartTimePanel = vgui.Create( "DPanel", popup.EditArea )
	popup.EditArea.StartTimePanel:Dock( TOP )
	popup.EditArea.StartTimePanel:SetTall( 36 )
	popup.EditArea.StartTimePanel:DockPadding( 138, 0, 12, 0 )
	popup.EditArea.StartTimePanel:DockMargin( 0, 0, 0, 4 )
	popup.EditArea.StartTimePanel.Paint = function( self, w, h )
		--draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 0, 255 ) )
		draw.SimpleText( "Start time:", "JukeBox.Font.18", 5, 24/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.EditArea.StartTimeMinsPanel = vgui.Create( "DPanel", popup.EditArea.StartTimePanel )
	popup.EditArea.StartTimeMinsPanel:Dock( LEFT )
	popup.EditArea.StartTimeMinsPanel:DockPadding( 12, 0, 12, 12)
	popup.EditArea.StartTimeMinsPanel:DockMargin( 0, 0, 12, 0 )
	popup.EditArea.StartTimeMinsPanel.Paint = function( self, w, h )
		if popup.EditArea.StartTimeMinsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( "MINS", "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	popup.EditArea.StartTimeMinsEntry = vgui.Create( "DNumberWang", popup.EditArea.StartTimeMinsPanel )
	popup.EditArea.StartTimeMinsEntry:Dock( FILL )
	popup.EditArea.StartTimeMinsEntry:SetFont( "JukeBox.Font.18" )
	popup.EditArea.StartTimeMinsEntry:SetMin( 0 )
	popup.EditArea.StartTimeMinsEntry:SetMax( math.floor(JukeBox.Settings.MaxSongLength/60) )
	popup.EditArea.StartTimeMinsEntry:SetDisabled( true )
	popup.EditArea.StartTimeMinsEntry.Val = 0
	popup.EditArea.StartTimeMinsEntry.Issue1 = true
	popup.EditArea.StartTimeMinsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	popup.EditArea.StartTimeMinsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	popup.EditArea.StartTimeMinsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		popup.EditArea.TimePanel.Checks()
		popup.EditArea.StartTimePanel.Checks()
		popup.EditArea.EndTimePanel.Checks()
	end
	
	popup.EditArea.StartTimeSecsPanel = vgui.Create( "DPanel", popup.EditArea.StartTimePanel )
	popup.EditArea.StartTimeSecsPanel:Dock( LEFT )
	popup.EditArea.StartTimeSecsPanel:DockPadding( 12, 0, 12, 12)
	popup.EditArea.StartTimeSecsPanel.Paint = function( self, w, h )
		if popup.EditArea.StartTimeSecsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( "SECS", "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	popup.EditArea.StartTimeSecsEntry = vgui.Create( "DNumberWang", popup.EditArea.StartTimeSecsPanel )
	popup.EditArea.StartTimeSecsEntry:Dock( FILL )
	popup.EditArea.StartTimeSecsEntry:SetFont( "JukeBox.Font.18" )
	popup.EditArea.StartTimeSecsEntry:SetMin( 0 )
	popup.EditArea.StartTimeSecsEntry:SetMax( 59 )
	popup.EditArea.StartTimeSecsEntry:SetDisabled( true )
	popup.EditArea.StartTimeSecsEntry.Val = 0
	popup.EditArea.StartTimeSecsEntry.Issue1 = true
	popup.EditArea.StartTimeSecsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	popup.EditArea.StartTimeSecsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	popup.EditArea.StartTimeSecsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		popup.EditArea.TimePanel.Checks()
		popup.EditArea.StartTimePanel.Checks()
		popup.EditArea.EndTimePanel.Checks()
	end

	popup.EditArea.StartTimeEnable = vgui.Create( "DButton", popup.EditArea.StartTimePanel )
	popup.EditArea.StartTimeEnable:Dock( LEFT )
	popup.EditArea.StartTimeEnable:SetWide( 70 )
	popup.EditArea.StartTimeEnable:SetTall( 24 )
	popup.EditArea.StartTimeEnable.Enabled = false
	popup.EditArea.StartTimeEnable:DockMargin( 20, 0, 0, 12 )
	popup.EditArea.StartTimeEnable:SetText( "" )
	popup.EditArea.StartTimeEnable.DoClick = function( self )
		self.Enabled = !self.Enabled
		popup.EditArea.StartTimeSecsEntry:SetDisabled( !self.Enabled )
		popup.EditArea.StartTimeMinsEntry:SetDisabled( !self.Enabled )
	end
	popup.EditArea.StartTimeEnable.Paint = function( self, w, h )
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
	
	function popup.EditArea.StartTimePanel.Checks()
		if popup.EditArea.StartTimeSecsEntry:GetValue()+popup.EditArea.StartTimeMinsEntry:GetValue()*60 >= 0 then
			popup.EditArea.StartTimeSecsEntry.Issue1 = false
			popup.EditArea.StartTimeMinsEntry.Issue1  = false
			if ( popup.EditArea.StartTimeSecsEntry:GetValue()+popup.EditArea.StartTimeMinsEntry:GetValue()*60 >= popup.EditArea.TimeSecsEntry:GetValue()+popup.EditArea.TimeMinsEntry:GetValue()*60 ) then
				popup.EditArea.StartTimeSecsEntry.Issue2 = true
				popup.EditArea.StartTimeMinsEntry.Issue2 = true
			else
				popup.EditArea.StartTimeSecsEntry.Issue2 = false
				popup.EditArea.StartTimeMinsEntry.Issue2 = false
			end
		else
			popup.EditArea.StartTimeSecsEntry.Issue1 = true
			popup.EditArea.StartTimeMinsEntry.Issue1  = true
		end
	end
	
	--// END TIME \\--
	popup.EditArea.EndTimePanel = vgui.Create( "DPanel", popup.EditArea )
	popup.EditArea.EndTimePanel:Dock( TOP )
	popup.EditArea.EndTimePanel:SetTall( 36 )
	popup.EditArea.EndTimePanel:DockPadding( 138, 0, 12, 0 )
	popup.EditArea.EndTimePanel:DockMargin( 0, 0, 0, 4 )
	popup.EditArea.EndTimePanel.Paint = function( self, w, h )
		--draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 0, 255 ) )
		draw.SimpleText( "End time:", "JukeBox.Font.18", 5, 24/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.EditArea.EndTimeMinsPanel = vgui.Create( "DPanel", popup.EditArea.EndTimePanel )
	popup.EditArea.EndTimeMinsPanel:Dock( LEFT )
	popup.EditArea.EndTimeMinsPanel:DockPadding( 12, 0, 12, 12)
	popup.EditArea.EndTimeMinsPanel:DockMargin( 0, 0, 12, 0 )
	popup.EditArea.EndTimeMinsPanel.Paint = function( self, w, h )
		if popup.EditArea.EndTimeMinsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( "MINS", "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	popup.EditArea.EndTimeMinsEntry = vgui.Create( "DNumberWang", popup.EditArea.EndTimeMinsPanel )
	popup.EditArea.EndTimeMinsEntry:Dock( FILL )
	popup.EditArea.EndTimeMinsEntry:SetFont( "JukeBox.Font.18" )
	popup.EditArea.EndTimeMinsEntry:SetMin( 0 )
	popup.EditArea.EndTimeMinsEntry:SetMax( math.floor(JukeBox.Settings.MaxSongLength/60) )
	popup.EditArea.EndTimeMinsEntry:SetDisabled( true )
	popup.EditArea.EndTimeMinsEntry.Val = 0
	popup.EditArea.EndTimeMinsEntry.Issue1 = true
	popup.EditArea.EndTimeMinsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	popup.EditArea.EndTimeMinsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	popup.EditArea.EndTimeMinsEntry.OnValueChanged = function( self )
		if self.Override then return end
		self.Val = self:GetValue()
		popup.EditArea.EndTimePanel.Checks()
	end
	popup.EditArea.EndTimeMinsEntry.ChangeValue = function( value )
		popup.EditArea.EndTimeMinsEntry.Override = true
		popup.EditArea.EndTimeMinsEntry:SetValue( value )
		popup.EditArea.EndTimeMinsEntry.Override = false
	end
	
	popup.EditArea.EndTimeSecsPanel = vgui.Create( "DPanel", popup.EditArea.EndTimePanel )
	popup.EditArea.EndTimeSecsPanel:Dock( LEFT )
	popup.EditArea.EndTimeSecsPanel:DockPadding( 12, 0, 12, 12)
	popup.EditArea.EndTimeSecsPanel.Paint = function( self, w, h )
		if popup.EditArea.EndTimeSecsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( "SECS", "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	popup.EditArea.EndTimeSecsEntry = vgui.Create( "DNumberWang", popup.EditArea.EndTimeSecsPanel )
	popup.EditArea.EndTimeSecsEntry:Dock( FILL )
	popup.EditArea.EndTimeSecsEntry:SetFont( "JukeBox.Font.18" )
	popup.EditArea.EndTimeSecsEntry:SetMin( 0 )
	popup.EditArea.EndTimeSecsEntry:SetMax( 59 )
	popup.EditArea.EndTimeSecsEntry:SetDisabled( true )
	popup.EditArea.EndTimeSecsEntry.Val = 0
	popup.EditArea.EndTimeSecsEntry.Issue1 = true
	popup.EditArea.EndTimeSecsEntry.Override = false
	popup.EditArea.EndTimeSecsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	popup.EditArea.EndTimeSecsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	popup.EditArea.EndTimeSecsEntry.OnValueChanged = function( self )
		if self.Override then return end
		self.Val = self:GetValue()
		popup.EditArea.EndTimePanel.Checks()
	end
	popup.EditArea.EndTimeSecsEntry.ChangeValue = function( value )
		popup.EditArea.EndTimeSecsEntry.Override = true
		popup.EditArea.EndTimeSecsEntry:SetValue( value )
		popup.EditArea.EndTimeSecsEntry.Override = false
	end
	
	popup.EditArea.EndTimeEnable = vgui.Create( "DButton", popup.EditArea.EndTimePanel )
	popup.EditArea.EndTimeEnable:Dock( LEFT )
	popup.EditArea.EndTimeEnable:SetWide( 70 )
	popup.EditArea.EndTimeEnable:SetTall( 24 )
	popup.EditArea.EndTimeEnable.Enabled = false
	popup.EditArea.EndTimeEnable:DockMargin( 20, 0, 0, 12 )
	popup.EditArea.EndTimeEnable:SetText( "" )
	popup.EditArea.EndTimeEnable.DoClick = function( self )
		self.Enabled = !self.Enabled
		popup.EditArea.EndTimeSecsEntry:SetDisabled( !self.Enabled )
		popup.EditArea.EndTimeMinsEntry:SetDisabled( !self.Enabled )
	end
	popup.EditArea.EndTimeEnable.Paint = function( self, w, h )
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
	
	function popup.EditArea.EndTimePanel.Checks()
		if not popup.EditArea.EndTimeEnable.Enabled then
			popup.EditArea.EndTimeSecsEntry.ChangeValue( popup.EditArea.TimeSecsEntry:GetValue() )
			popup.EditArea.EndTimeMinsEntry.ChangeValue( popup.EditArea.TimeMinsEntry:GetValue() )
		end
		if popup.EditArea.EndTimeSecsEntry:GetValue()+popup.EditArea.EndTimeMinsEntry:GetValue()*60 > 0 then
			popup.EditArea.EndTimeSecsEntry.Issue1 = false
			popup.EditArea.EndTimeMinsEntry.Issue1  = false
			if ( popup.EditArea.EndTimeSecsEntry:GetValue()+popup.EditArea.EndTimeMinsEntry:GetValue()*60 > popup.EditArea.TimeSecsEntry:GetValue()+popup.EditArea.TimeMinsEntry:GetValue()*60) then
				popup.EditArea.EndTimeSecsEntry.Issue2 = true
				popup.EditArea.EndTimeMinsEntry.Issue2 = true
			else
				popup.EditArea.EndTimeSecsEntry.Issue2 = false
				popup.EditArea.EndTimeMinsEntry.Issue2 = false
			end
		else
			popup.EditArea.EndTimeSecsEntry.Issue1 = true
			popup.EditArea.EndTimeMinsEntry.Issue1  = true
		end
	end
	
	--// BEHIND THE SCENES \\--
	function popup.EditArea.SetValues( info )
		popup.EditArea.NameEntry:SetValue( info.name )
		popup.EditArea.ArtistEntry:SetValue( info.artist )
		popup.EditArea.URLEntry:SetValue( info.id )
		popup.EditArea.TimeMinsEntry:SetValue( math.floor( info.length/60 ) )
		popup.EditArea.TimeSecsEntry:SetValue( info.length%60 )
		if info.starttime then
			if not popup.EditArea.StartTimeEnable.Enabled then
				popup.EditArea.StartTimeEnable:DoClick()
			end
			popup.EditArea.StartTimeMinsEntry:SetValue( math.floor( info.starttime/60 ) )
			popup.EditArea.StartTimeSecsEntry:SetValue( info.starttime%60 )
		else
			if popup.EditArea.StartTimeEnable.Enabled then
				popup.EditArea.StartTimeEnable:DoClick()
			end
			popup.EditArea.StartTimeMinsEntry:SetValue( 0 )
			popup.EditArea.StartTimeSecsEntry:SetValue( 0 )
		end
		if info.endtime then
			if not popup.EditArea.EndTimeEnable.Enabled then
				popup.EditArea.EndTimeEnable:DoClick()
			end
			popup.EditArea.EndTimeMinsEntry.ChangeValue( math.floor( info.endtime/60 ) )
			popup.EditArea.EndTimeSecsEntry.ChangeValue( info.endtime%60 )
		else
			if popup.EditArea.EndTimeEnable.Enabled then
				popup.EditArea.EndTimeEnable:DoClick()
			end
			popup.EditArea.EndTimePanel.Checks()
		end
	end
	
	popup.EditArea.ActionButtons = vgui.Create( "DPanel", popup.EditArea )
	popup.EditArea.ActionButtons:Dock( BOTTOM )
	popup.EditArea.ActionButtons:SetTall( 30 )
	popup.EditArea.ActionButtons.Paint = function( self, w, h )
		
	end
	
	popup.EditArea.ActionButtons.Accept = vgui.Create( "DButton", popup.EditArea.ActionButtons )
	popup.EditArea.ActionButtons.Accept:Dock( LEFT )
	popup.EditArea.ActionButtons.Accept:DockMargin( 0, 0, 10, 0 )
	popup.EditArea.ActionButtons.Accept:SetWide( 145 )
	popup.EditArea.ActionButtons.Accept:SetText( "" )
	popup.EditArea.ActionButtons.Accept.DoClick = function( self )
		popup.EditArea.CheckValues()
	end
	popup.EditArea.ActionButtons.Accept.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( "Update Song", "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end

	popup.EditArea.ActionButtons.Delete = vgui.Create( "DButton", popup.EditArea.ActionButtons )
	popup.EditArea.ActionButtons.Delete:Dock( LEFT )
	popup.EditArea.ActionButtons.Delete:SetWide( 140 )
	popup.EditArea.ActionButtons.Delete:SetText( "" )
	popup.EditArea.ActionButtons.Delete.DoClick = function( self )
		popup.EditArea.DeletePopup( popup.EditArea.GetValues(), bg )
	end
	popup.EditArea.ActionButtons.Delete.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Issue )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/cross.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( "Delete Song", "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.EditArea.ActionButtons.Cancel = vgui.Create( "DButton", popup.EditArea.ActionButtons )
	popup.EditArea.ActionButtons.Cancel:SetWide( 100 )
	popup.EditArea.ActionButtons.Cancel:Dock( RIGHT )
	popup.EditArea.ActionButtons.Cancel:SetVisible( true )
	popup.EditArea.ActionButtons.Cancel:DockMargin( 0, 0, 10, 0 )
	popup.EditArea.ActionButtons.Cancel:SetText( "" )
	popup.EditArea.ActionButtons.Cancel.Text = "Cancel"
	popup.EditArea.ActionButtons.Cancel.DoClick = function()
		bg:Remove()
	end
	popup.EditArea.ActionButtons.Cancel.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	function popup.EditArea.SetValues( info )
		popup.EditArea.NameEntry:SetValue( info.name )
		popup.EditArea.ArtistEntry:SetValue( info.artist )
		popup.EditArea.URLEntry:SetValue( info.id )
		popup.EditArea.TimeMinsEntry:SetValue( math.floor( info.length/60 ) )
		popup.EditArea.TimeSecsEntry:SetValue( info.length%60 )
		if info.starttime then
			if not popup.EditArea.StartTimeEnable.Enabled then
				popup.EditArea.StartTimeEnable:DoClick()
			end
			popup.EditArea.StartTimeMinsEntry:SetValue( math.floor( info.starttime/60 ) )
			popup.EditArea.StartTimeSecsEntry:SetValue( info.starttime%60 )
		else
			if popup.EditArea.StartTimeEnable.Enabled then
				popup.EditArea.StartTimeEnable:DoClick()
			end
			popup.EditArea.StartTimeMinsEntry:SetValue( 0 )
			popup.EditArea.StartTimeSecsEntry:SetValue( 0 )
		end
		if info.endtime then
			if not popup.EditArea.EndTimeEnable.Enabled then
				popup.EditArea.EndTimeEnable:DoClick()
			end
			popup.EditArea.EndTimeMinsEntry.ChangeValue( math.floor( info.endtime/60 ) )
			popup.EditArea.EndTimeSecsEntry.ChangeValue( info.endtime%60 )
		else
			if popup.EditArea.EndTimeEnable.Enabled then
				popup.EditArea.EndTimeEnable:DoClick()
			end
			popup.EditArea.EndTimePanel.Checks()
		end
	end
	popup.EditArea.SetValues( data )
	
	function popup.EditArea.GetValues()
		local data = {}
		data.name = popup.EditArea.NameEntry:GetValue()
		data.artist = popup.EditArea.ArtistEntry:GetValue()
		data.id = popup.EditArea.URLEntry:GetValue()
		data.length = popup.EditArea.TimeMinsEntry:GetValue()*60+popup.EditArea.TimeSecsEntry:GetValue()
		if popup.EditArea.StartTimeEnable.Enabled then
			data.starttime = popup.EditArea.StartTimeMinsEntry:GetValue()*60+popup.EditArea.StartTimeSecsEntry:GetValue()
		end
		if popup.EditArea.EndTimeEnable.Enabled then
			data.endtime = popup.EditArea.EndTimeMinsEntry:GetValue()*60+popup.EditArea.EndTimeSecsEntry:GetValue()
		end
		return data
	end
	
	function popup.EditArea.CheckValues()
		local errors = {}
		if popup.EditArea.NameEntry.Error1 then
			table.insert( errors, "Song Name" )
		end
		if popup.EditArea.ArtistEntry.Error1 then
			table.insert( errors, "Artist" )
		end
		if popup.EditArea.URLEntry.Error1 or popup.EditArea.URLEntry.Error2 then
			table.insert( errors, "YouTube URL" )
		end
		if popup.EditArea.TimeMinsEntry.Issue1 or popup.EditArea.TimeSecsEntry.Issue1 then
			table.insert( errors, "Length" )
		end
		if (!popup.EditArea.StartTimeMinsEntry:GetDisabled() or !popup.EditArea.StartTimeSecsEntry:GetDisabled())  and (popup.EditArea.StartTimeMinsEntry.Issue1 or popup.EditArea.StartTimeSecsEntry.Issue1 or popup.EditArea.StartTimeMinsEntry.Issue2 or popup.EditArea.StartTimeSecsEntry.Issue2) then
			table.insert( errors, "Start Time" )
		end
		if (!popup.EditArea.EndTimeMinsEntry:GetDisabled() or !popup.EditArea.EndTimeSecsEntry:GetDisabled())  and (popup.EditArea.EndTimeMinsEntry.Issue1 or popup.EditArea.EndTimeSecsEntry.Issue1 or popup.EditArea.EndTimeMinsEntry.Issue2 or popup.EditArea.EndTimeSecsEntry.Issue2) then
			table.insert( errors, "End Time" )
		end
		if table.Count( errors ) > 0 then
			local words = ""
			for k, v in pairs( errors ) do
				if k == 1 then
					words = words.."- "..v
				else
					words = words.."\n".."- "..v
				end
			end
			popup.EditArea.DisplayIssues( words )
		else
			popup.EditArea.AcceptPopup( data, bg )
		end
	end
	
	function popup.EditArea.DisplayIssues( words )
		local text = "There are issues with the following fields: \n"..words
		
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
		
		local newpopup = vgui.Create( "DPanel", bg )
		newpopup:SetSize( 500, 400 )
		newpopup:Center()
		newpopup.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
		end
		
		newpopup.TopBar = vgui.Create( "DPanel", newpopup )
		newpopup.TopBar:Dock( TOP )
		newpopup.TopBar:SetTall( 28 )
		newpopup.TopBar:DockPadding( 4, 4, 4, 4 )
		newpopup.TopBar.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
			draw.SimpleText( "JukeBox - Error", "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
		
		newpopup.TopBar.CloseButton = vgui.Create( "DButton", newpopup.TopBar )
		newpopup.TopBar.CloseButton:Dock( RIGHT )
		newpopup.TopBar.CloseButton:SetWide( 50 )
		newpopup.TopBar.CloseButton:SetText( "" )
		newpopup.TopBar.CloseButton.DoClick = function()
			bg:Remove()
		end
		newpopup.TopBar.CloseButton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 57, 43 ) )
			if not JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255 ), 0 )
		end
		
		newpopup.Content = vgui.Create( "DPanel", newpopup )
		newpopup.Content:DockMargin( 0, 1, 0, 0 )
		newpopup.Content:DockPadding( 5, 5, 5, 5 )
		newpopup.Content:Dock( FILL )
		newpopup.Content.Progress = 1
		newpopup.Content.ProgressData = ""
		newpopup.Content.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		end
		
		newpopup.Body = vgui.Create( "DLabel", newpopup.Content )
		newpopup.Body:SetFont( "JukeBox.Font.18" )
		newpopup.Body:SetTextColor( Color( 255, 255, 255 ) )
		newpopup.Body:SetText( text )
		newpopup.Body:SizeToContents()
		newpopup:SetWide( newpopup.Body:GetWide()+10 )
		newpopup:SetTall( newpopup.Body:GetTall()+newpopup.TopBar:GetTall()+11+50 )
		newpopup.Body:Dock( TOP )
		newpopup:Center()
		
		newpopup.BottomBar = vgui.Create( "DPanel", newpopup.Content )
		newpopup.BottomBar:Dock( BOTTOM )
		newpopup.BottomBar:SetTall( 30 )
		newpopup.BottomBar:DockMargin( 0, 0, 0, 5 )
		newpopup.BottomBar.Paint = function( self, w, h ) end
		
		newpopup.CancelButton = vgui.Create( "DButton", newpopup.BottomBar )
		newpopup.CancelButton:SetTall( 30 )
		newpopup.CancelButton:Dock( BOTTOM )
		newpopup.CancelButton:SetVisible( true )
		newpopup.CancelButton:DockMargin( 30, 0, 30, 0 )
		newpopup.CancelButton:SetText( "" )
		newpopup.CancelButton.Text = "Close"
		newpopup.CancelButton.DoClick = function()
			bg:Remove()
		end
		newpopup.CancelButton.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2-1, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			else
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	function popup.EditArea.AcceptPopup( data, bg2 )
		local text = "Are you sure you wish to commit the changes you have made?\nPlease make sure all data is correct before saving."
		
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
		
		local newpopup = vgui.Create( "DPanel", bg )
		newpopup:SetSize( 500, 400 )
		newpopup:Center()
		newpopup.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
		end
		
		newpopup.TopBar = vgui.Create( "DPanel", newpopup )
		newpopup.TopBar:Dock( TOP )
		newpopup.TopBar:SetTall( 28 )
		newpopup.TopBar:DockPadding( 4, 4, 4, 4 )
		newpopup.TopBar.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
			draw.SimpleText( "JukeBox - Update Song", "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
		
		newpopup.TopBar.CloseButton = vgui.Create( "DButton", newpopup.TopBar )
		newpopup.TopBar.CloseButton:Dock( RIGHT )
		newpopup.TopBar.CloseButton:SetWide( 50 )
		newpopup.TopBar.CloseButton:SetText( "" )
		newpopup.TopBar.CloseButton.DoClick = function()
			bg:Remove()
		end
		newpopup.TopBar.CloseButton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 57, 43 ) )
			if not JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255 ), 0 )
		end
		
		newpopup.Content = vgui.Create( "DPanel", newpopup )
		newpopup.Content:DockMargin( 0, 1, 0, 0 )
		newpopup.Content:DockPadding( 5, 5, 5, 5 )
		newpopup.Content:Dock( FILL )
		newpopup.Content.Progress = 1
		newpopup.Content.ProgressData = ""
		newpopup.Content.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		end
		
		newpopup.Body = vgui.Create( "DLabel", newpopup.Content )
		newpopup.Body:SetFont( "JukeBox.Font.18" )
		newpopup.Body:SetTextColor( Color( 255, 255, 255 ) )
		newpopup.Body:SetText( text )
		newpopup.Body:SizeToContents()
		newpopup:SetWide( newpopup.Body:GetWide()+10 )
		newpopup:SetTall( newpopup.Body:GetTall()+newpopup.TopBar:GetTall()+11+50 )
		newpopup.Body:Dock( TOP )
		newpopup:Center()
		
		newpopup.BottomBar = vgui.Create( "DPanel", newpopup.Content )
		newpopup.BottomBar:Dock( BOTTOM )
		newpopup.BottomBar:SetTall( 30 )
		newpopup.BottomBar:DockMargin( 0, 0, 0, 5 )
		newpopup.BottomBar.Paint = function( self, w, h ) end
		
		newpopup.AcceptButton = vgui.Create( "DButton", newpopup.BottomBar )
		newpopup.AcceptButton:SetWide( 150 )
		newpopup.AcceptButton:Dock( LEFT )
		newpopup.AcceptButton:SetVisible( true )
		newpopup.AcceptButton:DockMargin( 10, 0, 0, 0 )
		newpopup.AcceptButton:SetText( "" )
		newpopup.AcceptButton.Text = "Save Changes"
		newpopup.AcceptButton.DoClick = function()
			local data = popup.EditArea.GetValues()
			JukeBox:UpdateSong( data )
			bg:Remove()
			if bg2 and ValidPanel( bg2 ) then
				bg2:Remove()
			end			
		end
		newpopup.AcceptButton.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
			else
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
			draw.SimpleText( "Save Changes", "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
		end
		
		newpopup.CancelButton = vgui.Create( "DButton", newpopup.BottomBar )
		newpopup.CancelButton:SetWide( 100 )
		newpopup.CancelButton:Dock( RIGHT )
		newpopup.CancelButton:SetVisible( true )
		newpopup.CancelButton:DockMargin( 0, 0, 10, 0 )
		newpopup.CancelButton:SetText( "" )
		newpopup.CancelButton.Text = "Cancel"
		newpopup.CancelButton.DoClick = function()
			bg:Remove()
		end
		newpopup.CancelButton.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2-1, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			else
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	function popup.EditArea.DeletePopup( data, bg2 )
		local text = "Are you sure you wish to delete this song?\nThe song will not be recoverable and will have to be re-submitted."
		
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
		
		local newpopup = vgui.Create( "DPanel", bg )
		newpopup:SetSize( 500, 400 )
		newpopup:Center()
		newpopup.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
		end
		
		newpopup.TopBar = vgui.Create( "DPanel", newpopup )
		newpopup.TopBar:Dock( TOP )
		newpopup.TopBar:SetTall( 28 )
		newpopup.TopBar:DockPadding( 4, 4, 4, 4 )
		newpopup.TopBar.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
			draw.SimpleText( "JukeBox - Delete Song", "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
		
		newpopup.TopBar.CloseButton = vgui.Create( "DButton", newpopup.TopBar )
		newpopup.TopBar.CloseButton:Dock( RIGHT )
		newpopup.TopBar.CloseButton:SetWide( 50 )
		newpopup.TopBar.CloseButton:SetText( "" )
		newpopup.TopBar.CloseButton.DoClick = function()
			bg:Remove()
		end
		newpopup.TopBar.CloseButton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 57, 43 ) )
			if not JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255 ), 0 )
		end
		
		newpopup.Content = vgui.Create( "DPanel", newpopup )
		newpopup.Content:DockMargin( 0, 1, 0, 0 )
		newpopup.Content:DockPadding( 5, 5, 5, 5 )
		newpopup.Content:Dock( FILL )
		newpopup.Content.Progress = 1
		newpopup.Content.ProgressData = ""
		newpopup.Content.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		end
		
		newpopup.Body = vgui.Create( "DLabel", newpopup.Content )
		newpopup.Body:SetFont( "JukeBox.Font.18" )
		newpopup.Body:SetTextColor( Color( 255, 255, 255 ) )
		newpopup.Body:SetText( text )
		newpopup.Body:SizeToContents()
		newpopup:SetWide( newpopup.Body:GetWide()+10 )
		newpopup:SetTall( newpopup.Body:GetTall()+newpopup.TopBar:GetTall()+11+50 )
		newpopup.Body:Dock( TOP )
		newpopup:Center()
		
		newpopup.BottomBar = vgui.Create( "DPanel", newpopup.Content )
		newpopup.BottomBar:Dock( BOTTOM )
		newpopup.BottomBar:SetTall( 30 )
		newpopup.BottomBar:DockMargin( 0, 0, 0, 5 )
		newpopup.BottomBar.Paint = function( self, w, h ) end
		
		newpopup.DeleteButton = vgui.Create( "DButton", newpopup.BottomBar )
		newpopup.DeleteButton:SetWide( 135 )
		newpopup.DeleteButton:Dock( LEFT )
		newpopup.DeleteButton:SetVisible( true )
		newpopup.DeleteButton:DockMargin( 10, 0, 0, 0 )
		newpopup.DeleteButton:SetText( "" )
		newpopup.DeleteButton.Text = "Delete Song"
		newpopup.DeleteButton.DoClick = function()
			local data = popup.EditArea.GetValues()
			JukeBox:DeleteSong( data.id )
			bg:Remove()
			if bg2 and ValidPanel( bg2 ) then
				bg2:Remove()
			end	
		end
		newpopup.DeleteButton.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Issue )
			else
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/cross.png", Color( 255, 255, 255 ), 0 )
			draw.SimpleText( "Delete Song", "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
		end
		
		newpopup.CancelButton = vgui.Create( "DButton", newpopup.BottomBar )
		newpopup.CancelButton:SetWide( 100 )
		newpopup.CancelButton:Dock( RIGHT )
		newpopup.CancelButton:SetVisible( true )
		newpopup.CancelButton:DockMargin( 0, 0, 10, 0 )
		newpopup.CancelButton:SetText( "" )
		newpopup.CancelButton.Text = "Cancel"
		newpopup.CancelButton.DoClick = function()
			bg:Remove()
		end
		newpopup.CancelButton.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2-1, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			else
				draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
			end
			draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
end
 
JukeBox.VGUI:RegisterPage( "#TAB_Main", "AllSongs", "#TAB_AllSongs", "jukebox/music.png", function( parent ) JukeBox.VGUI.Pages.AllSongs:CreatePanel( parent ) end )