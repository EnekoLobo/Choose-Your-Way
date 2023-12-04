JukeBox.VGUI.Pages.Options = {}

function JukeBox.VGUI.Pages.Options:CreatePanel( parent )
	parent.Scroll = vgui.Create( "DScrollPanel", parent )
	parent.Scroll:Dock( FILL )
	parent.Scroll.pnlCanvas:DockPadding( 100, 30, 100, 30 )
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
	
	parent.ChatLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.ChatLabel:SetText( JukeBox.Lang:GetPhrase( "#OPTIONS_ChatMessages" ) )
	parent.ChatLabel:SetFont( "JukeBox.Font.18" )
	parent.ChatLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.ChatLabel:SetTall( 24 )
	parent.ChatLabel:Dock( TOP )
	parent.ChatLabel:DockMargin( 0, 0, 0, 10 )
	parent.ChatLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.StartSong = vgui.Create( "DPanel", parent.Scroll )
	parent.StartSong:Dock( TOP )
	parent.StartSong:DockPadding( 0, 3, 0, 3 )
	parent.StartSong:DockMargin( 0, 0, 0, 0 )
	parent.StartSong:SetTall( 30 )
	parent.StartSong.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_SongStart" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	parent.StartSongButton = vgui.Create( "DButton", parent.StartSong )
	parent.StartSongButton:Dock( LEFT )
	parent.StartSongButton:SetWide( 70 )
	parent.StartSongButton:SetTall( 24 )
	parent.StartSongButton.Enabled = tobool( JukeBox:GetCookie( "JukeBox_ChatStartSong" ) )
	parent.StartSongButton:SetText( "" )
	parent.StartSongButton.DoClick = function( self )
		self.Enabled = !self.Enabled
		JukeBox:SetCookie( "JukeBox_ChatStartSong", tostring(self.Enabled) )
	end
	parent.StartSongButton.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enabled" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enable" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	parent.SkipSong = vgui.Create( "DPanel", parent.Scroll )
	parent.SkipSong:Dock( TOP )
	parent.SkipSong:DockPadding( 0, 3, 0, 3 )
	parent.SkipSong:DockMargin( 0, 0, 0, 0 )
	parent.SkipSong:SetTall( 30 )
	parent.SkipSong.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_SongSkipped" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	parent.SkipSongButton = vgui.Create( "DButton", parent.SkipSong )
	parent.SkipSongButton:Dock( LEFT )
	parent.SkipSongButton:SetWide( 70 )
	parent.SkipSongButton:SetTall( 24 )
	parent.SkipSongButton.Enabled = tobool( JukeBox:GetCookie( "JukeBox_ChatSkipSong" ) )
	parent.SkipSongButton:SetText( "" )
	parent.SkipSongButton.DoClick = function( self )
		self.Enabled = !self.Enabled
		JukeBox:SetCookie( "JukeBox_ChatSkipSong", tostring(self.Enabled) )
	end
	parent.SkipSongButton.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enabled" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enable" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	parent.VoteSkipSong = vgui.Create( "DPanel", parent.Scroll )
	parent.VoteSkipSong:Dock( TOP )
	parent.VoteSkipSong:DockPadding( 0, 3, 0, 3 )
	parent.VoteSkipSong:DockMargin( 0, 0, 0, 0 )
	parent.VoteSkipSong:SetTall( 30 )
	parent.VoteSkipSong.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_SongVoteSkip" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	parent.VoteSkipSongButton = vgui.Create( "DButton", parent.VoteSkipSong )
	parent.VoteSkipSongButton:Dock( LEFT )
	parent.VoteSkipSongButton:SetWide( 70 )
	parent.VoteSkipSongButton:SetTall( 24 )
	parent.VoteSkipSongButton.Enabled = tobool( JukeBox:GetCookie( "JukeBox_ChatVoteSkip" ) )
	parent.VoteSkipSongButton:SetText( "" )
	parent.VoteSkipSongButton.DoClick = function( self )
		self.Enabled = !self.Enabled
		JukeBox:SetCookie( "JukeBox_ChatVoteSkip", tostring(self.Enabled) )
	end
	parent.VoteSkipSongButton.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enabled" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enable" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	parent.QueueSong = vgui.Create( "DPanel", parent.Scroll )
	parent.QueueSong:Dock( TOP )
	parent.QueueSong:DockPadding( 0, 3, 0, 3 )
	parent.QueueSong:DockMargin( 0, 0, 0, 0 )
	parent.QueueSong:SetTall( 30 )
	parent.QueueSong.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_SongQueued" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	parent.QueueSongButton = vgui.Create( "DButton", parent.QueueSong )
	parent.QueueSongButton:Dock( LEFT )
	parent.QueueSongButton:SetWide( 70 )
	parent.QueueSongButton:SetTall( 24 )
	parent.QueueSongButton.Enabled = tobool( JukeBox:GetCookie( "JukeBox_ChatQueueSong" ) )
	parent.QueueSongButton:SetText( "" )
	parent.QueueSongButton.DoClick = function( self )
		self.Enabled = !self.Enabled
		JukeBox:SetCookie( "JukeBox_ChatQueueSong", tostring(self.Enabled) )
	end
	parent.QueueSongButton.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enabled" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enable" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	if JukeBox:IsManager( LocalPlayer() ) then
		parent.AdminRequestAdded = vgui.Create( "DPanel", parent.Scroll )
		parent.AdminRequestAdded:Dock( TOP )
		parent.AdminRequestAdded:DockPadding( 0, 3, 0, 3 )
		parent.AdminRequestAdded:DockMargin( 0, 0, 0, 0 )
		parent.AdminRequestAdded:SetTall( 30 )
		parent.AdminRequestAdded.Paint = function( self, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_NewRequest" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
		end
		
		parent.AdminRequestAddedButton = vgui.Create( "DButton", parent.AdminRequestAdded )
		parent.AdminRequestAddedButton:Dock( LEFT )
		parent.AdminRequestAddedButton:SetWide( 70 )
		parent.AdminRequestAddedButton:SetTall( 24 )
		parent.AdminRequestAddedButton.Enabled = tobool( JukeBox:GetCookie( "JukeBox_ChatAdminRequest" ) )
		parent.AdminRequestAddedButton:SetText( "" )
		parent.AdminRequestAddedButton.DoClick = function( self )
			self.Enabled = !self.Enabled
			JukeBox:SetCookie( "JukeBox_ChatAdminRequest", tostring(self.Enabled) )
		end
		parent.AdminRequestAddedButton.Paint = function( self, w, h )
			if self.Enabled then
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
			else
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
			end
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			end
			if self.Enabled then
				draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enabled" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
			else
				draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enable" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
			end
		end
	end
	
	parent.MenuLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.MenuLabel:SetText( JukeBox.Lang:GetPhrase( "#OPTIONS_UserInterface" ) )
	parent.MenuLabel:SetFont( "JukeBox.Font.18" )
	parent.MenuLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.MenuLabel:SetTall( 24 )
	parent.MenuLabel:Dock( TOP )
	parent.MenuLabel:DockMargin( 0, 10, 0, 10 )
	parent.MenuLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.MaxSongs = vgui.Create( "DPanel", parent.Scroll )
	parent.MaxSongs:Dock( TOP )
	parent.MaxSongs:DockPadding( 0, 3, 0, 3 )
	parent.MaxSongs:DockMargin( 0, 0, 0, 0 )
	parent.MaxSongs:SetTall( 30 )
	parent.MaxSongs.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_MaxListItems" ), "JukeBox.Font.16", 20, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	parent.MaxSongsNote = vgui.Create( "DPanel", parent.Scroll )
	parent.MaxSongsNote:Dock( TOP )
	parent.MaxSongsNote:DockMargin( 20, 0, 20, 10 )
	parent.MaxSongsNote:SetTall( 26 )
	parent.MaxSongsNote.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Information )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, JukeBox.Colours.Information )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 255, 255, 255, 10 ) )
		draw.RoundedBox( 0, 2, 2, w-4, h-4, JukeBox.Colours.Information )		
		
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 18, "jukebox/warning.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_MaxListNote" ), "JukeBox.Font.18", h, 5, Color( 255, 255, 255 ), 0, 0 )
	end
	
	parent.MaxSongsSlider = vgui.Create( "DSlider", parent.Scroll )
	parent.MaxSongsSlider:Dock( TOP )
	parent.MaxSongsSlider:DockMargin( 20, 0, 20, 0 )
	parent.MaxSongsSlider:SetTrapInside( false )
	parent.MaxSongsSlider:SetWide( 150 )
	parent.MaxSongsSlider:SetSlideX( JukeBox:GetCookie( "JukeBox_MaxSongs" )/1000 )
	parent.MaxSongsSlider.SlideValue = JukeBox:GetCookie( "JukeBox_MaxSongs" )/1000
	parent.MaxSongsSlider.Think = function( panel )
		if panel:GetSlideX() != panel.SlideValue then
			if panel.Disabled then
				panel:SetSlideX( panel.SlideValue )
			else
				JukeBox:SetCookie( "JukeBox_MaxSongs", math.Round(panel:GetSlideX()*1000) )
				panel.SlideValue = panel:GetSlideX()
			end
		end
	end
	parent.MaxSongsSlider.Paint = function( panel, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( panel ) or panel:GetDragging() then
			draw.RoundedBox( 4, 0, h/2-3, w, 7, JukeBox.Colours.Light )
			if panel:GetSlideX() != 0 then
				if panel.Disabled then
					draw.RoundedBox( 4, 0, h/2-3, w*panel:GetSlideX(), 7, Color( 220, 100, 100 ) )
				else
					draw.RoundedBox( 4, 0, h/2-3, w*panel:GetSlideX(), 7, Color( 200, 200, 200 ) )
				end
			end
		else
			draw.RoundedBox( 4, 0, h/2-2, w, 5, JukeBox.Colours.Light )
			if panel:GetSlideX() != 0 then
				if panel.Disabled then
					draw.RoundedBox( 4, 0, h/2-2, w*panel:GetSlideX(), 5, Color( 220, 100, 100 ) )
				else
					draw.RoundedBox( 4, 0, h/2-2, w*panel:GetSlideX(), 5, Color( 200, 200, 200 ) )
				end
			end
		end
	end
	parent.MaxSongsSlider.Knob.Paint = function( panel, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( panel:GetParent() ) or panel:GetParent():GetDragging() then
			if panel:GetParent().Disabled then
				draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 100, 100 ) )
			else
				draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 255, 255 ) )
			end
		end
	end
	
	parent.MaxSongsSliderValue = vgui.Create( "DPanel", parent.Scroll )
	parent.MaxSongsSliderValue:Dock( TOP )
	parent.MaxSongsSliderValue:SetTall( 20 )
	parent.MaxSongsSliderValue.Paint = function( self, w, h )
		local val = parent.MaxSongsSlider:GetSlideX()
		draw.SimpleText( val < 1 and math.Round( val*1000 ) or "∞", "JukeBox.Font.16", 20+(w-40)*val, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	parent.DebugLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.DebugLabel:SetText( JukeBox.Lang:GetPhrase( "#OPTIONS_Debug" ) )
	parent.DebugLabel:SetFont( "JukeBox.Font.18" )
	parent.DebugLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.DebugLabel:SetTall( 24 )
	parent.DebugLabel:Dock( TOP )
	parent.DebugLabel:DockMargin( 0, 10, 0, 10 )
	parent.DebugLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	--JukeBox_DebugPlayer
	parent.ShowVideoPlayer = vgui.Create( "DPanel", parent.Scroll )
	parent.ShowVideoPlayer:Dock( TOP )
	parent.ShowVideoPlayer:DockPadding( 0, 3, 0, 3 )
	parent.ShowVideoPlayer:DockMargin( 0, 0, 0, 0 )
	parent.ShowVideoPlayer:SetTall( 30 )
	parent.ShowVideoPlayer.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_VideoOnScreen" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	parent.ShowVideoPlayerButton = vgui.Create( "DButton", parent.ShowVideoPlayer )
	parent.ShowVideoPlayerButton:Dock( LEFT )
	parent.ShowVideoPlayerButton:SetWide( 70 )
	parent.ShowVideoPlayerButton:SetTall( 24 )
	if JukeBox.HTMLPlayer then
		parent.ShowVideoPlayerButton.Enabled = (ValidPanel(JukeBox.HTMLPlayer.Overlay) and true or false)
	else
		parent.ShowVideoPlayerButton.Enabled = false
	end
	parent.ShowVideoPlayerButton:SetText( "" )
	parent.ShowVideoPlayerButton.DoClick = function( self )
		self.Enabled = !self.Enabled
		if self.Enabled then
			if JukeBox.HTMLPlayer then
				JukeBox.HTMLPlayer:SetVisible( true )
				JukeBox.HTMLPlayer:SetPos( 0, 0 )
				JukeBox.HTMLPlayer:SetSize( 300, 200 )
				JukeBox.HTMLPlayer.Overlay = vgui.Create( "DPanel", JukeBox.HTMLPlayer )
				JukeBox.HTMLPlayer.Overlay:Dock( FILL )
				JukeBox.HTMLPlayer.Overlay.Paint = function( self, w, h ) end
				JukeBox.HTMLPlayer.Overlay.OnMousePressed = function( self )
					local x, y = self:GetParent():GetPos()
					if ( gui.MouseX() > x+self:GetWide()-20 ) and ( gui.MouseY() > y+self:GetTall()-20 ) then
						self.Scaling = { x, y }
						self:MouseCapture( true )
					else
						self.Dragging = { gui.MouseX() - x, gui.MouseY() - y }
						self:MouseCapture( true )
					end
				end
				JukeBox.HTMLPlayer.Overlay.OnMouseReleased = function( self )
					self.Dragging = nil
					self.Scaling = nil
					self:MouseCapture( false )
				end
				JukeBox.HTMLPlayer.Overlay.Think = function( self, w, h )
					local x, y = self:GetParent():GetPos()
					if ( gui.MouseX() > x+self:GetWide()-20 ) and ( gui.MouseY() > y+self:GetTall()-20 ) then
						self:SetCursor( "sizenwse" )
					else
						self:SetCursor( "sizeall" )
					end
					if self.Scaling then
						self:GetParent():SetSize( math.Clamp( gui.MouseX()-self.Scaling[1], 300, ScrW()-x ), math.Clamp( gui.MouseY()-self.Scaling[2], 200, ScrH()-y ) )
					end
					if self.Dragging then
						self:GetParent():SetPos( math.Clamp( gui.MouseX()-self.Dragging[1], 0, ScrW()-self:GetWide() ), math.Clamp( gui.MouseY()-self.Dragging[2], 0, ScrH()-self:GetTall() ) )
					end
				end
			end
		else
			if JukeBox.HTMLPlayer then
				JukeBox.HTMLPlayer:SetSize( 500, 500 )
				JukeBox.HTMLPlayer:SetVisible( false )
				if JukeBox.HTMLPlayer.Overlay then
					JukeBox.HTMLPlayer.Overlay:Remove()
				end
			end
		end
	end
	parent.ShowVideoPlayerButton.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enabled" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enable" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
    
    parent.ChromiumFix = vgui.Create( "DPanel", parent.Scroll )
	parent.ChromiumFix:Dock( TOP )
	parent.ChromiumFix:DockPadding( 0, 3, 0, 3 )
	parent.ChromiumFix:DockMargin( 0, 0, 0, 0 )
	parent.ChromiumFix:SetTall( 30 )
	parent.ChromiumFix.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#CHROMIUM_OptionsText" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	parent.ChromiumFixButton = vgui.Create( "DButton", parent.ChromiumFix )
	parent.ChromiumFixButton:Dock( LEFT )
	parent.ChromiumFixButton:SetWide( 70 )
	parent.ChromiumFixButton:SetTall( 24 )
	parent.ChromiumFixButton.Enabled = tobool( JukeBox:GetCookie( "JukeBox_ChromiumPopupOff" ) )
	parent.ChromiumFixButton:SetText( "" )
	parent.ChromiumFixButton.DoClick = function( self )
		self.Enabled = !self.Enabled
		JukeBox:SetCookie( "JukeBox_ChromiumPopupOff", tostring(self.Enabled) )
	end
	parent.ChromiumFixButton.Paint = function( self, w, h )
		if self.Enabled then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.Enabled then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enabled" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_Enable" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		end
	end
    
    parent.ChromiumPopupButton = vgui.Create( "DButton", parent.Scroll )
	parent.ChromiumPopupButton:Dock( TOP )
	parent.ChromiumPopupButton:SetWide( 200 )
	parent.ChromiumPopupButton:SetTall( 40 )
	parent.ChromiumPopupButton:DockMargin( 0, 3, 0, 10 )
	parent.ChromiumPopupButton:SetText( "" )
	parent.ChromiumPopupButton.DoClick = function()
		JukeBox.VGUI:CreateChromiumPopup()
	end
	parent.ChromiumPopupButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#CHROMIUM_OptionsButton" ), "JukeBox.Font.20", w/2, h/2-2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	parent.PlaybackLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.PlaybackLabel:SetText( JukeBox.Lang:GetPhrase( "#OPTIONS_Quality" ) )
	parent.PlaybackLabel:SetFont( "JukeBox.Font.18" )
	parent.PlaybackLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.PlaybackLabel:SetTall( 24 )
	parent.PlaybackLabel:Dock( TOP )
	parent.PlaybackLabel:DockMargin( 0, 10, 0, 10 )
	parent.PlaybackLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.PlaybackDropdown = vgui.Create( "DComboBox", parent.Scroll )
	parent.PlaybackDropdown:Dock( TOP )
	parent.PlaybackDropdown:SetTall( 32 )
	parent.PlaybackDropdown:DockMargin( 0, 0, 0, 10 )
	local qualities = {
		["1. 240p"]	=	"small",
		["2. 360p"]	=	"medium",
		["3. 480p"]	= 	"large",
		["4. 720p"]	=	"hd720",
		["5. 1080p"]	= 	"hd1080",
		["6. 4Kp"]		= 	"highres",
	}
	parent.PlaybackDropdown:SetValue( table.KeyFromValue( qualities, JukeBox.Quality ) )
	for k, v in pairs( qualities ) do
		parent.PlaybackDropdown:AddChoice( k )
	end
	parent.PlaybackDropdown.OnSelect = function( panel, index, value )
		JukeBox.Quality = qualities[value]
		JukeBox:SetCookie( "JukeBox_VideoQuality", JukeBox.Quality )
	end
	
	parent.LanguageLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.LanguageLabel:SetText( JukeBox.Lang:GetPhrase( "#OPTIONS_Language" ) )
	parent.LanguageLabel:SetFont( "JukeBox.Font.18" )
	parent.LanguageLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.LanguageLabel:SetTall( 24 )
	parent.LanguageLabel:Dock( TOP )
	parent.LanguageLabel:DockMargin( 0, 10, 0, 10 )
	parent.LanguageLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.Note = vgui.Create( "DPanel", parent.Scroll )
	parent.Note:Dock( TOP )
	parent.Note:DockMargin( 0, 0, 0, 0 )
	parent.Note:SetTall( 44 )
	parent.Note.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Information )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, JukeBox.Colours.Information )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 255, 255, 255, 10 ) )
		draw.RoundedBox( 0, 2, 2, w-4, h-4, JukeBox.Colours.Information )		
		
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 18, "jukebox/warning.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_NoticeL1" ), "JukeBox.Font.18", h, 5, Color( 255, 255, 255 ), 0, 0 )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_NoticeL2" ), "JukeBox.Font.18", h, 22, Color( 255, 255, 255 ), 0, 0 )
	end
	
	parent.LanguageDropdown = vgui.Create( "DComboBox", parent.Scroll )
	parent.LanguageDropdown:Dock( TOP )
	parent.LanguageDropdown:SetTall( 32 )
	parent.LanguageDropdown:DockMargin( 0, 10, 0, 10 )
	parent.LanguageDropdown:SetValue( JukeBox.Lang.Current )
	for k, v in pairs( JukeBox.Lang.Languages ) do
		parent.LanguageDropdown:AddChoice( k )
	end
	parent.LanguageDropdown.OnSelect = function( panel, index, value )
		JukeBox.Lang.Current = value
		JukeBox.VGUI.Menu:Close()
		JukeBox.VGUI.OpenWindow()
	end

	-- New about section to comply with YouTube API T&Cs.
	parent.AboutLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.AboutLabel:SetText( JukeBox.Lang:GetPhrase( "#OPTIONS_About" ) )
	parent.AboutLabel:SetFont( "JukeBox.Font.18" )
	parent.AboutLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.AboutLabel:SetTall( 24 )
	parent.AboutLabel:Dock( TOP )
	parent.AboutLabel:DockMargin( 0, 10, 0, 10 )
	parent.AboutLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end

	parent.AboutText = vgui.Create( "DPanel", parent.Scroll )
	parent.AboutText:Dock( TOP )
	parent.AboutText:DockPadding( 0, 3, 0, 3 )
	parent.AboutText:DockMargin( 0, 0, 0, 0 )
	parent.AboutText:SetTall( 18 )
	parent.AboutText.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_AboutText1" ), "JukeBox.Font.16", 20, h/2, Color( 255, 255, 255 ), 0, 1 )
	end

	parent.AboutText2 = vgui.Create( "DPanel", parent.Scroll )
	parent.AboutText2:Dock( TOP )
	parent.AboutText2:DockPadding( 0, 3, 0, 3 )
	parent.AboutText2:DockMargin( 0, 0, 0, 0 )
	parent.AboutText2:SetTall( 18 )
	parent.AboutText2.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_AboutText2" ), "JukeBox.Font.16", 20, h/2, Color( 255, 255, 255 ), 0, 1 )
	end

	parent.AboutText3 = vgui.Create( "DPanel", parent.Scroll )
	parent.AboutText3:Dock( TOP )
	parent.AboutText3:DockPadding( 0, 3, 0, 3 )
	parent.AboutText3:DockMargin( 0, 0, 0, 0 )
	parent.AboutText3:SetTall( 18 )
	parent.AboutText3.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_AboutText3" ), "JukeBox.Font.16", 20, h/2, Color( 255, 255, 255 ), 0, 1 )
	end

	parent.AboutYouTubeTOS = vgui.Create( "DButton", parent.Scroll )
	parent.AboutYouTubeTOS:Dock( TOP )
	parent.AboutYouTubeTOS:DockMargin( 0, 3, 0, 3 )
	parent.AboutYouTubeTOS:SetWide( 70 )
	parent.AboutYouTubeTOS:SetTall( 24 )
	parent.AboutYouTubeTOS:SetText( "" )
	parent.AboutYouTubeTOS.DoClick = function( self )
		gui.OpenURL("https://www.youtube.com/t/terms")
	end
	parent.AboutYouTubeTOS.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_YouTubeTos" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end

	parent.AboutGooglePP = vgui.Create( "DButton", parent.Scroll )
	parent.AboutGooglePP:Dock( TOP )
	parent.AboutGooglePP:DockMargin( 0, 3, 0, 3 )
	parent.AboutGooglePP:SetWide( 70 )
	parent.AboutGooglePP:SetTall( 24 )
	parent.AboutGooglePP:SetText( "" )
	parent.AboutGooglePP.DoClick = function( self )
		gui.OpenURL("http://www.google.com/policies/privacy")
	end
	parent.AboutGooglePP.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#OPTIONS_GooglePrivacy" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
end

JukeBox.VGUI:RegisterPage( "#TAB_User", "Options", "#TAB_Options", "jukebox/options.png", function( parent ) JukeBox.VGUI.Pages.Options:CreatePanel( parent ) end )

-- Sorry, as the options page is currently empty, I left it off the main VGUI
-- When there are more options available, I'll enable this