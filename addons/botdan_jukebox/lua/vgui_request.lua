JukeBox.VGUI.Pages.Request = {}

function JukeBox.VGUI.Pages.Request:CreatePanel( parent )
	--parent:DockPadding( 100, 30, 100, 0 )
	
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
	
	parent.NameLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.NameLabel:SetText( JukeBox.Lang:GetPhrase( "#HEADING_Song" )..":" )
	parent.NameLabel:SetFont( "JukeBox.Font.18" )
	parent.NameLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.NameLabel:SetTall( 24 )
	parent.NameLabel:Dock( TOP )
	parent.NameLabel:DockMargin( 0, 0, 0, 10 )
	parent.NameLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.NamePanel = vgui.Create( "DPanel", parent.Scroll )
	parent.NamePanel:Dock( TOP )
	parent.NamePanel:DockPadding( 12, 0, 12, 0 )
	parent.NamePanel.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 255, 255 ) )
	end
	
	parent.NameEntry = vgui.Create( "DTextEntry", parent.NamePanel )
	parent.NameEntry:Dock( FILL )
	parent.NameEntry.Val = ""
	parent.NameEntry.Error1 = true
	parent.NameEntry:SetFont( "JukeBox.Font.16" )
	parent.NameEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnChange( self )
		end
	end
	parent.NameEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.NameEntry.OnChange = function( self )
		self.Val = self:GetValue()
		if self:GetValue() != "" then
			self.Error1 = false
			parent.NameError1:SetTextColor( JukeBox.Colours.Light )
		else
			self.Error1 = true
			parent.NameError1:SetTextColor( Color( 192, 57, 43 ) )
		end
	end
	
	parent.NameError1 = vgui.Create( "DLabel", parent.Scroll )
	parent.NameError1:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_FieldBlank" ) )
	parent.NameError1:SetFont( "JukeBox.Font.16" )
	parent.NameError1:SetTextColor( Color( 192, 57, 43 ) )
	parent.NameError1:SizeToContents()
	parent.NameError1:Dock( TOP )
	parent.NameError1:DockMargin( 10, 10, 10, 0 )
	
	
	parent.ArtistLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.ArtistLabel:SetText( JukeBox.Lang:GetPhrase( "#HEADING_Artist" )..":" )
	parent.ArtistLabel:SetFont( "JukeBox.Font.18" )
	parent.ArtistLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.ArtistLabel:SetTall( 24 )
	parent.ArtistLabel:Dock( TOP )
	parent.ArtistLabel:DockMargin( 0, 20, 0, 10 )
	parent.ArtistLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.ArtistPanel = vgui.Create( "DPanel", parent.Scroll )
	parent.ArtistPanel:Dock( TOP )
	parent.ArtistPanel:DockPadding( 12, 0, 12, 0 )
	parent.ArtistPanel.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 255, 255 ) )
	end
	
	parent.ArtistEntry = vgui.Create( "DTextEntry", parent.ArtistPanel )
	parent.ArtistEntry:Dock( FILL )
	parent.ArtistEntry.Val = ""
	parent.ArtistEntry.Error1 = true
	parent.ArtistEntry:SetFont( "JukeBox.Font.16" )
	parent.ArtistEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnChange( self )
		end
	end
	parent.ArtistEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.ArtistEntry.OnChange = function( self )
		self.Val = self:GetValue()
		if self:GetValue() != "" then
			self.Error1 = false
			parent.ArtistError1:SetTextColor( JukeBox.Colours.Light )
		else
			self.Error1 = true
			parent.ArtistError1:SetTextColor( Color( 192, 57, 43 ) )
		end
	end
	
	parent.ArtistError1 = vgui.Create( "DLabel", parent.Scroll )
	parent.ArtistError1:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_FieldBlank" ) )
	parent.ArtistError1:SetFont( "JukeBox.Font.16" )
	parent.ArtistError1:SetTextColor( Color( 192, 57, 43 ) )
	parent.ArtistError1:SizeToContents()
	parent.ArtistError1:Dock( TOP )
	parent.ArtistError1:DockMargin( 10, 10, 10, 0 )
	
	
	parent.URLLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.URLLabel:SetText( JukeBox.Lang:GetPhrase( "#MANUAL_YouTubeURL" )..":" )
	parent.URLLabel:SetFont( "JukeBox.Font.18" )
	parent.URLLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.URLLabel:SetTall( 24 )
	parent.URLLabel:Dock( TOP )
	parent.URLLabel:DockMargin( 0, 20, 0, 10 )
	parent.URLLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.URLPanel = vgui.Create( "DPanel", parent.Scroll )
	parent.URLPanel:Dock( TOP )
	parent.URLPanel:DockPadding( 12, 0, 12, 0 )
	parent.URLPanel.Paint = function( self, w, h )
		draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 255, 255 ) )
	end
	
	parent.URLEntry = vgui.Create( "DTextEntry", parent.URLPanel )
	parent.URLEntry:Dock( FILL )
	parent.URLEntry.Val = ""
	parent.URLEntry.Error1 = true
	parent.URLEntry.Error2 = true
	parent.URLEntry.URLID = nil
	parent.URLEntry:SetFont( "JukeBox.Font.18" )
	parent.URLEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnChange( self )
		end
	end
	parent.URLEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		if not self.Error1 and not self.Error2 and self.URLID then
			surface.SetFont( "JukeBox.Font.18" )
			local beg, en = string.find( self:GetValue(), self.URLID, 0, true )
			local subw, subh = surface.GetTextSize( string.sub( self:GetValue(), 1, beg-1 ) )
			local idw, idh = surface.GetTextSize( string.sub( self:GetValue(), beg, en ) )
			draw.RoundedBox( 4, subw+1, 2, idw+4, h-4, JukeBox.Colours.Accept )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.URLEntry.OnChange = function( self )
		self.Val = self:GetValue()
		if self:GetValue() and self:GetValue() != "" then
			self.Error1 = false
			parent.URLError1:SetTextColor( JukeBox.Colours.Light )
			local url = string.Explode( "/", self:GetValue() )
			for k, v in pairs( url ) do
				if (string.sub( v, 1, 8 ) == "watch?v=") then
					local id = string.sub( v, 9, 19 )
					if (string.len( id ) == 11) then
						self.URLID = id
						self.Error2 = false
						parent.URLError2:SetTextColor( JukeBox.Colours.Light )
						return
					else
						self.URLID = nil
						self.Error2 = true
						parent.URLError2:SetTextColor( Color( 192, 57, 43 ) )
					end
				else
					self.URLID = nil
					self.Error2 = true
					parent.URLError2:SetTextColor( Color( 192, 57, 43 ) )
				end
			end
		else
			self.URLID = nil
			self.Error1 = true
			self.Error2 = true
			parent.URLError1:SetTextColor( Color( 192, 57, 43 ) )
			parent.URLError2:SetTextColor( Color( 192, 57, 43 ) )
		end
	end
	
	parent.URLError1 = vgui.Create( "DLabel", parent.Scroll )
	parent.URLError1:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_FieldBlank" ) )
	parent.URLError1:SetFont( "JukeBox.Font.16" )
	parent.URLError1:SetTextColor( Color( 192, 57, 43 ) )
	parent.URLError1:SizeToContents()
	parent.URLError1:Dock( TOP )
	parent.URLError1:DockMargin( 10, 10, 10, 0 )
	
	parent.URLError2 = vgui.Create( "DLabel", parent.Scroll )
	parent.URLError2:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_FieldValidURL" ) )
	parent.URLError2:SetFont( "JukeBox.Font.16" )
	parent.URLError2:SetTextColor( Color( 192, 57, 43 ) )
	parent.URLError2:SizeToContents()
	parent.URLError2:Dock( TOP )
	parent.URLError2:DockMargin( 10, 5, 10, 0 )
	
	parent.TimeLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.TimeLabel:SetText( JukeBox.Lang:GetPhrase( "#HEADING_Length" )..":" )
	parent.TimeLabel:SetFont( "JukeBox.Font.18" )
	parent.TimeLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.TimeLabel:SetTall( 24 )
	parent.TimeLabel:Dock( TOP )
	parent.TimeLabel:DockMargin( 0, 20, 0, 10 )
	parent.TimeLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.TimePanel = vgui.Create( "DPanel", parent.Scroll )
	parent.TimePanel:Dock( TOP )
	parent.TimePanel:SetTall( 36 )
	parent.TimePanel:DockPadding( 12, 0, 12, 0 )
	parent.TimePanel.Paint = function( self, w, h )
		--draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 0, 255 ) )
	end
	
	parent.TimeMinsPanel = vgui.Create( "DPanel", parent.TimePanel )
	parent.TimeMinsPanel:Dock( LEFT )
	parent.TimeMinsPanel:DockPadding( 12, 0, 12, 12)
	parent.TimeMinsPanel:DockMargin( 0, 0, 12, 0 )
	parent.TimeMinsPanel.Paint = function( self, w, h )
		draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#MANUAL_Mins" ), "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	parent.TimeMinsEntry = vgui.Create( "DNumberWang", parent.TimeMinsPanel )
	parent.TimeMinsEntry:Dock( FILL )
	parent.TimeMinsEntry:SetFont( "JukeBox.Font.18" )
	parent.TimeMinsEntry:SetMin( 0 )
	parent.TimeMinsEntry:SetMax( math.floor(JukeBox.Settings.MaxSongLength/60) )
	parent.TimeMinsEntry.Val = 0
	parent.TimeMinsEntry.Issue1 = true
	parent.TimeMinsEntry.Issue2 = false
	parent.TimeMinsEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.TimeMinsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	parent.TimeMinsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		parent.TimePanel.Checks()
		parent.StartTimePanel.Checks()
		parent.EndTimePanel.Checks()
	end
	
	parent.TimeSecsPanel = vgui.Create( "DPanel", parent.TimePanel )
	parent.TimeSecsPanel:Dock( LEFT )
	parent.TimeSecsPanel:DockPadding( 12, 0, 12, 12)
	parent.TimeSecsPanel.Paint = function( self, w, h )
		draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#MANUAL_Secs" ), "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	parent.TimeSecsEntry = vgui.Create( "DNumberWang", parent.TimeSecsPanel )
	parent.TimeSecsEntry:Dock( FILL )
	parent.TimeSecsEntry:SetFont( "JukeBox.Font.18" )
	parent.TimeSecsEntry:SetMin( 0 )
	parent.TimeSecsEntry:SetMax( 59 )
	parent.TimeSecsEntry.Val = 0
	parent.TimeSecsEntry.Issue1 = true
	parent.TimeSecsEntry.Issue2 = false
	parent.TimeSecsEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.TimeSecsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	parent.TimeSecsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		parent.TimePanel.Checks()
		parent.StartTimePanel.Checks()
		parent.EndTimePanel.Checks()
	end
	
	function parent.TimePanel.Checks()
		if parent.TimeSecsEntry:GetValue()+parent.TimeMinsEntry:GetValue()*60 > 0 then
			parent.TimeSecsEntry.Issue1 = false
			parent.TimeMinsEntry.Issue1  = false
			parent.TimeError1:SetTextColor( JukeBox.Colours.Light )
		else
			parent.TimeSecsEntry.Issue1 = true
			parent.TimeMinsEntry.Issue1  = true
			parent.TimeError1:SetTextColor( Color( 192, 57, 43 ) )
		end
		if parent.TimeSecsEntry:GetValue()+parent.TimeMinsEntry:GetValue()*60 > JukeBox.Settings.MaxSongLength then
			parent.TimeSecsEntry.Issue2 = true
			parent.TimeMinsEntry.Issue2 = true
			parent.TimeError2:SetTextColor( Color( 192, 57, 43 ) )
		else
			parent.TimeSecsEntry.Issue2 = false
			parent.TimeMinsEntry.Issue2 = false
			parent.TimeError2:SetTextColor( JukeBox.Colours.Light )
		end
	end

	parent.TimeAutoGet = vgui.Create( "DButton", parent.TimePanel )
	parent.TimeAutoGet:Dock( LEFT )
	parent.TimeAutoGet:SetWide( 120 )
	parent.TimeAutoGet:SetTall( 24 )
	parent.TimeAutoGet.State = 0
	parent.TimeAutoGet:DockMargin( 20, 0, 0, 12 )
	parent.TimeAutoGet:SetText( "" )
	parent.TimeAutoGet.DoClick = function( self )
		if not parent.URLEntry.URLID then
			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_NoURL" ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
			return
		end
		if parent.TimeAutoGet.State == 0 then
			parent.TimeAutoGet.State = 1
			JukeBox:Fetch({request = "length", id = parent.URLEntry.URLID},
				function(data)
					if !IsValid( parent ) or !ValidPanel( parent ) then return end
					if (!data.exists) then
						JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_InvalidURL" ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
						parent.TimeAutoGet.State = 0
						return
					end
					local time = data.duration
					local mins = math.floor( time/60 )
					if time > JukeBox.Settings.MaxSongLength then
						JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_SongTooLong", JukeBox.Settings.MaxSongLength ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
					end
					local secs = time-(mins*60)
					parent.TimeMinsEntry:SetValue( mins )
					parent.TimeSecsEntry:SetValue( secs )
					parent.TimeAutoGet.State = 0
				end,
				function()
					if !IsValid( parent ) or !ValidPanel( parent ) then return end
					JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#WEB_IssueGeneric" ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
					parent.TimeAutoGet.State = 0
				end
			)
			-- REPLACED HTTP CODE WITH LOCAL FETCH REQUEST TO SERVER
			--
			-- http.Fetch( JukeBox.Settings.CheckerURL..parent.URLEntry.URLID, 
			-- 	function( body )
			-- 		local info = util.JSONToTable( body )
			-- 		if not info then
			-- 			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_InvalidURL" ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
			-- 		elseif info.videoExists then
			-- 			local time = info.videoLength
			-- 			local mins = math.floor( time/60 )
			-- 			if time > JukeBox.Settings.MaxSongLength then
			-- 				JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_SongTooLong", JukeBox.Settings.MaxSongLength ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
			-- 			end
			-- 			local secs = time-(mins*60)
			-- 			parent.TimeMinsEntry:SetValue( mins )
			-- 			parent.TimeSecsEntry:SetValue( secs )
			-- 		else
			-- 			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_InvalidURL" ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
			-- 		end
			-- 		parent.TimeAutoGet.State = 0
			-- 	end,
			-- 	function( issue )
			-- 		JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_ServerError" ), JukeBox.Colours.Warning, "jukebox/warning.png", "REQUEST", true )
			-- 	end )
		end
	end
	parent.TimeAutoGet.Paint = function( self, w, h )
		if not parent.URLEntry.URLID then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Accept )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		if self.State == 0 then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_GetVideoLength" ), "JukeBox.Font.16", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
		elseif self.State == 1 then
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 20, "jukebox/loading.png", Color( 255, 255, 255 ), -CurTime()*100 )
		end
	end
	
	parent.TimeError1 = vgui.Create( "DLabel", parent.Scroll )
	parent.TimeError1:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_LengthAbove0" ) )
	parent.TimeError1:SetFont( "JukeBox.Font.16" )
	parent.TimeError1:SetTextColor( Color( 192, 57, 43 ) )
	parent.TimeError1:SizeToContents()
	parent.TimeError1:Dock( TOP )
	parent.TimeError1:DockMargin( 10, 10, 10, 0 )
	
	parent.TimeError2 = vgui.Create( "DLabel", parent.Scroll )
	parent.TimeError2:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_LengthBelowX", JukeBox.Settings.MaxSongLength ) )
	parent.TimeError2:SetFont( "JukeBox.Font.16" )
	parent.TimeError2:SetTextColor( JukeBox.Colours.Light )
	parent.TimeError2:SizeToContents()
	parent.TimeError2:Dock( TOP )
	parent.TimeError2:DockMargin( 10, 10, 10, 0 )
	
	parent.SubmitButton1 = vgui.Create( "DButton", parent.Scroll )
	parent.SubmitButton1:Dock( TOP )
	parent.SubmitButton1:SetWide( 200 )
	parent.SubmitButton1:SetTall( 40 )
	parent.SubmitButton1:DockMargin( 0, 20, 0, 10 )
	parent.SubmitButton1:SetText( "" )
	parent.SubmitButton1.DoClick = function()
		JukeBox.VGUI.Pages.Request:CheckFields( parent )
	end
	parent.SubmitButton1.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_SendRequest" ), "JukeBox.Font.20", w/2, h/2-2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	parent.AdvancedLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.AdvancedLabel:SetText( JukeBox.Lang:GetPhrase( "#MANUAL_Advanced" ) )
	parent.AdvancedLabel:SetFont( "JukeBox.Font.24" )
	parent.AdvancedLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.AdvancedLabel:SetTall( 32 )
	parent.AdvancedLabel:Dock( TOP )
	parent.AdvancedLabel:DockMargin( 0, 20, 0, 0 )
	parent.AdvancedLabel.PaintOver = function( self, w, h )
		--draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.StartTimeLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.StartTimeLabel:SetText( JukeBox.Lang:GetPhrase( "#MANUAL_StartTime" )..":" )
	parent.StartTimeLabel:SetFont( "JukeBox.Font.18" )
	parent.StartTimeLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.StartTimeLabel:SetTall( 24 )
	parent.StartTimeLabel:Dock( TOP )
	parent.StartTimeLabel:DockMargin( 0, 0, 0, 10 )
	parent.StartTimeLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.StartTimePanel = vgui.Create( "DPanel", parent.Scroll )
	parent.StartTimePanel:Dock( TOP )
	parent.StartTimePanel:SetTall( 36 )
	parent.StartTimePanel:DockPadding( 12, 0, 12, 0 )
	parent.StartTimePanel.Paint = function( self, w, h )
		--draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 0, 255 ) )
	end
	
	parent.StartTimeMinsPanel = vgui.Create( "DPanel", parent.StartTimePanel )
	parent.StartTimeMinsPanel:Dock( LEFT )
	parent.StartTimeMinsPanel:DockPadding( 12, 0, 12, 12)
	parent.StartTimeMinsPanel:DockMargin( 0, 0, 12, 0 )
	parent.StartTimeMinsPanel.Paint = function( self, w, h )
		if parent.StartTimeMinsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#MANUAL_Mins" ), "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	parent.StartTimeMinsEntry = vgui.Create( "DNumberWang", parent.StartTimeMinsPanel )
	parent.StartTimeMinsEntry:Dock( FILL )
	parent.StartTimeMinsEntry:SetFont( "JukeBox.Font.18" )
	parent.StartTimeMinsEntry:SetMin( 0 )
	parent.StartTimeMinsEntry:SetMax( math.floor(JukeBox.Settings.MaxSongLength/60) )
	parent.StartTimeMinsEntry:SetDisabled( true )
	parent.StartTimeMinsEntry.Val = 0
	parent.StartTimeMinsEntry.Issue1 = true
	parent.StartTimeMinsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.StartTimeMinsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	parent.StartTimeMinsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		parent.StartTimePanel.Checks()
	end
	
	parent.StartTimeSecsPanel = vgui.Create( "DPanel", parent.StartTimePanel )
	parent.StartTimeSecsPanel:Dock( LEFT )
	parent.StartTimeSecsPanel:DockPadding( 12, 0, 12, 12)
	parent.StartTimeSecsPanel.Paint = function( self, w, h )
		if parent.StartTimeSecsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#MANUAL_Secs" ), "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	parent.StartTimeSecsEntry = vgui.Create( "DNumberWang", parent.StartTimeSecsPanel )
	parent.StartTimeSecsEntry:Dock( FILL )
	parent.StartTimeSecsEntry:SetFont( "JukeBox.Font.18" )
	parent.StartTimeSecsEntry:SetMin( 0 )
	parent.StartTimeSecsEntry:SetMax( 59 )
	parent.StartTimeSecsEntry:SetDisabled( true )
	parent.StartTimeSecsEntry.Val = 0
	parent.StartTimeSecsEntry.Issue1 = true
	parent.StartTimeSecsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.StartTimeSecsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	parent.StartTimeSecsEntry.OnValueChanged = function( self )
		self.Val = self:GetValue()
		parent.StartTimePanel.Checks()
	end
	
	function parent.StartTimePanel.Checks()
		if parent.StartTimeSecsEntry:GetValue()+parent.StartTimeMinsEntry:GetValue()*60 >= 0 then
			parent.StartTimeSecsEntry.Issue1 = false
			parent.StartTimeMinsEntry.Issue1  = false
			parent.StartTimeError1:SetTextColor( JukeBox.Colours.Light )
			if ( parent.StartTimeSecsEntry:GetValue()+parent.StartTimeMinsEntry:GetValue()*60 >= parent.TimeSecsEntry:GetValue()+parent.TimeMinsEntry:GetValue()*60 ) then
				parent.StartTimeSecsEntry.Issue2 = true
				parent.StartTimeMinsEntry.Issue2 = true
				parent.StartTimeError2:SetTextColor( Color( 192, 57, 43 ) )
			else
				parent.StartTimeSecsEntry.Issue2 = false
				parent.StartTimeMinsEntry.Issue2 = false
				parent.StartTimeError2:SetTextColor( JukeBox.Colours.Light )
			end
		else
			parent.StartTimeSecsEntry.Issue1 = true
			parent.StartTimeMinsEntry.Issue1  = true
			parent.StartTimeError1:SetTextColor( Color( 192, 57, 43 ) )
		end
	end
	
	parent.StartTimeEnable = vgui.Create( "DButton", parent.StartTimePanel )
	parent.StartTimeEnable:Dock( LEFT )
	parent.StartTimeEnable:SetWide( 70 )
	parent.StartTimeEnable:SetTall( 24 )
	parent.StartTimeEnable.Enabled = false
	parent.StartTimeEnable:DockMargin( 20, 0, 0, 12 )
	parent.StartTimeEnable:SetText( "" )
	parent.StartTimeEnable.DoClick = function( self )
		self.Enabled = !self.Enabled
		parent.StartTimeSecsEntry:SetDisabled( !self.Enabled )
		parent.StartTimeMinsEntry:SetDisabled( !self.Enabled )
	end
	parent.StartTimeEnable.Paint = function( self, w, h )
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
	
	parent.StartTimeError1 = vgui.Create( "DLabel", parent.Scroll )
	parent.StartTimeError1:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_StartNot0" ) )
	parent.StartTimeError1:SetFont( "JukeBox.Font.16" )
	parent.StartTimeError1:SetTextColor( JukeBox.Colours.Light )
	parent.StartTimeError1:SizeToContents()
	parent.StartTimeError1:Dock( TOP )
	parent.StartTimeError1:DockMargin( 10, 10, 10, 0 )
	
	parent.StartTimeError2 = vgui.Create( "DLabel", parent.Scroll )
	parent.StartTimeError2:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_StartNotLength" ) )
	parent.StartTimeError2:SetFont( "JukeBox.Font.16" )
	parent.StartTimeError2:SetTextColor( Color( 192, 57, 43 ) )
	parent.StartTimeError2:SizeToContents()
	parent.StartTimeError2:Dock( TOP )
	parent.StartTimeError2:DockMargin( 10, 5, 10, 0 )
	
	parent.EndTimeLabel = vgui.Create( "DLabel", parent.Scroll )
	parent.EndTimeLabel:SetText( JukeBox.Lang:GetPhrase( "#MANUAL_EndTime" )..":" )
	parent.EndTimeLabel:SetFont( "JukeBox.Font.18" )
	parent.EndTimeLabel:SetTextColor( Color( 255, 255, 255 ) )
	parent.EndTimeLabel:SetTall( 24 )
	parent.EndTimeLabel:Dock( TOP )
	parent.EndTimeLabel:DockMargin( 0, 20, 0, 10 )
	parent.EndTimeLabel.PaintOver = function( self, w, h )
		draw.RoundedBox( 0, 0, h-1, w, 1, JukeBox.Colours.Light )
	end
	
	parent.EndTimePanel = vgui.Create( "DPanel", parent.Scroll )
	parent.EndTimePanel:Dock( TOP )
	parent.EndTimePanel:SetTall( 36 )
	parent.EndTimePanel:DockPadding( 12, 0, 12, 0 )
	parent.EndTimePanel.Paint = function( self, w, h )
		--draw.RoundedBox( h/2, 0, 0, w, h, Color( 255, 0, 255 ) )
	end
	
	parent.EndTimeMinsPanel = vgui.Create( "DPanel", parent.EndTimePanel )
	parent.EndTimeMinsPanel:Dock( LEFT )
	parent.EndTimeMinsPanel:DockPadding( 12, 0, 12, 12)
	parent.EndTimeMinsPanel:DockMargin( 0, 0, 12, 0 )
	parent.EndTimeMinsPanel.Paint = function( self, w, h )
		if parent.EndTimeMinsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#MANUAL_Mins" ), "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	parent.EndTimeMinsEntry = vgui.Create( "DNumberWang", parent.EndTimeMinsPanel )
	parent.EndTimeMinsEntry:Dock( FILL )
	parent.EndTimeMinsEntry:SetFont( "JukeBox.Font.18" )
	parent.EndTimeMinsEntry:SetMin( 0 )
	parent.EndTimeMinsEntry:SetMax( math.floor(JukeBox.Settings.MaxSongLength/60) )
	parent.EndTimeMinsEntry:SetDisabled( true )
	parent.EndTimeMinsEntry.Val = 0
	parent.EndTimeMinsEntry.Override = false
	parent.EndTimeMinsEntry.Issue1 = true
	parent.EndTimeMinsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.EndTimeMinsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	parent.EndTimeMinsEntry.OnValueChanged = function( self )
		if self.Override then return end
		self.Val = self:GetValue()
		parent.EndTimePanel.Checks()
	end
	parent.EndTimeMinsEntry.ChangeValue = function( value )
		parent.EndTimeMinsEntry.Override = true
		parent.EndTimeMinsEntry:SetValue( value )
		parent.EndTimeMinsEntry.Override = false
	end
	
	parent.EndTimeSecsPanel = vgui.Create( "DPanel", parent.EndTimePanel )
	parent.EndTimeSecsPanel:Dock( LEFT )
	parent.EndTimeSecsPanel:DockPadding( 12, 0, 12, 12)
	parent.EndTimeSecsPanel.Paint = function( self, w, h )
		if parent.EndTimeSecsEntry:GetDisabled() then
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 24/2, 0, 0, w, 24, Color( 255, 255, 255 ) )
		end
		draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#MANUAL_Secs" ), "JukeBox.Font.12", w/2, h, Color( 200, 200, 200 ), 1, 4 )
	end
	
	parent.EndTimeSecsEntry = vgui.Create( "DNumberWang", parent.EndTimeSecsPanel )
	parent.EndTimeSecsEntry:Dock( FILL )
	parent.EndTimeSecsEntry:SetFont( "JukeBox.Font.18" )
	parent.EndTimeSecsEntry:SetMin( 0 )
	parent.EndTimeSecsEntry:SetMax( 59 )
	parent.EndTimeSecsEntry:SetDisabled( true )
	parent.EndTimeSecsEntry.Val = 0
	parent.EndTimeSecsEntry.Override = false
	parent.EndTimeSecsEntry.Issue1 = true
	parent.EndTimeSecsEntry.Paint = function( self, w, h )
		if self:GetDisabled() then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 100, 100 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		end
		self:DrawTextEntryText( JukeBox.Colours.Base, Color( 30, 130, 255 ), JukeBox.Colours.Base)
	end
	parent.EndTimeSecsEntry.Think = function( self )
		if self.Val != self:GetValue() then
			self:OnValueChanged( self )
		end
	end
	parent.EndTimeSecsEntry.OnValueChanged = function( self )
		if self.Override then return end
		self.Val = self:GetValue()
		parent.EndTimePanel.Checks()
	end
	parent.EndTimeSecsEntry.ChangeValue = function( value )
		parent.EndTimeSecsEntry.Override = true
		parent.EndTimeSecsEntry:SetValue( value )
		parent.EndTimeSecsEntry.Override = false
	end
	
	function parent.EndTimePanel.Checks()
		if not parent.EndTimeEnable.Enabled then
			parent.EndTimeSecsEntry.ChangeValue( parent.TimeSecsEntry:GetValue() )
			parent.EndTimeMinsEntry.ChangeValue( parent.TimeMinsEntry:GetValue() )
		end
		if parent.EndTimeSecsEntry:GetValue()+parent.EndTimeMinsEntry:GetValue()*60 > 0 then
			parent.EndTimeSecsEntry.Issue1 = false
			parent.EndTimeMinsEntry.Issue1  = false
			parent.EndTimeError1:SetTextColor( JukeBox.Colours.Light )
			if ( parent.EndTimeSecsEntry:GetValue()+parent.EndTimeMinsEntry:GetValue()*60 > parent.TimeSecsEntry:GetValue()+parent.TimeMinsEntry:GetValue()*60) then
				parent.EndTimeSecsEntry.Issue2 = true
				parent.EndTimeMinsEntry.Issue2 = true
				parent.EndTimeError2:SetTextColor( Color( 192, 57, 43 ) )
			else
				parent.EndTimeSecsEntry.Issue2 = false
				parent.EndTimeMinsEntry.Issue2 = false
				parent.EndTimeError2:SetTextColor( JukeBox.Colours.Light )
			end
		else
			parent.EndTimeSecsEntry.Issue1 = true
			parent.EndTimeMinsEntry.Issue1  = true
			parent.EndTimeError1:SetTextColor( Color( 192, 57, 43 ) )
		end

	end
	
	parent.EndTimeEnable = vgui.Create( "DButton", parent.EndTimePanel )
	parent.EndTimeEnable:Dock( LEFT )
	parent.EndTimeEnable:SetWide( 70 )
	parent.EndTimeEnable:SetTall( 24 )
	parent.EndTimeEnable.Enabled = false
	parent.EndTimeEnable:DockMargin( 20, 0, 0, 12 )
	parent.EndTimeEnable:SetText( "" )
	parent.EndTimeEnable.DoClick = function( self )
		self.Enabled = !self.Enabled
		parent.EndTimeMinsEntry:SetDisabled( !self.Enabled )
		parent.EndTimeSecsEntry:SetDisabled( !self.Enabled )
	end
	parent.EndTimeEnable.Paint = function( self, w, h )
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
	
	parent.EndTimeError1 = vgui.Create( "DLabel", parent.Scroll )
	parent.EndTimeError1:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_EndNot0" ) )
	parent.EndTimeError1:SetFont( "JukeBox.Font.16" )
	parent.EndTimeError1:SetTextColor( Color( 192, 57, 43 ) )
	parent.EndTimeError1:SizeToContents()
	parent.EndTimeError1:Dock( TOP )
	parent.EndTimeError1:DockMargin( 10, 10, 10, 0 )
	
	parent.EndTimeError2 = vgui.Create( "DLabel", parent.Scroll )
	parent.EndTimeError2:SetText( "- "..JukeBox.Lang:GetPhrase( "#MANUAL_EndNotLength" ) )
	parent.EndTimeError2:SetFont( "JukeBox.Font.16" )
	parent.EndTimeError2:SetTextColor( Color( 192, 57, 43 ) )
	parent.EndTimeError2:SizeToContents()
	parent.EndTimeError2:Dock( TOP )
	parent.EndTimeError2:DockMargin( 10, 5, 10, 0 )
	
end

function JukeBox.VGUI.Pages.Request:CheckFields( parent )
	local errors = {}
	if parent.NameEntry.Error1 then
		table.insert( errors, JukeBox.Lang:GetPhrase( "#HEADING_Song" ) )
	end
	if parent.ArtistEntry.Error1 then
		table.insert( errors, JukeBox.Lang:GetPhrase( "#HEADING_Artist" ) )
	end
	if parent.URLEntry.Error1 or parent.URLEntry.Error2 then
		table.insert( errors, JukeBox.Lang:GetPhrase( "#MANUAL_YouTubeURL" ) )
	end
	if parent.TimeMinsEntry.Issue1 or parent.TimeSecsEntry.Issue1 or parent.TimeMinsEntry.Issue2 or parent.TimeSecsEntry.Issue2 then
		table.insert( errors, JukeBox.Lang:GetPhrase( "#HEADING_Length" ) )
	end
	if (!parent.StartTimeMinsEntry:GetDisabled() or !parent.StartTimeSecsEntry:GetDisabled())  and (parent.StartTimeMinsEntry.Issue1 or parent.StartTimeSecsEntry.Issue1 or parent.StartTimeMinsEntry.Issue2 or parent.StartTimeSecsEntry.Issue2) then
		table.insert( errors, JukeBox.Lang:GetPhrase( "#MANUAL_StartTime" ) )
	end
	if (!parent.EndTimeMinsEntry:GetDisabled() or !parent.EndTimeSecsEntry:GetDisabled())  and (parent.EndTimeMinsEntry.Issue1 or parent.EndTimeSecsEntry.Issue1 or parent.EndTimeMinsEntry.Issue2 or parent.EndTimeSecsEntry.Issue2) then
		table.insert( errors, JukeBox.Lang:GetPhrase( "#MANUAL_EndTime" ) )
	end
	if table.Count( errors ) > 0 then
		local words = ""
		for k, v in pairs( errors ) do
			if k == 1 then
				words = words..v
			else
				words = words..", "..v
			end
		end
		JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_IssueWithFields", words ), JukeBox.Colours.Issue, "jukebox/warning.png", "REQUEST", true )
	else
		self:SubmitRequest( parent )
	end
end

function JukeBox.VGUI.Pages.Request:SubmitRequest( parent )
	local data = {}
	data.name = parent.NameEntry:GetValue()
	data.artist = parent.ArtistEntry:GetValue()
	data.id = parent.URLEntry.URLID
	data.length = parent.TimeMinsEntry:GetValue()*60+parent.TimeSecsEntry:GetValue()
	if !parent.StartTimeMinsEntry:GetDisabled() and !parent.StartTimeSecsEntry:GetDisabled() then
		data.starttime = parent.StartTimeMinsEntry:GetValue()*60+parent.StartTimeSecsEntry:GetValue()
	end
	if !parent.EndTimeMinsEntry:GetDisabled() and !parent.EndTimeSecsEntry:GetDisabled() then
		data.endtime = parent.EndTimeMinsEntry:GetValue()*60+parent.EndTimeSecsEntry:GetValue()
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
	popup:SetSize( 400, 200 )
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
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#HEADING_Name" ).." - "..JukeBox.Lang:GetPhrase( "#MANUAL_SendingRequest" ), "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	popup.TopBar.CloseButton = vgui.Create( "DButton", popup.TopBar )
	popup.TopBar.CloseButton:Dock( RIGHT )
	popup.TopBar.CloseButton:SetWide( 50 )
	popup.TopBar.CloseButton:SetText( "" )
	popup.TopBar.CloseButton.DoClick = function()
		JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_UserCancel" ), JukeBox.Colours.Warning, "jukebox/warning.png", "REQUEST", true )
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
	popup.Content:Dock( FILL )
	popup.Content.Progress = 1
	popup.Content.ProgressData = ""
	popup.Content.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		if self.Progress == 1 then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_CheckingURL" ), "JukeBox.Font.20", w/2, 15, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/loading.png", Color( 255, 255, 255 ), -CurTime()*100 )
		elseif self.Progress == 2 then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_VideoExists" ), "JukeBox.Font.20", w/2, 15, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
		elseif self.Progress == 3 then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_VideoNotExists" ), "JukeBox.Font.20", w/2, 15, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/cross.png", Color( 255, 255, 255 ), 0 )
		elseif self.Progress == 4 then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_ErrorWithServer" ), "JukeBox.Font.20", w/2, 15, Color( 255, 255, 255 ), 1, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2-10, 80, "jukebox/error.png", Color( 255, 255, 255 ), 0 )
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_ErrorList", self.ProgressData ), "JukeBox.Font.20", w/2, h-20, Color( 255, 255, 255 ), 1, 1 )
		end
	end
	
	popup.BottomButton = vgui.Create( "DButton", popup.Content )
	popup.BottomButton:SetSize( 100, 40 )
	popup.BottomButton:Dock( BOTTOM )
	popup.BottomButton:SetVisible( false )
	popup.BottomButton:DockMargin( 75, 5, 75, 10 )
	popup.BottomButton:SetText( "" )
	popup.BottomButton.Text = ""
	popup.BottomButton.SetSend = function()
		popup.BottomButton.Text = JukeBox.Lang:GetPhrase( "#MANUAL_SendRequest" )
		popup.BottomButton.DoClick = function()
			JukeBox:AddRequest( data )
			bg:Remove()
			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_RequestSent" ), JukeBox.Colours.Accept, "jukebox/tick.png", "REQUEST", true )
		end
		popup.BottomButton:SetVisible( true )
		if popup.BottomButton2 then
			popup.BottomButton2:SetVisible( true )
		end
	end
	popup.BottomButton.SetClose = function()
		popup.BottomButton.Text = JukeBox.Lang:GetPhrase( "#BUTTON_Close" )
		popup.BottomButton.DoClick = function()
			bg:Remove()
			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#MANUAL_RequestInvalid" ), JukeBox.Colours.Warning, "jukebox/warning.png", "REQUEST", true )
		end
		popup.BottomButton:SetVisible( true )
	end
	popup.BottomButton.DoClick = function()
		
	end
	popup.BottomButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
		else
			draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2-2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	if JukeBox:IsManager( LocalPlayer() ) then
		popup.BottomButton2 = vgui.Create( "DButton", popup.Content )
		popup.BottomButton2:SetSize( 140, 24 )
		popup.BottomButton2:Dock( BOTTOM )
		popup.BottomButton2:SetVisible( false )
		popup.BottomButton2:DockMargin( 60, 20, 60, 0 )
		popup.BottomButton2:SetText( "" )
		popup.BottomButton2.Text = JukeBox.Lang:GetPhrase( "#MANUAL_StraightToAll" )
		popup.BottomButton2.DoClick = function()
			JukeBox:AcceptRequest( data )
			bg:Remove()
		end
		popup.BottomButton2.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
			else
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
			end
			draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2-2, Color( 255, 255, 255 ), 1, 1 )
		end
		popup:SetTall( 250 )
	elseif JukeBox.Settings.RequestFasttrack then
		popup.BottomButton2 = vgui.Create( "DButton", popup.Content )
		popup.BottomButton2:SetSize( 140, 24 )
		popup.BottomButton2:Dock( BOTTOM )
		popup.BottomButton2:SetVisible( false )
		popup.BottomButton2:DockMargin( 75, 20, 75, 0 )
		popup.BottomButton2:SetText( "" )
		popup.BottomButton2.Text = JukeBox.Lang:GetPhrase( "#MANUAL_FastTrack" )
		popup.BottomButton2.DoClick = function()
			JukeBox.VGUI.Pages.Request:FasttrackPage( parent, data, bg )
		end
		popup.BottomButton2.Paint = function( self, w, h )
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Definition )
			else
				draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Light )
			end
			draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2-2, Color( 255, 255, 255 ), 1, 1 )
		end
		popup:SetTall( 250 )
	end

	JukeBox:Fetch({request = "length", id = data.id},
		function(dat)
			if !IsValid( bg ) or !ValidPanel( bg ) then return end
			if (!dat.exists) then
				popup.Content.Progress = 3
				popup.BottomButton:SetClose()
			else
				popup.Content.Progress = 2
				popup.BottomButton:SetSend()
			end
		end,
		function()
			if !IsValid( bg ) or !ValidPanel( bg ) then return end
			JukeBox.VGUI.VGUI:MakeNotification( JukeBox.Lang:GetPhrase( "#WEB_IssueGeneric" ), JukeBox.Colours.Issue, "jukebox/warning.png", "ALLSONGS", true )
			popup.Content.Progress = 4
			popup.BottomButton:SetSend()
		end
	)
	
	-- REPLACED HTTP CODE WITH LOCAL FETCH REQUEST TO SERVER
	--
	-- http.Fetch( JukeBox.Settings.CheckerURL..data.id, 
	-- 	function( body )
	-- 		if not ValidPanel( bg ) then return end
	-- 		local info = util.JSONToTable( body )
	-- 		if not info then
	-- 			popup.Content.Progress = 4
	-- 			popup.BottomButton:SetSend()
	-- 		elseif info.videoExists then
	-- 			popup.Content.Progress = 2
	-- 			popup.BottomButton:SetSend()
	-- 		else
	-- 			popup.Content.Progress = 3
	-- 			popup.BottomButton:SetClose()
	-- 		end
	-- 	end,
	-- 	function( issue )
	-- 		if not ValidPanel( bg ) then return end
	-- 		popup.Content.Progress = 4
	-- 		popup.BottomButton:SetClose()
	-- 	end )
end

function JukeBox.VGUI.Pages.Request:FasttrackPage( parent, data, other )
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
	popup:SetSize( 420, 160 )
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
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#HEADING_Name" ).." - "..JukeBox.Lang:GetPhrase( "#MANUAL_SendingRequest" ), "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
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
	popup.Content:DockPadding( 10, 10, 10, 10 )
	popup.Content:Dock( FILL )
	popup.Content.Progress = 1
	popup.Content.ProgressData = ""
	popup.Content.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	local text = ""
	if JukeBox.Settings.UsePointshop then
		text = JukeBox.Lang:GetPhrase( "#MANUAL_FastTrackWarn", JukeBox.Settings.RequestFasttrackCost, JukeBox.Lang:GetPhrase( "#ALLSONGS_CostPS" ) )
	elseif JukeBox.Settings.UsePointshop2 then
		text = JukeBox.Lang:GetPhrase( "#MANUAL_FastTrackWarn", JukeBox.Settings.RequestFasttrackCost, JukeBox.Lang:GetPhrase( "#ALLSONGS_CostPS2" ) )
	elseif JukeBox.Settings.UseDarkRPCash then
		text = JukeBox.Lang:GetPhrase( "#MANUAL_FastTrackWarn", JukeBox.Settings.RequestFasttrackCost, JukeBox.Lang:GetPhrase( "#ALLSONGS_CostDRPCash" ) )
	elseif JukeBox.Settings.UseSimpleMoney then
		text = JukeBox.Lang:GetPhrase( "#MANUAL_FastTrackWarn", JukeBox.Settings.RequestFasttrackCost, JukeBox.Lang:GetPhrase( "#ALLSONGS_CostSMCash" ) )
	else
		text = JukeBox.Lang:GetPhrase( "#MANUAL_FastTrackWarn", JukeBox.Lang:GetPhrase( "#ALLSONGS_CostNothing" ), "" )
	end
	
	popup.Content.Text = vgui.Create( "DLabel", popup.Content )
	popup.Content.Text:Dock( FILL )
	popup.Content.Text:SetText( text )
	popup.Content.Text:SetTextColor( Color( 255, 255, 255, 255 ) )
	popup.Content.Text:SetFont( "JukeBox.Font.18" )
	
	popup.Content.ActionButtons = vgui.Create( "DPanel", popup.Content )
	popup.Content.ActionButtons:Dock( BOTTOM )
	popup.Content.ActionButtons:SetTall( 30 )
	popup.Content.ActionButtons.Paint = function( self, w, h )
		
	end
	
	popup.Content.ActionButtons.Accept = vgui.Create( "DButton", popup.Content.ActionButtons )
	popup.Content.ActionButtons.Accept:Dock( LEFT )
	popup.Content.ActionButtons.Accept:DockMargin( 0, 0, 10, 0 )
	popup.Content.ActionButtons.Accept:SetWide( 125 )
	popup.Content.ActionButtons.Accept:SetText( "" )
	popup.Content.ActionButtons.Accept.DoClick = function( self )
		JukeBox:FasttrackRequest( data )
		bg:Remove()
		other:Remove()
	end
	popup.Content.ActionButtons.Accept.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Accept )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( h*0.75, h/2, 16, "jukebox/tick.png", Color( 255, 255, 255 ), 0 )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#MANUAL_AddSong" ), "JukeBox.Font.20", h+10, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.Content.ActionButtons.Cancel = vgui.Create( "DButton", popup.Content.ActionButtons )
	popup.Content.ActionButtons.Cancel:SetWide( 100 )
	popup.Content.ActionButtons.Cancel:Dock( RIGHT )
	popup.Content.ActionButtons.Cancel:SetVisible( true )
	popup.Content.ActionButtons.Cancel:DockMargin( 0, 0, 10, 0 )
	popup.Content.ActionButtons.Cancel:SetText( "" )
	popup.Content.ActionButtons.Cancel.Text = JukeBox.Lang:GetPhrase( "#BUTTON_Cancel" )
	popup.Content.ActionButtons.Cancel.DoClick = function()
		bg:Remove()
	end
	popup.Content.ActionButtons.Cancel.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( h/2-1, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		else
			draw.RoundedBox( h/2-1, 0, 0, w, h, JukeBox.Colours.Light )
		end
		draw.SimpleText( self.Text, "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
end
 
JukeBox.VGUI:RegisterPage( "#TAB_AddSong", "Request", "#TAB_Manual", "jukebox/edit.png", function( parent ) JukeBox.VGUI.Pages.Request:CreatePanel( parent ) end )