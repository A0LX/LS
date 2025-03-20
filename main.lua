_G.LSDropper = {
    -- Controllers: Enter the user IDs (or names) allowed to control the bots
    Controllers = {
        "7451107665",
    },
    
    -- alts: Put all alt user IDs here
    alts = {
        8055468531,
        7178503675,
        7707204045,
        7707164601,
        7707264889,
        8055473927,
        7707209002,
        3034352629,
    },
    
    -- Prefix: Enter the prefix before each command.
    Prefix = "/"
}

-- Loader: Loads the main script logic
loadstring(game:HttpGet("https://raw.githubusercontent.com/LS-AltControl/LS-Control/refs/heads/main/Loader.lua"))()
