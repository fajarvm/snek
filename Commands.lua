local _, SNEK = ...

local function Dispatch(msg)
    msg = strtrim(string.lower(msg or ""))

    if msg == "" or msg == "options" or msg == "config" then
        SNEK.Options.Open()
    elseif msg == "minimap" then
        local db = SNEK.DB.Get()
        db.showMinimap = not db.showMinimap
        SNEK.Minimap.UpdateVisibility()
        print("|cff00ff00S.N.E.K.:|r Minimap icon " .. (db.showMinimap and "shown" or "hidden") .. ".")
    elseif msg == "on" then
        local db = SNEK.DB.Get()
        db.enabled = true
        SNEK_Reset()
        print("|cff00ff00S.N.E.K.:|r Enabled.")
    elseif msg == "off" then
        local db = SNEK.DB.Get()
        db.enabled = false
        SNEK_Reset()
        print("|cffff9900S.N.E.K.:|r Disabled.")
    elseif msg == "reset" then
        SNEK_Reset()
    elseif msg == "version" then
        print("|cff00ff00S.N.E.K.|r version " .. SNEK.VERSION)
    elseif msg == "help" then
        print("|cff00ff00S.N.E.K. commands:|r")
        print("  /snek options   - open options panel")
        print("  /snek minimap   - toggle minimap icon")
        print("  /snek on        - enable the addon")
        print("  /snek off       - disable the addon")
        print("  /snek reset     - clear current sequence")
        print("  /snek version   - show version")
        print("  /snek help      - show this help")
    else
        print("|cff00ff00S.N.E.K.:|r Unknown command. Type |cffffff00/snek help|r")
    end
end

SLASH_SNEK1 = "/snek"
SlashCmdList["SNEK"] = Dispatch
