JukeBox.VGUI.Pages.AddPlaylist = {}

function JukeBox.VGUI.Pages.AddPlaylist:CreatePanel( parent )
	JukeBox.VGUI.Pages.AddPlaylist:CreateHomepage( parent )
end

function JukeBox.VGUI.Pages.AddPlaylist:CreateHomepage( parent )
	parent:Clear()

	parent.Description = vgui.Create( "DLabel", parent )
	parent.Description:Dock( TOP )
	parent.Description:SetText( JukeBox.Lang:GetPhrase( "#PLAYLIST_Description" ) )
	parent.Description:SetFont( "JukeBox.Font.20" )
	parent.Description:DockMargin( 10, 10, 10, 0 )
	parent.Description:SetTall( 40 )
	parent.Description:SetWrap( true )

	parent.Top = vgui.Create( "DPanel", parent )
	parent.Top:Dock( TOP )
	parent.Top:SetTall( 42 )
	parent.Top.Paint = function( self, w, h )
		draw.RoundedBox( 12, 5, 10, w-94, h-20, Color( 255, 255, 255 ) )
		--draw.RoundedBox( 12, w-104, 10, h, h-20, Color( 255, 255, 255 ) )
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 14, "jukebox/search.png", JukeBox.Colours.Base, 0 )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
	end

	parent.Top.Search = vgui.Create( "DTextEntry", parent.Top )
	parent.Top.Search:Dock( FILL )
	parent.Top.Search:DockMargin( 28, 10, 0, 10 )
	parent.Top.Search:SetFont( "JukeBox.Font.16" )
	parent.Top.Search:SetDrawBorder( false )
	parent.Top.Search.Issue = 0
	parent.Top.Search.OnChange = function( self, w, h )

	end
	parent.Top.Search.OnEnter = function()
		parent.Scroll.SearchForSong()
	end
	parent.Top.Search.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color(30, 130, 255), JukeBox.Colours.Base)
	end

	parent.Top.Go = vgui.Create( "DButton", parent.Top )
	parent.Top.Go:Dock( RIGHT )
	parent.Top.Go:SetWide( 70 )
	parent.Top.Go:SetTall( 24 )
	parent.Top.Go:DockMargin( 24, 10, 10, 8 )
	parent.Top.Go:SetText( "" )
	parent.Top.Go.DoClick = function( self )
		parent.Scroll.SearchForSong()
	end
	parent.Top.Go.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#SEARCH_Search" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#SEARCH_Search" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end

	parent.Scroll = vgui.Create( "DScrollPanel", parent )
	parent.Scroll:Dock( FILL )
	parent.Scroll.Count = 0
	parent.Scroll.Loading = false
	parent.Scroll.Issue = false
	parent.Scroll.VBar:SetWide( 10 )
	parent.Scroll.Paint = function( self, w, h )
		if self.Loading then
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/loading.png", Color( 255, 255, 255 ), -CurTime()*100 )
			draw.SimpleText(JukeBox.Lang:GetPhrase("#PLAYLIST_Loading"), "JukeBox.Font.20", w/2, h/2+80, Color( 255, 255, 255 ), 1, 1 )
		elseif self.Issue then
			draw.SimpleText( self.Issue, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
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

	parent.Scroll.SearchForSong = function()
		if parent.Scroll.Loading then return end
		parent.Scroll:Clear()
		if parent.AcceptArea then
			parent.AcceptArea:Remove()
		end
		parent.Scroll.Loading = true
		parent.Scroll.Issue = false
		JukeBox:Fetch({ request = "playlist", id = parent.Top.Search:GetValue()},
			function(data)
				if not ValidPanel( parent.Scroll ) then return end
				parent.Scroll.Loading = false
				local info = data
				if not (type( info ) == "table") then
					parent.Scroll.Issue = JukeBox.Lang:GetPhrase( "#PLAYLIST_InvalidID" )
					return
				end
				if table.Count( info ) >= 1 then
					for k, v in pairs( info ) do
						parent.Scroll.AddVideoCard( parent.Scroll, v )
					end

					parent.AcceptArea = vgui.Create("DPanel", parent)
					parent.AcceptArea:Dock(BOTTOM)
					parent.AcceptArea:SetTall(60)
					parent.AcceptArea.Paint = function(self,w,h)
						draw.RoundedBox( 0, 0, 0, w, 1, JukeBox.Colours.Base )
					end

					parent.Accept = vgui.Create("DButton", parent.AcceptArea)
					parent.Accept:Dock( TOP )
					parent.Accept:SetWide( 200 )
					parent.Accept:SetTall( 40 )
					parent.Accept:DockMargin( 10, 10, 10, 10 )
					parent.Accept:SetText( "" )
					parent.Accept.DoClick = function()
						JukeBox.VGUI.Pages.AddPlaylist:AddAllSongs( parent.Scroll:GetCanvas():GetChildren() )
						parent.Scroll:Clear()
						parent.AcceptArea:Remove()
						parent.Top.Search:SetValue("")
					end
					parent.Accept.Paint = function( self, w, h )
						if JukeBox.VGUI.VGUI:GetHovered( self ) then
							draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
						else
							draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
						end
						draw.SimpleText( JukeBox.Lang:GetPhrase( "#PLAYLIST_AddAllSongs" ), "JukeBox.Font.20", w/2, h/2-2, Color( 255, 255, 255 ), 1, 1 )
					end
				else
					parent.Scroll.Issue = JukeBox.Lang:GetPhrase( "#PLAYLIST_InvalidID" )
				end
			end,
			function( issue )
					if not ValidPanel( parent.Scroll ) then return end
					parent.Scroll.Loading = false
					parent.Scroll.Issue = JukeBox.Lang:GetPhrase( "#PLAYLIST_UnexpectedErr" )
				end
		)
		-- http.Fetch( JukeBox.Settings.PlaylistURL..string.Replace(parent.Top.Search:GetValue(), " ", "+"),
		-- function( body )
		-- 	if not ValidPanel( parent.Scroll ) then return end
		-- 	parent.Scroll.Loading = false
		-- 	local info = util.JSONToTable( body )
		-- 	if info == "" or info == " " or info == nil then return end
		-- 	if not (type( info ) == "table") then
		-- 		parent.Scroll.Issue = JukeBox.Lang:GetPhrase( "#PLAYLIST_InvalidID" )
		-- 		return
		-- 	end
		-- 	if table.Count( info ) >= 1 then
		-- 		for k, v in pairs( info ) do
		-- 			parent.Scroll.AddVideoCard( parent.Scroll, v )
		-- 		end

		-- 		parent.AcceptArea = vgui.Create("DPanel", parent)
		-- 		parent.AcceptArea:Dock(BOTTOM)
		-- 		parent.AcceptArea:SetTall(60)
		-- 		parent.AcceptArea.Paint = function(self,w,h)
		-- 			draw.RoundedBox( 0, 0, 0, w, 1, JukeBox.Colours.Base )
		-- 		end

		-- 		parent.Accept = vgui.Create("DButton", parent.AcceptArea)
		-- 		parent.Accept:Dock( TOP )
		-- 		parent.Accept:SetWide( 200 )
		-- 		parent.Accept:SetTall( 40 )
		-- 		parent.Accept:DockMargin( 10, 10, 10, 10 )
		-- 		parent.Accept:SetText( "" )
		-- 		parent.Accept.DoClick = function()
		-- 			JukeBox.VGUI.Pages.AddPlaylist:AddAllSongs( parent.Scroll:GetCanvas():GetChildren() )
		-- 			parent.Scroll:Clear()
		-- 			parent.AcceptArea:Remove()
		-- 			parent.Top.Search:SetValue("")
		-- 		end
		-- 		parent.Accept.Paint = function( self, w, h )
		-- 			if JukeBox.VGUI.VGUI:GetHovered( self ) then
		-- 				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		-- 			else
		-- 				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		-- 			end
		-- 			draw.SimpleText( JukeBox.Lang:GetPhrase( "#PLAYLIST_AddAllSongs" ), "JukeBox.Font.20", w/2, h/2-2, Color( 255, 255, 255 ), 1, 1 )
		-- 		end
		-- 	else
		-- 		parent.Scroll.Issue = JukeBox.Lang:GetPhrase( "#PLAYLIST_InvalidID" )
		-- 	end
		-- end,
		-- function( issue )
		-- 	if not ValidPanel( parent.Scroll ) then return end
		-- 	parent.Scroll.Loading = false
		-- 	parent.Scroll.Issue = JukeBox.Lang:GetPhrase( "#PLAYLIST_UnexpectedErr" )
		-- end
		-- )
	end

	parent.Scroll.AddVideoCard = function( parent, info )
		local split = string.Explode( " - ", info.title )
		local data = {}
		if #split == 2 then
			data = {
				name = split[2],
				artist = split[1],
				id = info.id,
				length = info.length,
			}
		else
			data = {
				name = info.title,
				artist = info.title,
				id = info.id,
				length = info.length,
			}
		end

		local card = vgui.Create( "DPanel", parent )
		card:SetTall( 40 )
		card:Dock( TOP )
		card:DockMargin( 15, 0, 20, 0 )
		card.Chosen = false
		card.Details = data
		function card:SetChosen( bool )
			card.Chosen = bool
		end
		card.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
			elseif self.Chosen then
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 5 ) )
			end
			draw.SimpleText( JukeBox:MinWord( data.name, "JukeBox.Font.20", w-10-(w-(w/2.5))-20 ), "JukeBox.Font.20", 10, h/2, Color( 255, 255, 255 ), 0, 1 )
			draw.SimpleText( JukeBox:MinWord( data.artist, "JukeBox.Font.20", w-10-(w/2.5)-(w-(w*0.75))-20 ), "JukeBox.Font.20", w/2.5, h/2, Color( 255, 255, 255 ), 0, 1 )
			local time =  string.FormattedTime( data.length )
			draw.SimpleText( time.h!=0 and Format("%02i:%02i:%02i", time.h, time.m, time.s) or Format("%02i:%02i", time.m, time.s), "JukeBox.Font.20", w*0.75, h/2, Color( 255, 255, 255 ), 1, 1 )
			draw.SimpleText( data.id, "JukeBox.Font.20", w-10, h/2, Color( 255, 255, 255 ), 2, 1 )
			draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Base )
		end

		parent:AddItem( card )

	end
end

function JukeBox.VGUI.Pages.AddPlaylist:AddAllSongs( panels )
	net.Start("JukeBox_PlaylistSongState")
	net.WriteBool(true)
	net.SendToServer()
	for k, v in pairs(panels) do
		local data = v.Details
		JukeBox:AceptPlaylistSong( data )
	end
	net.Start("JukeBox_PlaylistSongState")
	net.WriteBool(false)
	net.SendToServer()
end

if not JukeBox.Settings.DisableAddPlaylistTab then
	JukeBox.VGUI:RegisterPage( "ADMIN", "AddPlaylist", "Add Playlist", "jukebox/admin.png", function( parent ) JukeBox.VGUI.Pages.AddPlaylist:CreatePanel( parent ) end, true )
end
