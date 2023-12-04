--// Creates the player (hidden) \\--
function JukeBox:InitPlayer()
	if not (self.HTMLPlayer) then
		self.HTMLPlayer = vgui.Create( "DHTML" )
	end
	self.HTMLPlayer:SetPos( -500, -500 )
	self.HTMLPlayer:SetSize( 500, 500 )
	self.HTMLPlayer:SetVisible( true )
	self.HTMLPlayer:SetAllowLua( true )
	/*																							*\
		A word of apology here. I've had to overwrite this function because
        the YouTube API causes HTML errors to be spammed into the console on first song start.
		Overwriting this seems to suppress the messages.
		I don't want to have to do this but I see no other alternative.
		Sorry to delete your error messages.
	\*																							*/
	self.HTMLPlayer.MouseState = 0
	function self.HTMLPlayer:DoMouseStuff()
		if self.MouseState == 0 then return end
		if self.MouseState == 600 then
			self:SetVisible( true )
			self:SetZPos( 32767 )
			self:MakePopup()
			self:SetPos( gui.MouseX()-10, gui.MouseY()-self:GetTall()+10 )
			self:MakePopup()
			gui.EnableScreenClicker()
			gui.InternalCursorMoved( 0, 0 )
		elseif self.MouseState == 599 then
			local x, y = input.GetCursorPos()
			gui.InternalCursorMoved( x, y )
		elseif (self.MouseState == 598 or self.MouseState == 2) then
			gui.InternalMousePressed( MOUSE_LEFT )
			gui.InternalMouseReleased( MOUSE_LEFT )
		elseif self.MouseState == 1 then
			--gui.EnableScreenClicker( false )
			--self:SetKeyboardInputEnabled( false )
			--self:SetMouseInputEnabled( false )
			--self:SetZPos( 0 )
			self:SetPos( 0, 0 )
		end
		self.MouseState = self.MouseState - 1
	end
	function self.HTMLPlayer:Think()
		self:DoMouseStuff()
	end
	function self.HTMLPlayer:ConsoleMessage( msg )
		if ( !isstring( msg ) ) then msg = "*js variable*" end
		if ( string.StartWith( msg, "RUNLUA:" ) ) then
			local strLua = string.sub( msg, 8 )
			RunString( strLua )
			--return; 
		end
		--MsgC( Color( 255, 160, 255 ), "[HTML] " )
		--MsgC( Color( 255, 255, 255 ), msg, "\n" )	
	end
	self.HTMLPlayer:OpenURL( JukeBox.Settings.PlayerURL.."?time="..CurTime() )
end

--// Hopefully fixes playback issues \\--
function JukeBox:FixPlayback()
	self.HTMLPlayer.MouseState = 600
	if true then return end
	local wasCursorVisible = vgui.CursorVisible()
	
	if not wasCursorVisible then
		gui.EnableScreenClicker( true )
	end
	
	local mouseX, mouseY 	= gui.MousePos()
	local panelW, panelH 	= self.HTMLPlayer:GetSize()
	local panelX, panelY 	= self.HTMLPlayer:GetPos()
	local wasVisible 		= self.HTMLPlayer:IsVisible()
	local wasDebug 			= ValidPanel( self.HTMLPlayer.Overlay )
	
	if wasDebug then
		self.HTMLPlayer.Overlay:SetVisible( false )
	end
	if not wasVisible then
		self.HTMLPlayer:SetVisible( true )
	end
	
	local popup = vgui.Create( "DFrame" )
	popup:DockPadding( 0, 0, 0, 0 )
	popup:SetSize( panelW, panelH )
	popup:SetPos( mouseX-10, mouseY-panelH+10 )
	popup:MakePopup()
	popup:MoveToFront()
	
	self.HTMLPlayer:SetParent( popup )
	self.HTMLPlayer:SetPos( 0, 0 )
	self.HTMLPlayer:SetSize( panelW, panelH )

	--gui.InternalMouseDoublePressed( MOUSE_LEFT )
	--self.HTMLPlayer:SetPos( panelX, panelY )
	--self.HTMLPlayer:KillFocus()
	
	if not wasVisible then
		--self.HTMLPlayer:SetVisible( false )
	end
	if wasDebug then
		--self.HTMLPlayer.Overlay:SetVisible( true )
	end
	
	if not wasCursorVisible then
		gui.EnableScreenClicker( false )
	end
end

--// Stops the video \\--
function JukeBox:StopVideo()
	if not (self.HTMLPlayer) then return end
	self.HTMLPlayer:RunJavascript( "JukeBox.StopVideo();")
end

--// Plays the video \\--
function JukeBox:PlayVideo( id )
	if not (self.HTMLPlayer) then return end
	if not tobool( self:GetCookie( "JukeBox_Enabled" ) ) and not self.ListenLocally then return end
	if not JukeBox.Settings.PlayWhileAlive and not JukeBox.PlayerAlive then return end
	self.HTMLPlayer:RunJavascript( 'JukeBox.PlayVideo("'..id..'");')
end

--// Sets the volume of the player \\--
function JukeBox:SetVolume( volume )
	if not (self.HTMLPlayer) then return end
	if type( JukeBox.ServerVolume ) == "number" then volume = JukeBox.ServerVolume end
	self.HTMLPlayer:RunJavascript( "JukeBox.SetVolume("..volume..");")
end

--// Goes to specific point in video \\--
function JukeBox:PlayVideoFromTime( id, time )
	if not (self.HTMLPlayer) then return end
	if not tobool( self:GetCookie( "JukeBox_Enabled" ) ) and not self.ListenLocally then return end
	if not JukeBox.Settings.PlayWhileAlive and not JukeBox.PlayerAlive then return end
	self.HTMLPlayer:RunJavascript( 'JukeBox.PlayVideoFrom("'.. id .. '", '..time..');')
end

--// Ends at specific point in video \\--
function JukeBox:PlayVideoUntilTime( id, time )
	if not (self.HTMLPlayer) then return end
	if not tobool( self:GetCookie( "JukeBox_Enabled" ) ) and not self.ListenLocally then return end
	if not JukeBox.Settings.PlayWhileAlive and not JukeBox.PlayerAlive then return end
	self.HTMLPlayer:RunJavascript( 'JukeBox.PlayVideoUntil("'..id..'", '..time..');')
end

--// Makes use of startTime and endTime \\--
function JukeBox:PlayVideoWithTimes( id, startTime, endTime )
	if not (self.HTMLPlayer) then return end
	if not tobool( self:GetCookie( "JukeBox_Enabled" ) ) and not self.ListenLocally then return end
	if not JukeBox.Settings.PlayWhileAlive and not JukeBox.PlayerAlive then return end
	self.HTMLPlayer:RunJavascript( 'JukeBox.PlayVideoFromUntil("'..id..'", '..startTime..', '..endTime..');')
end

--// Start-up Hook \\--
hook.Add( "Initialize", "JukeBox_ClientStartUp", function() 
	JukeBox:InitPlayer()
	timer.Simple( 1, function()
		JukeBox:SetVolume( JukeBox:GetCookie( "JukeBox_Volume" ) )
	end )
end)