-- your workshop collection id --
simplemount.config.workshopCollectionId = 3061951895

-- skips the user interaction and downloads + mounts the workshop automatically
-- this will also disable the popup menu and chat command
-- default; false
simplemount.config.autoDownload = false

-- print out to chat when a player is missing collection subscriptions --
-- true/false ; default: false
simplemount.config.chatPrints = true

-- open the main menu if a player is missing content --
-- true/false ; default: true
simplemount.config.openWindowAuto = true

-- enable/disable the "don't show me again box on the menu"
-- true/false ; default: true
simplemount.config.dontOpenAgainBox = true

-- chat command to open main menu
-- string ; default: "!mount"
simplemount.config.chatCommand = "!montar"

-- play roll over button sounds
-- default; true
simplemount.config.rollOverSounds = true

-- play roll over button click sounds
-- default; true
simplemount.config.buttonClickSound = true

-- admins ranks.. who can open the admin menu?
-- default: 
simplemount.config.adminRanks = {
    "founder",
    "owner",
    "superadmin",
}

-- color theme -- 
simplemount.config.colors = {
    close_button = {
        primary = Color(220, 40, 40, 255),
        text_color = Color(255, 255, 255, 255),
        font = "DermaDefault"
    },
    scrollbar = {
        up = Color(35, 35, 35),
        down = Color(35, 35, 35),
        grip = Color(40, 40, 40),
        background = Color(10, 10, 10, 200),
    },
    titleBar = {
        color = Color(50, 50, 50),
    },
    main_menu = {
        bg = Color(26, 26, 26),
        gradient = Color(35, 35, 35),
    },
    button = {
        paint = Color(45, 45, 45, 175),
        paint_dark = Color(32, 32, 32, 255),
    },
    admin = {
        panel = Color(45, 45, 45, 175),
    }
}

simplemount.config.text = {
    title = "Simple Mount",
    open_collection = "Open Collection",
    mount_all = "Download & Mount (temporary)",
    mount = "Mount",
    download = "Download",
    close = "X",
    ignore = "Ignore (Decline)",
    error_fetching = "Sorry, we could not fetch the latest workshop content for you!",
    missing = "You are missing content to play this server!",
    loading = "Attempting to load server's content collection for you...",
    downloading_collection = "Downloading collection...",
    admin_cp = "Admin",
    up_to_date = "Great news, you have all our content!",
    force_download = "Force Download",
    check_missing = "Check Missing Content",
    not_valid = "[SimpleMount] Not a valid player!",
    downloading_now = "[SimpleMount][Admin] %s is downloading any missing content from the collection!", -- KEEP %s
    not_missing = "[SimpleMount][Admin] %s is *not* missing any content from the collection!", -- KEEP %s
    missing_content = "[SimpleMount][Admin] %s is *missing* content from the collection!", -- KEEP %s
}