// HRadio Error Catcher v1

// create or initialise global tables
hradio = hradio or {}
hradio.errorcatcher = {}
hradio.errorcatcher.isOpen = false
hradio.errorcatcher.caughtErrors = {}
hradio.errorcatcher.startupErrors = {}

if SERVER then

	util.AddNetworkString("HCS_ReportError")
	util.AddNetworkString("HCS_ReportStartupError")
	util.AddNetworkString("HCS_ServerError")
	util.AddNetworkString("HCS_ServerStartupError")

	net.Receive("HCS_ReportError", function(ln, ply) -- Bounceback

		local msg = net.ReadString()

		hradio.errorcatcher.Catch(msg)

	end)

	net.Receive("HCS_ReportStartupError", function(ln, ply) -- Bounceback

		local msg = net.ReadString()

		hradio.errorcatcher.CatchLater(msg)

	end)

else -- CLIENT

	net.Receive("HCS_ServerStartupError", function(ln, ply)

		local msg = net.ReadString()

		hradio.errorcatcher.startupErrors[msg] = true -- Don't use Catch() to not create an infinite loop

	end)

	net.Receive("HCS_ServerError", function(ln, ply)

		local msg = net.ReadString()

		if !hradio.errorcatcher.isOpen then
			hradio.errorcatcher.open()
		end

		hradio.errorcatcher.addError(msg) -- Don't use Catch() to not create an infinite loop

	end)

end

function hradio.errorcatcher.Catch(errorMsg)

	if CLIENT then

		if !hradio.errorcatcher.isOpen then
			hradio.errorcatcher.open()
		end

		if (!hradio.errorcatcher.caughtErrors[errorMsg]) then

			net.Start("HCS_ReportError")
			net.WriteString(errorMsg)
			net.SendToServer()

			hradio.errorcatcher.addError(errorMsg)

		end

	else

		net.Start("HCS_ServerError")
		net.WriteString(errorMsg)
		net.Broadcast() -- I don't care if your players get them, server shouldn't be making errors.

	end

end

function hradio.errorcatcher.CatchLater(errorMsg)

	if SERVER then

		net.Start("HCS_ServerStartupError")
		net.WriteString(errorMsg)
		net.Broadcast() -- I don't care if your players get them, server shouldn't be making errors.

	else

		if (!hradio.errorcatcher.startupErrors[errorMsg]) then

			net.Start("HCS_ReportStartupError")
			net.WriteString(errorMsg)
			net.SendToServer()
			
			hradio.errorcatcher.startupErrors[errorMsg] = true

		end

	end

end

if CLIENT then

	function hradio.errorcatcher.onClose()
		hradio.errorcatcher.caughtErrors = {}
		hradio.errorcatcher.isOpen = false
	end

	function hradio.errorcatcher.open()

		local fr = vgui.Create("DFrame")
		fr:DockMargin(20,20,20,20)
		fr:SetSize(600,400)
		fr:SetPos(ScrW()/2-300,ScrH()/2-300)
		fr:MakePopup()
		fr:SetTitle("HCS Error Catcher")

		local lb = vgui.Create("DLabel", fr)
		lb:Dock(TOP)
		lb:SetText("Helios Comms System has caught errors!")
		lb:SetFont("CloseCaption_Bold")
		lb:SetHeight(30)
		lb:Center()
		lb:DockMargin(0,0,0,10)
		lb:SetContentAlignment(5)

		local ps = vgui.Create("DPropertySheet", fr)
		ps:Dock(FILL)

		local fr = vgui.Create("DPanel")
		fr:SetBackgroundColor(Color(0,0,0))
		local fe = vgui.Create("DPanel")
		fe:SetBackgroundColor(Color(0,0,0))

		local re = ps:AddSheet("Runtime Errors", fr)
		local se = ps:AddSheet("Startup Errors", fe)

		local errList = vgui.Create("DScrollPanel", fr)
		errList:Dock(FILL)

		local errListS = vgui.Create("DScrollPanel", fe)
		errListS:Dock(FILL)

		function hradio.errorcatcher.addError(errorMsg)
			if hradio.errorcatcher.caughtErrors[errorMsg] then return end

			hradio.errorcatcher.caughtErrors[errorMsg] = true
			local eLb = vgui.Create("RichText")
			eLb:SetText(errorMsg)
			eLb:Dock(TOP)
			errList:AddItem(eLb)
			eLb:SizeToContents()
			eLb:SetTall(50)
		end

		for errorMsg,_ in pairs(hradio.errorcatcher.startupErrors) do
			local eLb = vgui.Create("RichText")
			eLb:SetText(errorMsg)
			eLb:Dock(TOP)
			errListS:AddItem(eLb)
			eLb:SizeToContents()
			eLb:SetTall(50)
		end

		hradio.errorcatcher.isOpen = true

		function fr.OnClose(self)
			hradio.errorcatcher.onClose()
		end

	end

end