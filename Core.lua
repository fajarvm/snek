local addonName, SNEK = ...
SNEK = SNEK or {}

-- Binding display names
_G["BINDING_NAME_SNEK_TOGGLE_RECORDER"] = "Toggle Recorder (Start/Stop)"
_G["BINDING_NAME_SNEK_RESET"]           = "Reset / Abort Sequence"
for i = 1, 10 do
    _G["BINDING_NAME_SNEK_KEY" .. i] = "Key " .. i
end

-- Runtime state
SNEK.sequence = {}
SNEK.isPlaying = false
SNEK.playGeneration = 0

-------------------------------------------------
-- Global functions required by Bindings.xml
-------------------------------------------------
function SNEK_ToggleRecorder()
    if GetCurrentKeyBoardFocus() then return end
    local db = SNEK.DB.Get()
    if not db.enabled then return end

    db.isRecording = not db.isRecording

    if db.isRecording then
        print("|cff00ff00S.N.E.K.:|r Recorder |cff00ff00STARTED|r")
    else
        print("|cff00ff00S.N.E.K.:|r Recorder |cffff9900STOPPED|r (" .. #SNEK.sequence .. " steps)")
    end
end

function SNEK_AddKey(index)
    if GetCurrentKeyBoardFocus() then return end

    local db = SNEK.DB.Get()
    if not db.enabled or not db.isRecording then return end

    local label = db.labels[index]
    if type(label) ~= "string" or label == "" then return end

    -- Sequence limit check
    if #SNEK.sequence >= (tonumber(db.sequenceLimit) or 7) then
        db.isRecording = false
        print("|cffff9900S.N.E.K.:|r Sequence limit reached (" .. db.sequenceLimit .. "). Recorder stopped.")
        if db.autoFinalizeOnLimit then
            SNEK_Finalize()
        end
        return
    end

    table.insert(SNEK.sequence, label)

    if db.showKeyFeedback then
        print("|cff00ff00S.N.E.K.:|r + '" .. label .. "'  (" .. #SNEK.sequence .. "/" .. db.sequenceLimit .. ")")
    end

    -- Check limit again after adding
    if #SNEK.sequence >= (tonumber(db.sequenceLimit) or 7) then
        db.isRecording = false
        print("|cffff9900S.N.E.K.:|r Sequence limit reached. Recorder stopped.")
        if db.autoFinalizeOnLimit then
            SNEK_Finalize()
        end
    end
end

function SNEK_Finalize()
    local db = SNEK.DB.Get()
    if not db.enabled then return end

    local seq = SNEK.sequence
    if #seq == 0 then
        print("|cffff9900S.N.E.K.:|r Nothing to play.")
        return
    end
    if SNEK.isPlaying then
        print("|cffff9900S.N.E.K.:|r Already playing.")
        return
    end

    local delay = tonumber(db.delay) or 3
    local initialDelay = tonumber(db.initialDelay) or 3

    local snapshot = {}
    for i, v in ipairs(seq) do
        snapshot[i] = v
    end
    wipe(seq)
    db.isRecording = false

    SNEK.isPlaying = true
    SNEK.playGeneration = SNEK.playGeneration + 1
    local gen = SNEK.playGeneration

    print("|cff00ff00S.N.E.K.:|r Sequence locked (" .. #snapshot .. " steps). Starting in " .. initialDelay .. "s...")

    local i = 1
    local function nextStep()
        if gen ~= SNEK.playGeneration then return end
        if i > #snapshot then
            SNEK.isPlaying = false
            print("|cff00ff00S.N.E.K.:|r Playback finished.")
            return
        end
        print(snapshot[i])
        i = i + 1
        if i <= #snapshot then
            C_Timer.After(delay, nextStep)
        else
            SNEK.isPlaying = false
            print("|cff00ff00S.N.E.K.:|r Playback finished.")
        end
    end

    C_Timer.After(initialDelay, nextStep)
end

function SNEK_Reset()
    SNEK.playGeneration = SNEK.playGeneration + 1
    SNEK.isPlaying = false
    wipe(SNEK.sequence)
    local db = SNEK.DB.Get()
    db.isRecording = false
    print("|cff00ff00S.N.E.K.:|r Sequence cleared & playback stopped.")
end

-- Manual finalize can still be triggered via slash if desired
-- (kept internal for auto-finalize on limit)

-------------------------------------------------
-- Initialization
-------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end

    SNEK.DB.Init()
    SNEK.Minimap.Create()
    SNEK.Options.Register()

    local status = SNEK.DB.Get().enabled and "|cff00ff00enabled|r" or "|cffff9900disabled|r"
    print("|cff00ff00S.N.E.K.|r v0.7 loaded (" .. status .. ").")
    print("  Type |cffffff00/snek|r for commands.")

    self:UnregisterEvent("ADDON_LOADED")
end)