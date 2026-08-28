local addonName, SNEK = ...
SNEK = SNEK or {}

-- Single source of truth for the version string
SNEK.VERSION = "0.8.5"

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

    if db.isRecording then
        -- Turning OFF → stop recording and auto-start playback if we have steps
        db.isRecording = false
        local count = #SNEK.sequence
        print("|cff00ff00S.N.E.K.:|r Recorder |cffff9900STOPPED|r (" .. count .. " steps)")
        if count > 0 then
            SNEK_Finalize()
        end
    else
        -- Turning ON
        db.isRecording = true
        print("|cff00ff00S.N.E.K.:|r Recorder |cff00ff00STARTED|r")
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

    local delay = tonumber(db.delay) or 2.8
    local initialDelay = tonumber(db.initialDelay) or 2.5

    local snapshot = {}
    for i, v in ipairs(seq) do
        snapshot[i] = v
    end
    wipe(seq)
    db.isRecording = false

    SNEK.isPlaying = true
    SNEK.playGeneration = SNEK.playGeneration + 1
    local gen = SNEK.playGeneration

    -- Decide output mode once at the start of playback
    local useSay = db.useSayChat and MessageQueue
    if db.useSayChat and not MessageQueue then
        print("|cffff9900S.N.E.K.:|r MessageQueue not found – falling back to local print.")
        useSay = false
    end

    local modeText = useSay and "SAY" or "local print"
    print("|cff00ff00S.N.E.K.:|r Sequence locked (" .. #snapshot .. " steps, " .. modeText .. "). Starting in " .. initialDelay .. "s...")

    local i = 1

    local function finish()
        if gen ~= SNEK.playGeneration then return end
        SNEK.isPlaying = false
        print("|cff00ff00S.N.E.K.:|r Playback finished.")
    end

    local function nextStep()
        if gen ~= SNEK.playGeneration then return end
        if i > #snapshot then
            finish()
            return
        end

        local text = snapshot[i]
        i = i + 1

        if useSay then
            -- Queue the SAY message; continue the chain from the callback
            -- (after the message has actually been sent via hardware event)
            MessageQueue.SendChatMessage(text, "SAY", nil, nil, function()
                if gen ~= SNEK.playGeneration then return end
                if i <= #snapshot then
                    C_Timer.After(delay, nextStep)
                else
                    finish()
                end
            end)
        else
            -- Classic local print path
            print(text)
            if i <= #snapshot then
                C_Timer.After(delay, nextStep)
            else
                finish()
            end
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
    print("|cff00ff00S.N.E.K.|r v" .. SNEK.VERSION .. " loaded (" .. status .. ").")
    print("  Type |cffffff00/snek|r for commands.")

    self:UnregisterEvent("ADDON_LOADED")
end)
