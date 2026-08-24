local _, SNEK = ...

SNEK.DB = {}

local DEFAULTS = {
    enabled = false,
    isRecording = false,
    delay = 3,
    initialDelay = 3,
    sequenceLimit = 7,
    autoFinalizeOnLimit = false,   -- false = just stop recording, true = auto-finalize
    showMinimap = true,
    showKeyFeedback = true,
    labels = {
        [1] = "left",
        [2] = "right",
        [3] = "forward",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
        [9] = "",
        [10] = "",
    },
    minimapAngle = 220,
}

function SNEK.DB.Init()
    if not SNEKDB then
        SNEKDB = {}
    end

    local db = SNEKDB

    for k, v in pairs(DEFAULTS) do
        if db[k] == nil then
            if type(v) == "table" then
                db[k] = {}
                for mk, mv in pairs(v) do
                    db[k][mk] = mv
                end
            else
                db[k] = v
            end
        end
    end

    if type(db.labels) ~= "table" then
        db.labels = {}
    end
    for i = 1, 10 do
        if db.labels[i] == nil then
            db.labels[i] = DEFAULTS.labels[i] or ""
        end
    end
end

function SNEK.DB.Get()
    if not SNEKDB then
        SNEK.DB.Init()
    end
    return SNEKDB
end