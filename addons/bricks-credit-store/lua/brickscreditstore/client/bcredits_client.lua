local function GetImageFromURL( url )
    local CRC = util.CRC( url )
    local Extension = string.Split( url, "." )
    Extension = Extension[#Extension] or "png"

    if( not file.Exists( "brickscreditstore/images", "DATA" ) ) then
        file.CreateDir( "brickscreditstore/images" )
    end
    
    if( file.Exists( "brickscreditstore/images/" .. CRC .. "." .. Extension, "DATA" ) ) then
        return Material( "data/brickscreditstore/images/" .. CRC .. "." .. Extension, "noclamp smooth" )
    else
        http.Fetch( url, function( body )
            file.Write( "brickscreditstore/images/" .. CRC .. "." .. Extension, body )
            BRICKSCREDITSTORE.CachedMaterials[CRC] = Material( "data/brickscreditstore/images/" .. CRC .. "." .. Extension, "noclamp smooth" )
            return Material( "data/brickscreditstore/images/" .. CRC .. "." .. Extension, "noclamp smooth" )
        end )
    end
end

BRICKSCREDITSTORE.CachedMaterials = {}

function BRICKSCREDITSTORE.GetImage( url, dontContinue )
    local CRC = util.CRC( url )
    if( CRC and BRICKSCREDITSTORE.CachedMaterials[CRC] and type( BRICKSCREDITSTORE.CachedMaterials[CRC] ) == "IMaterial" ) then
        return BRICKSCREDITSTORE.CachedMaterials[CRC]
    elseif( not dontContinue and CRC and not BRICKSCREDITSTORE.CachedMaterials[CRC] ) then
        BRICKSCREDITSTORE.CachedMaterials[CRC] = GetImageFromURL( url )
        return BRICKSCREDITSTORE.GetImage( url, true )
    else
        return Material( "materials/brickscreditstore/error.png" )
    end
end

function BRICKSCREDITSTORE.OpenStore( NPCType )
    if( not BRICKSCREDITSTORE.CONFIG.NPCs[NPCType] ) then return end

    if( IsValid( BCREDITSTORE_MENU ) ) then
        BCREDITSTORE_MENU:Remove()
    end

    BCREDITSTORE_MENU = vgui.Create( "brcs_vgui_shop" )
    BCREDITSTORE_MENU:SetNPCType( NPCType )
end

function BRICKSCREDITSTORE.RefreshLocker()
    if( IsValid( BCREDITSTORE_MENU ) and BCREDITSTORE_MENU.RefreshLocker ) then
        BCREDITSTORE_MENU:RefreshLocker()
    end
end

local function GetCMDs()
    local CMDs = {}
    for k, v in pairs( BRICKSCREDITSTORE.CONFIG.NPCs ) do
        if( v.CMD ) then
            CMDs[v.CMD] = k
        end
    end

    return CMDs
end

hook.Add( "OnPlayerChat", "BRCSHooks_OnPlayerChat_MenuCMD", function( ply, text, teamC, dead )
    if( GetCMDs()[text] ) then
        if( ply == LocalPlayer() ) then
            BRICKSCREDITSTORE.OpenStore( GetCMDs()[text] )
        end

        return true
    end
end )

local function GetBinds()
    local Binds = {}
    for k, v in pairs( BRICKSCREDITSTORE.CONFIG.NPCs ) do
        if( v.Bind ) then
            Binds[v.Bind] = k
        end
    end

    return Binds
end

hook.Add( "PlayerButtonDown", "BRCSHooks_PlayerButtonDown_MenuBind", function( ply, key )
    if( GetBinds()[key] ) then
        BRICKSCREDITSTORE.OpenStore( GetBinds()[key] )
    end
end )

net.Receive( "BRCS_Net_Notify", function( len, ply )
    local Message = net.ReadString()

    if( not Message ) then return end

    notification.AddLegacy( Message, 1, 3 )
end )

hook.Add( "HUDPaint", "BRCSHooks_HUDPaint_DrawCredits", function()
    if( not BRICKSCREDITSTORE.LUACONFIG.DisableHUD ) then
        draw.SimpleText( BRICKSCREDITSTORE.FormatCredits( LocalPlayer():GetBRCS_Credits() ), "DermaLarge", 25, 25, Color( 255, 255, 255 ), 0, 0 ) 
    end
end )

function BRICKSCREDITSTORE.DrawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

BRCS_SWIDTH = ScrW()*0.7
BRCS_SWIDTH_SCALE, BRCS_SHEIGHT_SCALE = BRCS_SWIDTH/3960, (BRCS_SWIDTH*0.5625)/2790

surface.CreateFont( "BRCS_MP_30", {
	font = "Myriad Pro",
	size = 30,
	weight = 2500,
	antialias = true,
} )

surface.CreateFont( "BRCS_MP_26", {
	font = "Myriad Pro",
	size = 26,
	weight = 2500,
	antialias = true,
} )

surface.CreateFont( "BRCS_MP_24", {
	font = "Myriad Pro",
	size = 24,
	weight = 2500,
	antialias = true,
} )

surface.CreateFont( "BRCS_MP_22", {
	font = "Myriad Pro",
	size = 22,
	weight = 2500,
	antialias = true,
} )

surface.CreateFont( "BRCS_MP_20", {
	font = "Myriad Pro",
	size = 20,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "BRCS_MP_16", {
	font = "MyriadPro-Regular",
	size = 16,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "BRCS_MP_15", {
	font = "MyriadPro-Regular",
	size = 15,
	weight = 500,
	antialias = true,
} )

net.Receive( "BRCS_Net_OpenAdmin", function()
    if( IsValid( BCREDITSTORE_ADMIN_MENU ) ) then
        BCREDITSTORE_ADMIN_MENU:Remove()
    end

    BCREDITSTORE_ADMIN_MENU = vgui.Create( "brcs_vgui_admin" )
end )

net.Receive( "BRCS_Net_SendConfig", function( len, ply )
	local configCompressed = net.ReadData( len )
    local configUnCompressed = util.JSONToTable( util.Decompress( configCompressed ) )
    
    BRICKSCREDITSTORE.CONFIG = configUnCompressed
end )

BRICKSCREDITSTORE.KeyBinds = {
    [1] = "None",
    [KEY_F1] = "F1",
    [KEY_F2] = "F2",
    [KEY_F3] = "F3",
    [KEY_F4] = "F4",
    [KEY_F5] = "F5",
    [KEY_F6] = "F6",
    [KEY_F7] = "F7",
    [KEY_F8] = "F8",
    [KEY_F9] = "F9",
    [KEY_F10] = "F10",
    [KEY_F11] = "F11",
    [KEY_F12] = "F12"
}