JukeBox.HUD = {}
JukeBox.HUD.Width = 300
JukeBox.HUD.Height = 70
JukeBox.HUD.BarHeight = 20
JukeBox.HUD.Across = {
	["left"] = 10,
	["center"] = (ScrW()/2)-(JukeBox.HUD.Width/2),
	["right"] = ScrW()-10-JukeBox.HUD.Width,
}
JukeBox.HUD.Down = {
	["top"] = 10,
	["center"] = (ScrH()/2)-(JukeBox.HUD.Height/2),
	["bottom"] = ScrH()-10-JukeBox.HUD.Height,
}
JukeBox.HUD.X = JukeBox.HUD.Across[JukeBox.Settings.HUDAcross]
JukeBox.HUD.Y = JukeBox.HUD.Down[JukeBox.Settings.HUDDown]
JukeBox.HUD.W = JukeBox.HUD.Width
JukeBox.HUD.H = JukeBox.HUD.Height 

function JukeBox.HUD.PaintHUD()
	if JukeBox.CurPlaying and tobool( JukeBox:GetCookie( "JukeBox_Enabled" ) ) then
		draw.RoundedBox( 0, JukeBox.HUD.X, JukeBox.HUD.Y, JukeBox.HUD.W, JukeBox.HUD.H-JukeBox.HUD.BarHeight, JukeBox.Colours.HUDBase )
		
		draw.RoundedBox( 0, JukeBox.HUD.X, JukeBox.HUD.Y+JukeBox.HUD.H-JukeBox.HUD.BarHeight+5, JukeBox.HUD.W, 2, JukeBox.Colours.HUDBase )
		draw.RoundedBox( 0, JukeBox.HUD.X, JukeBox.HUD.Y+JukeBox.HUD.H+5-2, JukeBox.HUD.W, 2, JukeBox.Colours.HUDBase )
		draw.RoundedBox( 0, JukeBox.HUD.X, JukeBox.HUD.Y+JukeBox.HUD.H-JukeBox.HUD.BarHeight+5+2, 2, JukeBox.HUD.BarHeight-4, JukeBox.Colours.HUDBase )
		draw.RoundedBox( 0, JukeBox.HUD.X+JukeBox.HUD.W-2, JukeBox.HUD.Y+JukeBox.HUD.H-JukeBox.HUD.BarHeight+5+2, 2, JukeBox.HUD.BarHeight-4, JukeBox.Colours.HUDBase )
		
		draw.RoundedBox( 0, JukeBox.HUD.X+2, JukeBox.HUD.Y+JukeBox.HUD.H-JukeBox.HUD.BarHeight+5+2, JukeBox.HUD.W-4, JukeBox.HUD.BarHeight-4, ColorAlpha( JukeBox.Colours.HUDBase, JukeBox.Colours.HUDBase.a/4) )
		
		if not JukeBox.Settings.PlayWhileAlive and not JukeBox.PlayerAlive then
			draw.RoundedBox( 4, JukeBox.HUD.X+10, JukeBox.HUD.Y+10, 12, 30, JukeBox.Colours.HUDFont )
			draw.RoundedBox( 4, JukeBox.HUD.X+28, JukeBox.HUD.Y+10, 12, 30, JukeBox.Colours.HUDFont )
		else
			surface.SetDrawColor( JukeBox.Colours.HUDFont )
			surface.SetMaterial( Material( "jukebox/play.png" ) )
			surface.DrawTexturedRectRotated( JukeBox.HUD.X+((JukeBox.HUD.H-JukeBox.HUD.BarHeight)/2), JukeBox.HUD.Y+((JukeBox.HUD.H-JukeBox.HUD.BarHeight)/2), 40, 40, 0 )
		end
		
		render.SetScissorRect( JukeBox.HUD.X, JukeBox.HUD.Y, JukeBox.HUD.X+JukeBox.HUD.W, JukeBox.HUD.Y+JukeBox.HUD.H-JukeBox.HUD.BarHeight, true )
		draw.SimpleText( JukeBox:MinWord( JukeBox.SongList[JukeBox.CurPlaying].name, "JukeBox.Font.20", JukeBox.HUD.W-60 ), "JukeBox.Font.20", JukeBox.HUD.X+10+40+1, JukeBox.HUD.Y+16+1, JukeBox.Colours.HUDBase, 0, 1 )
		draw.SimpleText( JukeBox:MinWord( JukeBox.SongList[JukeBox.CurPlaying].name, "JukeBox.Font.20", JukeBox.HUD.W-60 ), "JukeBox.Font.20", JukeBox.HUD.X+10+40, JukeBox.HUD.Y+16, JukeBox.Colours.HUDFont, 0, 1 )
		
		draw.SimpleText( JukeBox:MinWord( JukeBox.SongList[JukeBox.CurPlaying].artist, "JukeBox.Font.16", JukeBox.HUD.W-60 ), "JukeBox.Font.16", JukeBox.HUD.X+10+40+1, JukeBox.HUD.Y+(JukeBox.HUD.H-JukeBox.HUD.BarHeight)-16+1, JukeBox.Colours.HUDBase, 0, 1 )
		draw.SimpleText( JukeBox:MinWord( JukeBox.SongList[JukeBox.CurPlaying].artist, "JukeBox.Font.16", JukeBox.HUD.W-60 ), "JukeBox.Font.16", JukeBox.HUD.X+10+40, JukeBox.HUD.Y+(JukeBox.HUD.H-JukeBox.HUD.BarHeight)-16, JukeBox.Colours.HUDFont, 0, 1 )
		render.SetScissorRect( JukeBox.HUD.X, JukeBox.HUD.Y, JukeBox.HUD.X+JukeBox.HUD.W, JukeBox.HUD.Y+JukeBox.HUD.H-JukeBox.HUD.BarHeight, false )
		
		length = tonumber(JukeBox.SongList[JukeBox.CurPlaying].length)
		local time =  string.FormattedTime( length )
		minsec1 = time.h!=0 and Format("%02i:%02i:%02i", time.h, time.m, time.s) or Format("%02i:%02i", time.m, time.s)
		time2 = string.FormattedTime( math.Clamp( math.Round(os.time()-JukeBox.CurPlayingStart), 0, length ) )
		minsec2 = time2.h!=0 and Format("%02i:%02i:%02i", time2.h, time2.m, time2.s) or Format("%02i:%02i", time2.m, time2.s)
		percent = math.Clamp( ((os.time()-JukeBox.CurPlayingStart)/(JukeBox.CurPlayingEnd-JukeBox.CurPlayingStart)), 0, 1 )
		
		draw.RoundedBox( 0, JukeBox.HUD.X+4, JukeBox.HUD.Y+JukeBox.HUD.H-JukeBox.HUD.BarHeight+5+4, (JukeBox.HUD.W-8)*percent, JukeBox.HUD.BarHeight-8, JukeBox.Colours.HUDHighlight )

		draw.SimpleText( minsec2, "JukeBox.Font.13", JukeBox.HUD.X+8+1, JukeBox.HUD.Y+JukeBox.HUD.H-(JukeBox.HUD.BarHeight/2)+4+1, JukeBox.Colours.HUDBase, 0, 1 )
		draw.SimpleText( minsec2, "JukeBox.Font.13", JukeBox.HUD.X+8, JukeBox.HUD.Y+JukeBox.HUD.H-(JukeBox.HUD.BarHeight/2)+4, JukeBox.Colours.HUDFont, 0, 1 )
		
		draw.SimpleText( minsec1, "JukeBox.Font.13", JukeBox.HUD.X+JukeBox.HUD.W-8+1, JukeBox.HUD.Y+JukeBox.HUD.H-(JukeBox.HUD.BarHeight/2)+4+1, JukeBox.Colours.HUDBase, 2, 1 )
		draw.SimpleText( minsec1, "JukeBox.Font.13", JukeBox.HUD.X+JukeBox.HUD.W-8, JukeBox.HUD.Y+JukeBox.HUD.H-(JukeBox.HUD.BarHeight/2)+4, JukeBox.Colours.HUDFont, 2, 1 )
		
        if JukeBox.Settings.ChatCommands[1] then
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#BASE_ChatCommand", JukeBox.Settings.ChatCommands[1] ), "JukeBox.Font.13", JukeBox.HUD.X+JukeBox.HUD.W/2+1, JukeBox.HUD.Y+JukeBox.HUD.H-(JukeBox.HUD.BarHeight/2)+4+1, JukeBox.Colours.HUDBase, 1, 1 )
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#BASE_ChatCommand", JukeBox.Settings.ChatCommands[1] ), "JukeBox.Font.13", JukeBox.HUD.X+JukeBox.HUD.W/2, JukeBox.HUD.Y+JukeBox.HUD.H-(JukeBox.HUD.BarHeight/2)+4, JukeBox.Colours.HUDFont, 1, 1 )
		end
        
        if JukeBox.ChromiumPopup == 1 then
            draw.RoundedBox( 0, JukeBox.HUD.X, JukeBox.HUD.Y+JukeBox.HUD.H+10, JukeBox.HUD.W, JukeBox.HUD.BarHeight, Color(231, 76, 60, 150) )
            draw.SimpleText( JukeBox.Lang:GetPhrase( "#CHROMIUM_HudMessage", JukeBox.Settings.ChatCommands[1] ), "JukeBox.Font.13", JukeBox.HUD.X+JukeBox.HUD.W/2+1, JukeBox.HUD.Y+JukeBox.HUD.H+5+(JukeBox.HUD.BarHeight/2)+4+1, JukeBox.Colours.HUDBase, 1, 1 )
			draw.SimpleText( JukeBox.Lang:GetPhrase( "#CHROMIUM_HudMessage", JukeBox.Settings.ChatCommands[1] ), "JukeBox.Font.13", JukeBox.HUD.X+JukeBox.HUD.W/2, JukeBox.HUD.Y+JukeBox.HUD.H+5+(JukeBox.HUD.BarHeight/2)+4, JukeBox.Colours.HUDFont, 1, 1 )
        end
	end
end
if JukeBox.Settings.HUDEnabled then
	hook.Add("HUDPaint", "JukeBox.HUD.Hook", function() JukeBox.HUD.PaintHUD() end )
end