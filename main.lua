script_key = 'joIBLGqlUfbonOcQoYjMtYfclJUbDVVQ'
getgenv().AutofarmSettings = {
    ["Fps"] = 10,
    ["InstaTP"] = true,
    ["Underground"] = true,

    ["Webhook"] = {
        ["URL"] = "https://discord.com/api/webhooks/1349392866446807050/GGyeqFg5e8JxllAJWpyxFRAT4DZWxMQVTmDMg9cCLFctrJDSQ-hp5lqIzPOVANpT2lTF",
        ["Interval"] = 10
    },

    ["Serverhop"] = {
        ["Cycle"]   = 25,        -- 1 = After dying once.
        ["Time"]    = 0,        -- 1 = After 1 Minute.
        ["Kick"]    = false,    -- true = After getting kicked.
        ["Blacklisted_IDs"] = { 241714165, 7707159035, 7707263046, 7707251668, 8055468531, 2939174150, 7707209002, 7178503675, 8055473927, 2827160867, 8055446371, 7707261230, 228432957, 3034352629, 7707264889, 7707164601, 7707204045, 8195210, 439942262, 93101606, 163721789, 3944434729, 4255947062, 1830168970, 29242182 } -- If UserID was found ingame, Detects new joining players too.
    },
    " warlocks atm farm - @snuffing "
}
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/2f5a5d4b9fc7ed0f115580a53bfab777.lua"))()
