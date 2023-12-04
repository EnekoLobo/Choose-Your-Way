/*
 * Queued Songs
 */

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "JukeBox"
MODULE.Name = "Queued Songs"
MODULE.Colour = JukeBox.Colours.Definition

MODULE:Setup(function()
	MODULE:Hook("JukeBox_SongQueued", "onSongQueued", function(ply, song)
		MODULE:Log("{1} queued {2} - {3} (youtu.be/{4})",
      GAS.Logging:FormatPlayer(ply),
      GAS.Logging:Highlight(song.artist),
      GAS.Logging:Highlight(song.name),
      GAS.Logging:Highlight(song.id)
    )
	end)
end)

GAS.Logging:AddModule(MODULE)

/*
 * Requested songs
 */

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "JukeBox"
MODULE.Name = "Requested Songs"
MODULE.Colour = JukeBox.Colours.Definition

MODULE:Setup(function()
  MODULE:Hook("JukeBox_SongRequested", "onSongRequested", function(ply, request, accepted)
    MODULE:Log("{1} requested {2} - {3} (youtu.be/{4})",
      GAS.Logging:FormatPlayer(ply),
      GAS.Logging:Highlight(request.artist),
      GAS.Logging:Highlight(request.name),
      GAS.Logging:Highlight(request.id)
    )
  end)
end)
 
GAS.Logging:AddModule(MODULE)