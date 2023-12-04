JukeBox.VGUI = {}
JukeBox.VGUI.VGUI = {}

net.Receive( "JukeBox_OpenMenu", function() JukeBox.VGUI.OpenWindow() end )

--// FKEY command \\--
local keytoggle = false
function JukeBox.VGUI.ButtonThink()
	if JukeBox.Settings.UseQuickKey then
		if input.IsKeyDown( JukeBox.Settings.QuickKey ) then
			if keytoggle then return end
			keytoggle = true
			JukeBox.VGUI.OpenWindow()
		else
			keytoggle = false
		end
	end
end
hook.Add("Think", "JukeBox.VGUI.ButtonHook", JukeBox.VGUI.ButtonThink )

--// Checks if the user is restricted \\--
function JukeBox.VGUI.CanOpen()
	if (JukeBox:IsManager(LocalPlayer())) then return true end
	if not JukeBox.Settings.RestrictMenu then return true end
	if JukeBox.Settings.UseGroupRestrictions then
		local isInGroup = table.HasValue( JukeBox.Settings.RestrictedGroups, LocalPlayer():GetUserGroup() )
		local result = isInGroup
		if (not JukeBox.Settings.GroupRestrctionWhiteList) then result = not result end
		return result
	end
	if JukeBox.Settings.UseJobRestrictions then
		local isInJob = table.HasValue( JukeBox.Settings.RestrictedJobs, LocalPlayer():Team() )
		local result = isInJob
		if JukeBox.Settings.JobRestrictionWhitelist then result = not result end
		return result
	end
	if JukeBox.Settings.UsexAdminRestrictions then
		return LocalPlayer():xAdminHasPermission("jukebox_queuesong")
	end
	return true
end

--// Opens the window \\--
function JukeBox.VGUI.OpenWindow()
	if (not JukeBox.VGUI.CanOpen()) then
		JukeBox:ChatAddText( '#CHAT_CantOpenMenu', 'JukeBox_CantOpenMenu' )
		return
	end
	if JukeBox.VGUI.Menu and ValidPanel( JukeBox.VGUI.Menu ) then
		JukeBox.VGUI.Menu:SetVisible( true )
	else
		JukeBox.VGUI.Menu = vgui.Create( "D_JukeBox" )
        if JukeBox.ChromiumPopup == 1 then
            JukeBox.VGUI:CreateChromiumPopup()
            JukeBox.ChromiumPopup = 2
        end
	end
end

concommand.Add( "JukeBox_OpenMenu", function() JukeBox.VGUI.OpenWindow() end, nil, "Console command to open the JukeBox VGUI" )

--// Creates a Popup \\--
function JukeBox.VGUI:CreatePopup( header, body )
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
	--popup:SetSize( 0, 0 )
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
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#HEADING_Name" ).." - "..header, "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
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
	popup.Content.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	popup.Body = vgui.Create( "DLabel", popup.Content )
	popup.Body:SetFont( "JukeBox.Font.18" )
	popup.Body:SetTextColor( Color( 255, 255, 255 ) )
	popup.Body:SetText( body )
	popup.Body:SizeToContents()
	popup:SetWide( popup.Body:GetWide()+10 )
	popup:SetTall( popup.Body:GetTall()+popup.TopBar:GetTall()+11 )
	popup.Body:Dock( FILL )
	
	popup:Center()
end

--// Add a page \\--
JukeBox.VGUI.Pages = {}
JukeBox.VGUI.VGUI.Pages = {}
function JukeBox.VGUI:RegisterPage( header, unique, name, mat, run, admin )
	table.insert( self.VGUI.Pages, {
		header = header,
		unique = unique,
		name = name,
		mat = mat,
		run = run,
		admin = admin,
	} )
end

--// Panel initialisation \\--
function JukeBox.VGUI.VGUI:Init()
	JukeBox.VGUI.VGUI = self
	self:SetSize( ScrW()*0.8, ScrH()*0.8 )
	self:Center()
	self:ShowCloseButton( false )
	self:SetDraggable( true )
	self:SetTitle( " " )
	self:DockPadding( 0, 0, 0, 0 )
	self:MakePopup()
	self.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
	end
	
	self.TopBar = vgui.Create( "DPanel", self )
	self.TopBar:Dock( TOP )
	self.TopBar:SetTall( 28 )
	self.TopBar:DockPadding( 4, 4, 4, 4 )
	self.TopBar.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#HEADING_Name" ), "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	self.TopBar.CloseButton = vgui.Create( "DButton", self.TopBar )
	self.TopBar.CloseButton:Dock( RIGHT )
	self.TopBar.CloseButton:SetWide( 50 )
	self.TopBar.CloseButton:SetText( "" )
	self.TopBar.CloseButton.DoClick = function()
		self:Close()
	end
	self.TopBar.CloseButton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 57, 43 ) )
		if not JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255 ), 0 )
	end
	
	self.Notifications = vgui.Create( "DPanel", self )
	self.Notifications:Dock( TOP )
	self.Notifications:DockPadding( 0, 1, 0, 0 )
	self.Notifications:SetTall( 1 )
	self.Notifications.Paint = function( self, w, h )
	
	end
	
	self.PlayBar = vgui.Create( "DPanel", self )
	self.PlayBar:Dock( BOTTOM )
	self.PlayBar:SetTall( 60 )
	self.PlayBar.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		if JukeBox.CurPlaying then
			draw.SimpleText( JukeBox.VoteSkips.."/"..math.ceil(JukeBox.PlayersTunedIn*JukeBox.Settings.VoteSkipPercent), "JukeBox.Font.18", 75/2, 12, Color( 255, 255, 255 ), 1, 0 )
			draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#BASE_VotesTo" ), "JukeBox.Font.12", 75/2, 30, Color( 255, 255, 255 ), 1, 0 )
			draw.SimpleText( JukeBox.Lang:GetPhraseCaps( "#BASE_Skip" ), "JukeBox.Font.12", 75/2, 40, Color( 255, 255, 255 ), 1, 0 )
		end
	end
	
	self.PlayBar.Volume = vgui.Create( "DSlider", self.PlayBar )
	self.PlayBar.Volume:Dock( RIGHT )
	self.PlayBar.Volume:DockMargin( 10, 15, 20, 15 )
	self.PlayBar.Volume:SetTrapInside( false )
	self.PlayBar.Volume:SetWide( 150 )
	self.PlayBar.Volume.Disabled = type( JukeBox.ServerVolume ) == "number"
	hook.Add( "JukeBox_ServerVolume", "JukeBox_VolumeSliderDisable", function()
		if ValidPanel( self ) then
			if type( JukeBox.ServerVolume ) == "number" then
				self.PlayBar.Volume.Disabled = true
			else
				self.PlayBar.Volume.Disabled = false
			end
		end
	end )
	self.PlayBar.Volume:SetSlideX( JukeBox:GetCookie( "JukeBox_Volume" )/100 )
	self.PlayBar.Volume.SlideValue = JukeBox:GetCookie( "JukeBox_Volume" )/100
	self.PlayBar.Volume.Think = function( panel )
		if panel:GetSlideX() != panel.SlideValue then
			if panel.Disabled then
				panel:SetSlideX( panel.SlideValue )
			else
				JukeBox:SetCookie( "JukeBox_Volume", math.Round(panel:GetSlideX()*100) )
				if tobool( JukeBox:GetCookie( "JukeBox_Enabled" ) ) then
					JukeBox:SetVolume( math.Round(panel:GetSlideX()*100) )
				end
				panel.SlideValue = panel:GetSlideX()
			end
		end
	end
	self.PlayBar.Volume.Paint = function( panel, w, h )
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
	self.PlayBar.Volume.Knob.Paint = function( panel, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self.PlayBar.Volume ) or self.PlayBar.Volume:GetDragging() then
			if panel:GetParent().Disabled then
				draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 100, 100 ) )
			else
				draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 255, 255 ) )
			end
		end
	end
	
	self.PlayBar.Volume.Icon = vgui.Create( "DPanel", self.PlayBar )
	self.PlayBar.Volume.Icon:Dock( RIGHT )
	self.PlayBar.Volume.Icon:SetWide( 20 )
	self.PlayBar.Volume.Icon.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 14, "jukebox/volume.png", Color( 200, 200, 200 ), 0 )
	end
	
	self.PlayBar.Controls = vgui.Create( "DPanel", self.PlayBar )
	self.PlayBar.Controls:Dock( LEFT )
	self.PlayBar.Controls:SetWide( 200 )
	self.PlayBar.Controls.Paint = function( self, w, h )

	end
	
	self.PlayBar.Controls.PlayStop = vgui.Create( "DButton", self.PlayBar.Controls )
	self.PlayBar.Controls.PlayStop:Dock( LEFT )
	self.PlayBar.Controls.PlayStop:DockMargin( 75, 5, 0, 5 )
	self.PlayBar.Controls.PlayStop:SetWide( 50 )
	self.PlayBar.Controls.PlayStop:SetText( "" )
	self.PlayBar.Controls.PlayStop.PlayEnabled = tobool( JukeBox:GetCookie( "JukeBox_Enabled" ) )
	self.PlayBar.Controls.PlayStop.DoClick = function()
		if JukeBox.ListenLocally then
			JukeBox.ListenLocally = false
			JukeBox.timer.Destroy( "JukeBox_PlayingTimer" )
			JukeBox:StopVideo()
			JukeBox.CurPlaying = false
			JukeBox.CurPlayingStart = false
			JukeBox.CurPlayingEnd = false
			if JukeBox:GetCookie( "JukeBox_Enabled" ) then
				JukeBox:PlayReEnabled()
			end
			return
		end
		self.PlayBar.Controls.PlayStop.PlayEnabled = !self.PlayBar.Controls.PlayStop.PlayEnabled
		JukeBox:SetCookie( "JukeBox_Enabled", tostring( self.PlayBar.Controls.PlayStop.PlayEnabled ) )
		if !self.PlayBar.Controls.PlayStop.PlayEnabled then
			JukeBox:StopVideo()
			JukeBox:IsTunedIn( false )
		else
			JukeBox:PlayReEnabled()
			JukeBox:IsTunedIn( true )
		end
	end
	self.PlayBar.Controls.PlayStop.Paint = function( self, w, h )
		if self.PlayEnabled or JukeBox.ListenLocally then
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				surface.DrawCircle( w/2, h/2, w/2, JukeBox.Colours.Definition )
				draw.RoundedBox( 4, w/2-12, h/2-12, 24, 24, JukeBox.Colours.Definition )
			else
				surface.DrawCircle( w/2, h/2, w/2, Color( 200, 200, 200 ) )
				draw.RoundedBox( 4, w/2-12, h/2-12, 24, 24, Color( 255, 255, 255 ) )
			end
		else
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				surface.DrawCircle( w/2, h/2, w/2, JukeBox.Colours.Definition )
				JukeBox.VGUI.VGUI:DrawEmblem( w/2+2, h/2, 32, "jukebox/play.png", JukeBox.Colours.Definition, 0 )
			else
				surface.DrawCircle( w/2, h/2, w/2, Color( 200, 200, 200 ) )
				JukeBox.VGUI.VGUI:DrawEmblem( w/2+2, h/2, 32, "jukebox/play.png", Color( 255, 255, 255 ), 0 )
			end
		end
	end
	self.PlayBar.Controls.PlayStop.Think = function( self )
		if not JukeBox.Settings.PlayWhileAlive then
			if not JukeBox.PlayerAlive and not self.Blocker then
				self.Blocker = true
				self:SetDisabled( true )
				self:SetToolTip( JukeBox.Lang:GetPhrase( "#BASE_PlayDisabled" ) )
				self.PaintOver = function( self, w, h )
					draw.RoundedBox( h/2, 0, 0, w, h, JukeBox.Colours.Issue )
					surface.DrawCircle( w/2, h/2, w/2, Color( 255, 255, 255 ) )
					surface.DrawCircle( w/2, h/2, w/2-1, Color( 255, 255, 255 ) )
					--JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, h/2, "jukebox/warning.png", Color( 255, 255, 255 ), 0 )
					draw.RoundedBox( 4, 13, 12, 10, h-24, Color( 255, 255, 255 ) )
					draw.RoundedBox( 4, w-12-11, 12, 10, h-24, Color( 255, 255, 255 ) )
				end
			elseif JukeBox.PlayerAlive and self.Blocker then
				self.Blocker = false
				self:SetDisabled( false )
				self:SetToolTip( nil )
			end
		end
	end

	self.PlayBar.Controls.VoteSkip = vgui.Create( "DButton", self.PlayBar.Controls )
	self.PlayBar.Controls.VoteSkip:Dock( LEFT )
	self.PlayBar.Controls.VoteSkip:DockMargin( 20, 20, 0, 20 )
	self.PlayBar.Controls.VoteSkip:SetWide( 16 )
	self.PlayBar.Controls.VoteSkip:SetText( "" )
	self.PlayBar.Controls.VoteSkip.DoClick = function()
		if JukeBox:IsManager( LocalPlayer() ) then
			local dropdown = vgui.Create( "DMenu" )
			dropdown:SetPos( input.GetCursorPos() )
			dropdown:MakePopup()
			dropdown.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Background )
			end
			local dropdownVoteButton = dropdown:AddOption( JukeBox.Lang:GetPhrase( "#BASE_VoteSkip" ) )
			dropdownVoteButton:SetTextColor( Color( 255, 255, 255 ) )
			function dropdownVoteButton:DoClick()
				JukeBox:VoteSkip()
			end
			dropdown:AddSpacer()
			local dropdownForceButton = dropdown:AddOption( JukeBox.Lang:GetPhrase( "#BASE_ForceSkip" ) )
			dropdownForceButton:SetTextColor( Color( 255, 255, 255 ) )
			function dropdownForceButton:DoClick()
				JukeBox:ForceSkip()
			end
		else
			JukeBox:VoteSkip()
		end
	end
	self.PlayBar.Controls.VoteSkip.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, h, "jukebox/play.png", JukeBox.Colours.Definition, 0 )
			draw.RoundedBox( 4, w-5, 1, 5, h-2, JukeBox.Colours.Definition )
		else
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, h, "jukebox/play.png", Color( 255, 255, 255 ), 0 )
			draw.RoundedBox( 4, w-5, 1, 5, h-2, Color( 255, 255, 255 ) )
		end
	end
	
	self.PlayBar.Bar = vgui.Create( "DPanel", self.PlayBar )
	self.PlayBar.Bar:Dock( FILL )
	self.PlayBar.Bar:DockMargin( 0, 15, 10, 15 )
	self.PlayBar.Bar.Paint = function( self, w, h )
		local length, minsec, percent
		if JukeBox.CurPlaying then
			length = tonumber(JukeBox.SongList[JukeBox.CurPlaying].length)
			local time =  string.FormattedTime( length )
			minsec1 = time.h!=0 and Format("%02i:%02i:%02i", time.h, time.m, time.s) or Format("%02i:%02i", time.m, time.s)
			time2 = string.FormattedTime( math.Clamp( math.Round(os.time()-JukeBox.CurPlayingStart), 0, length ) )
			minsec2 = time2.h!=0 and Format("%02i:%02i:%02i", time2.h, time2.m, time2.s) or Format("%02i:%02i", time2.m, time2.s)
			percent = math.Clamp( ((os.time()-JukeBox.CurPlayingStart)/(JukeBox.CurPlayingEnd-JukeBox.CurPlayingStart)), 0, 1 )
			
			if JukeBox.VGUI.VGUI:GetHovered( self ) then
				draw.RoundedBox( 4, 60, h/2-3, w-120, 7, JukeBox.Colours.Light )
				draw.RoundedBox( 4, 60, h/2-3, (w-120)*percent, 7, JukeBox.Colours.Definition )
			else
				draw.RoundedBox( 4, 60, h/2-2, w-120, 5, JukeBox.Colours.Light )
				draw.RoundedBox( 4, 60, h/2-2, (w-120)*percent, 5, JukeBox.Colours.Definition )
			end
			draw.SimpleText( minsec2, "JukeBox.Font.14", 50, h/2, Color( 255, 255, 255 ), 2, 1 )
			draw.SimpleText( minsec1, "JukeBox.Font.14", w-50, h/2, Color( 255, 255, 255 ), 0, 1 )
		end
	end
	
	self.LeftHolder = vgui.Create( "DPanel", self )
	self.LeftHolder:Dock( LEFT )
	self.LeftHolder:SetWide( 200 )
	self.LeftHolder.Paint = function( self, w, h )
		
	end
	
	self.PlayInfo = vgui.Create( "DPanel", self.LeftHolder )
	self.PlayInfo:Dock( BOTTOM )
	self.PlayInfo:SetTall( 50 )
	self.PlayInfo:DockMargin( 0, 0, 0, 1 )
	self.PlayInfo.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
		if JukeBox.CurPlaying then
			draw.SimpleText( JukeBox:MinWord( JukeBox.SongList[JukeBox.CurPlaying].name, "JukeBox.Font.20", 180 ), "JukeBox.Font.20", 10, 16, Color( 255, 255, 255 ), 0, 1 )
			draw.SimpleText( JukeBox:MinWord( JukeBox.SongList[JukeBox.CurPlaying].artist, "JukeBox.Font.16", 180), "JukeBox.Font.16", 10, h-16, Color( 255, 255, 255 ), 0, 1 )
		else
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#BASE_NotPlaying" ), "JukeBox.Font.20", 10, 16, Color( 255, 255, 255 ), 0, 1 )
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#BASE_NotPlaying" ), "JukeBox.Font.16", 10, h-16, Color( 255, 255, 255 ), 0, 1 )
		end
	end
	
	self.Navigation = vgui.Create( "DScrollPanel", self.LeftHolder )
	self.Navigation:Dock( FILL )
	self.Navigation.Pages = {}
	self.Navigation:SetWide( 200 )
	self.Navigation:DockMargin( 0, 0, 0, 1 )
	self.Navigation:DockPadding( 0, 0, 0, 0 )
	self.Navigation.VBar:SetWide( 10 )
	self.Navigation.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	self.Navigation.VBar.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	self.Navigation.VBar.btnGrip.Paint = function( self, w, h )
		draw.RoundedBox( w/2, 0, 0, w, h, JukeBox.Colours.Light )
	end
	self.Navigation.VBar.btnUp.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 0 )
	end
	self.Navigation.VBar.btnDown.Paint = function( self, w, h )
		JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, w, "jukebox/arrow.png", Color( 200, 200, 200 ), 180 )
	end
	
	self.MainPage = vgui.Create( "DPanel", self )
	self.MainPage:Dock( FILL )
	self.MainPage:DockMargin( 1, 0, 1, 1 )
	self.MainPage.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	--self:MakeNavButton( "MAIN", "AllSongs", "All Songs", "jukebox/music.png" )
	--self:HideTabsExcept( self.Navigation["MAIN"]["AllSongs"] )
	for k, v in pairs( self.Pages ) do
		if v.admin then
			if JukeBox:IsManager( LocalPlayer() ) then
				self:MakeNavButton( v.header, v.unique, v.name, v.mat, v.run )
			end
		else
			self:MakeNavButton( v.header, v.unique, v.name, v.mat, v.run )
		end
		if k == 1 then
			self:HideTabsExcept( self.Navigation[v.header][v.unique] )
		end
	end
	--self:MakeNavButton( "MAIN", "Queue", "Queue", "jukebox/list.png" )
	--self:MakeNavButton( "MAIN", "Request", "Add a song", "jukebox/edit.png" )
	--self:MakeNavButton( "USER", "Options", "Options", "jukebox/options.png" )
	--self:MakeNavButton( "USER", "Debug", "Debug Player", "jukebox/warning.png" )
	--self:MakeNavButton( "ADMIN", "AdminRequest", "Requests", "jukebox/admin.png" )		
end

--// Create header \\--
function JukeBox.VGUI.VGUI:MakeNavHeader( parentnav, unique )
	parentnav[unique] = vgui.Create( "DPanel", parentnav )
	parentnav[unique]:Dock( TOP )
	parentnav[unique]:DockPadding( 0, 25, 0, 0 )
	parentnav[unique]:DockMargin( 0, 0, 0, 30 )
	parentnav[unique]:SetTall( 25 )
	parentnav[unique].Paint = function( self, w, h )
		draw.SimpleText( string.StartWith( unique, "#" ) and JukeBox.Lang:GetPhraseCaps( unique ) or unique, "JukeBox.Font.14", 12, 12, Color( 200, 200, 200 ), 0, 1 )
	end
end

--// Create Tab Button \\--
function JukeBox.VGUI.VGUI:MakeNavButton( header, unique, name, mat, run )
	local parentnav = JukeBox.VGUI.VGUI.Navigation
	local parentpage = JukeBox.VGUI.VGUI.MainPage
	if not parentnav[header] then
		JukeBox.VGUI.VGUI:MakeNavHeader( parentnav, header )
	end
	parentnav[header][unique] = {}
	parentnav[header][unique].Selected = false
	parentnav[header][unique].SetChosen = function( bool )
		parentnav[header][unique].Selected = bool
		parentnav[header][unique].Page:SetVisible( bool )
	end
	
	parentnav[header][unique].NavButton = vgui.Create( "DButton", parentnav[header] )
	parentnav[header][unique].NavButton:Dock( TOP )
	parentnav[header][unique].NavButton:SetTall( 35 )
	parentnav[header][unique].NavButton:SetText( "" )
	parentnav[header][unique].NavButton.DoClick = function()
		JukeBox.VGUI.VGUI:HideTabsExcept( parentnav[header][unique] )
	end
	parentnav[header][unique].NavButton.Paint = function( self, w, h )
		if parentnav[header][unique].Selected then
			draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Light )
			draw.RoundedBox( 0, 0, 0, 3, h, JukeBox.Colours.Definition )
		end
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			draw.SimpleText( string.StartWith( name, "#" ) and JukeBox.Lang:GetPhrase( name ) or name, "JukeBox.Font.20", 50, h/2, Color( 255, 255, 255 ), 0, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( h/2+7, h/2, 18, mat, Color( 255, 255, 255 ), 0 )
		else
			draw.SimpleText( string.StartWith( name, "#" ) and JukeBox.Lang:GetPhrase( name ) or name, "JukeBox.Font.20", 50, h/2, Color( 200, 200, 200 ), 0, 1 )
			JukeBox.VGUI.VGUI:DrawEmblem( h/2+7, h/2, 18, mat, Color( 200, 200, 200 ), 0 )
		end
	end
	parentnav[header]:SetTall(parentnav[header]:GetTall()+35)
	
	parentnav[header][unique].Page = vgui.Create( "DPanel", parentpage )
	parentnav[header][unique].Page:Dock( FILL )
	parentnav[header][unique].Page:SetVisible( false )
	parentnav[header][unique].Page.Paint = function( self, w, h )
		--draw.SimpleText( name.." Page", "JukeBox.Font.20", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
	end
	
	if run then
		run( parentnav[header][unique].Page )
	end
	
	table.insert( parentnav.Pages, parentnav[header][unique] )
end

--// Deselects all tabs bar 1 \\--
function JukeBox.VGUI.VGUI:HideTabsExcept( unique )
	local pages = self.Navigation.Pages
	for k, v in pairs( pages ) do
		v.SetChosen( false )
	end
	unique.SetChosen( true )
end

--// Check if cursor's on element \\--
function JukeBox.VGUI.VGUI:GetHovered( panel )
	local x, y = panel:LocalCursorPos()
	if x>=0 and x<panel:GetWide( ) and y>=0 and y<panel:GetTall( ) then
		return true
	else
		return false
	end
end

--// Draw material easier \\--
function JukeBox.VGUI.VGUI:DrawEmblem( x, y, size, mat, color, angle )
	if not angle then angle = 0 end
	surface.SetDrawColor( color )
	surface.SetMaterial( Material( mat ) )
	surface.DrawTexturedRectRotated( x, y, size, size, angle )
end

--// Top notifications creator \\--
function JukeBox.VGUI.VGUI:MakeNotification( text, colour, mat, id, killID, emergency )
	local noteHeight = 32
	if killID then
		self:KillNotifications( id )
	end
	JukeBox.VGUI.VGUI.Notifications:SetTall( JukeBox.VGUI.VGUI.Notifications:GetTall()+noteHeight )
	local note = vgui.Create( "DPanel", JukeBox.VGUI.VGUI.Notifications )
	note:Dock( TOP )
	note:DockMargin( 0, 0, 0, 0 )
	note:SetTall( noteHeight )
	note.ID = id
	note.Flash = 255
	note.DieTime = (!emergency and CurTime()+JukeBox.Settings.NotificationTimer or CurTime() )
	note.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, colour )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, colour )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 255, 255, 255, 10 ) )
		draw.RoundedBox( 0, 2, 2, w-4, h-4, colour )
		
		draw.RoundedBox( 0, 0, 0, w*((self.DieTime-CurTime())/JukeBox.Settings.NotificationTimer), h, Color( 0, 0, 0, 50 ) )
		
		local distance = math.floor((0 - note.Flash) * (math.Clamp( 0.2 * FrameTime() * 60 , 0 , 1 )))		
		self.Flash = self.Flash + distance
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, self.Flash ) )
		
		JukeBox.VGUI.VGUI:DrawEmblem( h/2, h/2, 18, mat, Color( 255, 255, 255 ), 0 )
		draw.SimpleText( text, "JukeBox.Font.18", h, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	if JukeBox.Settings.NotificationTimer > 0 and not emergency then
		timer.Simple( JukeBox.Settings.NotificationTimer, function() if note and note:IsValid() then JukeBox.VGUI.VGUI.Notifications:SetTall( JukeBox.VGUI.VGUI.Notifications:GetTall()-noteHeight ) note:Remove() end end )
	end
	
	note.CloseButton = vgui.Create( "DButton", note )
	note.CloseButton:Dock( RIGHT )
	note.CloseButton:SetWide( noteHeight )
	note.CloseButton:SetText( "" )
	note.CloseButton.DoClick = function()
		JukeBox.VGUI.VGUI.Notifications:SetTall( JukeBox.VGUI.VGUI.Notifications:GetTall()-noteHeight )
		note:Remove()
	end
	note.CloseButton.Paint = function( self, w, h )
		if JukeBox.VGUI.VGUI:GetHovered( self ) then
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255 ), 0 )
		else
			JukeBox.VGUI.VGUI:DrawEmblem( w/2, h/2, 10, "jukebox/close.png", Color( 255, 255, 255, 100 ), 0 )
		end
	end
end

--// Removes all notifications with ID \\--
function JukeBox.VGUI.VGUI:KillNotifications( id )
	local noteHeight = 32
	local count = 0
	for k, v in pairs( JukeBox.VGUI.VGUI.Notifications:GetChildren() ) do
		if v.ID == id then
			v:Remove()
			count = count+1
		end
	end
	JukeBox.VGUI.VGUI.Notifications:SetTall( JukeBox.VGUI.VGUI.Notifications:GetTall()-noteHeight*count )
end

--// No think function \\--
function JukeBox.VGUI.VGUI:Think()

end

--// Makes sure the panel closes \\--
function JukeBox.VGUI.VGUI:Close()
	self:Remove()
end

--// No perform layout function \\--
function JukeBox.VGUI.VGUI:PerformLayout()
	
end

--// Finally, register the VGUI \\--
vgui.Register( "D_JukeBox", JukeBox.VGUI.VGUI, "DFrame" )

--// Creates the Chromium Popup \\--
--// Creates a Popup \\--
function JukeBox.VGUI:CreateChromiumPopup()
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
	--popup:SetSize( 0, 0 )
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
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#CHROMIUM_PopupTitle" ), "JukeBox.Font.18", w/2, h/2, Color( 255, 255, 255 ), 1, 1 )
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
	popup.Content.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, JukeBox.Colours.Base )
	end
	
	popup.Body = vgui.Create( "DLabel", popup.Content )
	popup.Body:SetFont( "JukeBox.Font.18" )
	popup.Body:SetTextColor( Color( 255, 255, 255 ) )
	popup.Body:SetText( JukeBox.Lang:GetPhrase( "#CHROMIUM_PopupBody" ) )
	popup.Body:SizeToContents()
	popup.Body:Dock( FILL )
    
    popup.BottomButton = vgui.Create( "DButton", popup.Content )
	popup.BottomButton:SetSize( 100, 40 )
	popup.BottomButton:Dock( BOTTOM )
	popup.BottomButton:SetVisible( true )
	popup.BottomButton:DockMargin( 75, 20, 75, 10 )
	popup.BottomButton:SetText( "" )
	popup.BottomButton.Text = "Close"
	popup.BottomButton.DoClick = function()
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
    
        popup.NeverAgain = vgui.Create( "DPanel", popup.Content )
	popup.NeverAgain:Dock( BOTTOM )
	popup.NeverAgain:DockPadding( 0, 3, 0, 3 )
	popup.NeverAgain:DockMargin( 0, 0, 0, 0 )
	popup.NeverAgain:SetTall( 30 )
	popup.NeverAgain.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
		draw.SimpleText( JukeBox.Lang:GetPhrase( "#CHROMIUM_PopupCheckbox" ), "JukeBox.Font.16", 80, h/2, Color( 255, 255, 255 ), 0, 1 )
	end
	
	popup.NeverAgainButton = vgui.Create( "DButton", popup.NeverAgain )
	popup.NeverAgainButton:Dock( LEFT )
	popup.NeverAgainButton:SetWide( 70 )
	popup.NeverAgainButton:SetTall( 24 )
	popup.NeverAgainButton.Enabled = tobool( JukeBox:GetCookie( "JukeBox_ChromiumPopupOff" ) )
	popup.NeverAgainButton:SetText( "" )
	popup.NeverAgainButton.DoClick = function( self )
		self.Enabled = !self.Enabled
		JukeBox:SetCookie( "JukeBox_ChromiumPopupOff", tostring(self.Enabled) )
	end
	popup.NeverAgainButton.Paint = function( self, w, h )
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
	
    popup:SetWide( popup.Body:GetWide()+10 )
	popup:SetTall( popup.Body:GetTall()+popup.TopBar:GetTall()+11+popup.NeverAgain:GetTall()+popup.BottomButton:GetTall()+36 )
	popup:Center()
end