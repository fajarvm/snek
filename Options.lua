local addonName, SNEK = ...

local Settings = _G.Settings
local InterfaceOptions_AddCategory = _G.InterfaceOptions_AddCategory

SNEK.Options = {}
local O = SNEK.Options

local configFrame
local stub
local capturingFor = nil
local captureFrame

local function RefreshBindingLabels()
    if not configFrame then return end

    local function setLabel(key, bindingName)
        local label = configFrame[key .. "BindLabel"]
        if label then
            local current = GetBindingKey(bindingName)
            label:SetText(current and ("|cff00ff00" .. current .. "|r") or "|cffaaaaaaNot bound|r")
        end
    end

    setLabel("toggle", "SNEK_TOGGLE_RECORDER")
    setLabel("reset",  "SNEK_RESET")
    for i = 1, 10 do
        setLabel("key" .. i, "SNEK_KEY" .. i)
    end
end

local function StartKeyCapture(bindingName, friendlyName)
    if capturingFor then return end
    capturingFor = bindingName
    print("|cff00ff00S.N.E.K.:|r Press a key for \"" .. friendlyName .. "\" (ESC = cancel)")

    if not captureFrame then
        captureFrame = CreateFrame("Frame", nil, UIParent)
        captureFrame:EnableKeyboard(true)
        captureFrame:SetPropagateKeyboardInput(false)
        captureFrame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                capturingFor = nil
                self:Hide()
                print("|cffff9900S.N.E.K.:|r Keybind cancelled.")
                return
            end

            local old = GetBindingKey(capturingFor)
            while old do
                SetBinding(old, nil)
                old = GetBindingKey(capturingFor)
            end

            SetBinding(key, capturingFor)
            SaveBindings(GetCurrentBindingSet())

            capturingFor = nil
            self:Hide()
            print("|cff00ff00S.N.E.K.:|r Bound to |cffffff00" .. key .. "|r")
            RefreshBindingLabels()
        end)
    end

    captureFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    captureFrame:Show()
end

local function SaveNumber(box, dbKey)
    local val = tonumber(box:GetText())
    if val and val >= 0 then
        SNEK.DB.Get()[dbKey] = val
    end
end

local function CreateConfigFrame()
    local f = CreateFrame("Frame", "SNEKConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(460, 520)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    f.TitleText:SetText("S.N.E.K. Options")

    -- Scroll frame (leaves room for title bar and bottom help text)
    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 12, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 28)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(400, 720)  -- tall enough for all options
    scrollFrame:SetScrollChild(content)

    local y = -8

    -- Enable
    local enableCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", 8, y)
    enableCheck:SetSize(28, 28)
    local enableLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    enableLabel:SetPoint("LEFT", enableCheck, "RIGHT", 6, 0)
    enableLabel:SetText("Enable S.N.E.K.")
    enableCheck:SetScript("OnClick", function(self)
        local db = SNEK.DB.Get()
        db.enabled = self:GetChecked()
        SNEK_Reset()
        print(db.enabled and "|cff00ff00S.N.E.K.:|r Enabled." or "|cffff9900S.N.E.K.:|r Disabled.")
    end)
    f.enableCheck = enableCheck
    y = y - 36

    -- Timing
    local timingHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    timingHeader:SetPoint("TOPLEFT", 8, y)
    timingHeader:SetText("Timing")
    y = y - 26

    local function MakeNumberRow(text, key)
        local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 18, y)
        label:SetText(text)
        local box = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
        box:SetSize(60, 20)
        box:SetPoint("LEFT", label, "RIGHT", 8, 0)
        box:SetAutoFocus(false)
        box:SetScript("OnTextChanged", function(self) SaveNumber(self, key) end)
        box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        f[key .. "Box"] = box
        y = y - 26
    end

    MakeNumberRow("Initial delay after finalize (seconds):", "initialDelay")
    MakeNumberRow("Delay between messages (seconds):", "delay")
    MakeNumberRow("Sequence limit:", "sequenceLimit")
    y = y - 8

    -- Auto-finalize on limit
    local autoCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    autoCheck:SetPoint("TOPLEFT", 14, y)
    autoCheck:SetSize(24, 24)
    local autoLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    autoLabel:SetPoint("LEFT", autoCheck, "RIGHT", 4, 0)
    autoLabel:SetText("Auto-finalize when sequence limit is reached")
    autoCheck:SetScript("OnClick", function(self)
        SNEK.DB.Get().autoFinalizeOnLimit = self:GetChecked()
    end)
    f.autoCheck = autoCheck
    y = y - 32

    -- Feedback & Minimap & Playback
    local feedHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    feedHeader:SetPoint("TOPLEFT", 8, y)
    feedHeader:SetText("Feedback, Minimap & Playback")
    y = y - 26

    local feedbackCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    feedbackCheck:SetPoint("TOPLEFT", 14, y)
    feedbackCheck:SetSize(24, 24)
    local feedbackLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    feedbackLabel:SetPoint("LEFT", feedbackCheck, "RIGHT", 4, 0)
    feedbackLabel:SetText("Show key-press feedback while recording")
    feedbackCheck:SetScript("OnClick", function(self)
        SNEK.DB.Get().showKeyFeedback = self:GetChecked()
    end)
    f.feedbackCheck = feedbackCheck
    y = y - 26

    local minimapCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    minimapCheck:SetPoint("TOPLEFT", 14, y)
    minimapCheck:SetSize(24, 24)
    local minimapLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    minimapLabel:SetPoint("LEFT", minimapCheck, "RIGHT", 4, 0)
    minimapLabel:SetText("Show minimap icon")
    minimapCheck:SetScript("OnClick", function(self)
        SNEK.DB.Get().showMinimap = self:GetChecked()
        SNEK.Minimap.UpdateVisibility()
    end)
    f.minimapCheck = minimapCheck
    y = y - 26

    local sayCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    sayCheck:SetPoint("TOPLEFT", 14, y)
    sayCheck:SetSize(24, 24)
    local sayLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sayLabel:SetPoint("LEFT", sayCheck, "RIGHT", 4, 0)
    sayLabel:SetText("Playback in /say (requires MessageQueue addon installed)")
    sayCheck:SetScript("OnClick", function(self)
        SNEK.DB.Get().useSayChat = self:GetChecked()
    end)
    f.sayCheck = sayCheck
    y = y - 32

    -- Control Keybindings
    local ctrlHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    ctrlHeader:SetPoint("TOPLEFT", 8, y)
    ctrlHeader:SetText("Control Keys")
    y = y - 26

    local function MakeBindRow(text, which, bindingName)
        local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 18, y)
        label:SetText(text)
        local bindLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        bindLabel:SetPoint("LEFT", label, "RIGHT", 8, 0)
        bindLabel:SetWidth(100)
        bindLabel:SetJustifyH("LEFT")
        f[which .. "BindLabel"] = bindLabel
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(90, 22)
        btn:SetPoint("LEFT", bindLabel, "RIGHT", 6, 0)
        btn:SetText("Set Key")
        btn:SetScript("OnClick", function()
            StartKeyCapture(bindingName, text)
        end)
        y = y - 26
    end

    MakeBindRow("Toggle Recorder:", "toggle", "SNEK_TOGGLE_RECORDER")
    MakeBindRow("Reset / Abort:",   "reset",  "SNEK_RESET")
    y = y - 10

    -- Key labels + bindings
    local keyHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    keyHeader:SetPoint("TOPLEFT", 8, y)
    keyHeader:SetText("Recordable Keys (empty label = ignored)")
    y = y - 26

    for i = 1, 10 do
        local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 18, y)
        label:SetText("Key " .. i .. ":")

        local box = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
        box:SetSize(120, 20)
        box:SetPoint("LEFT", label, "RIGHT", 6, 0)
        box:SetAutoFocus(false)
        box:SetScript("OnTextChanged", function(self)
            SNEK.DB.Get().labels[i] = self:GetText() or ""
        end)
        box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        f["label" .. i .. "Box"] = box

        local bindLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        bindLabel:SetPoint("LEFT", box, "RIGHT", 10, 0)
        bindLabel:SetWidth(90)
        bindLabel:SetJustifyH("LEFT")
        f["key" .. i .. "BindLabel"] = bindLabel

        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(70, 20)
        btn:SetPoint("LEFT", bindLabel, "RIGHT", 4, 0)
        btn:SetText("Set")
        btn:SetScript("OnClick", function()
            StartKeyCapture("SNEK_KEY" .. i, "Key " .. i)
        end)

        y = y - 24
    end

    -- Store content height for potential future use
    content:SetHeight(math.abs(y) + 20)

    -- Reset Sequence button (pinned to outer frame, top-right)
    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetSize(120, 24)
    resetBtn:SetPoint("TOPRIGHT", -20, -36)
    resetBtn:SetText("Reset Sequence")
    resetBtn:SetScript("OnClick", SNEK_Reset)

    -- Help text at bottom of outer frame
    local help = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    help:SetPoint("BOTTOMLEFT", 16, 10)
    help:SetPoint("BOTTOMRIGHT", -16, 10)
    help:SetJustifyH("LEFT")
    help:SetText("Changes are saved automatically.  Scroll for more options.")

    f:SetScript("OnShow", function()
        local db = SNEK.DB.Get()
        f.enableCheck:SetChecked(db.enabled == true)
        f.initialDelayBox:SetText(tostring(db.initialDelay or 3))
        f.delayBox:SetText(tostring(db.delay or 3))
        f.sequenceLimitBox:SetText(tostring(db.sequenceLimit or 7))
        f.autoCheck:SetChecked(db.autoFinalizeOnLimit == true)
        f.feedbackCheck:SetChecked(db.showKeyFeedback ~= false)
        f.minimapCheck:SetChecked(db.showMinimap ~= false)
        f.sayCheck:SetChecked(db.useSayChat == true)
        for i = 1, 10 do
            f["label" .. i .. "Box"]:SetText(db.labels[i] or "")
        end
        RefreshBindingLabels()
        scrollFrame:SetVerticalScroll(0)
    end)

    return f
end

local function BuildStub()
    stub = CreateFrame("Frame", "SNEKStubPanel", UIParent)
    stub.name = "S.N.E.K."

    local title = stub:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("CENTER", stub, "CENTER", 0, 50)
    title:SetText("|cff00ff00S.N.E.K.|r")

    local version = stub:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    version:SetPoint("TOP", title, "BOTTOM", 0, -10)
    version:SetText("Version " .. SNEK.VERSION .. "  –  Sequence Next Enqueued Key")

    local open = CreateFrame("Button", nil, stub)
    open:SetPoint("TOP", version, "BOTTOM", 0, -24)
    local openText = open:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    openText:SetText("/snek")
    open:SetFontString(openText)
    open:SetSize(openText:GetStringWidth() + 16, 28)
    openText:SetPoint("CENTER")
    openText:SetTextColor(1, 0.82, 0)

    open:SetScript("OnEnter", function() openText:SetTextColor(0, 0.9, 1) end)
    open:SetScript("OnLeave", function() openText:SetTextColor(1, 0.82, 0) end)
    open:SetScript("OnClick", function() O.Open() end)

    local hint = stub:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOP", open, "BOTTOM", 0, -16)
    hint:SetText("Click the command above or the minimap button to open options.")
end

function O.Open()
    if not configFrame then
        configFrame = CreateConfigFrame()
    end
    configFrame:Show()
end

function O.Toggle()
    if not configFrame then
        configFrame = CreateConfigFrame()
    end
    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end

function O.Register()
    if stub then return end
    BuildStub()

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(stub, "S.N.E.K.")
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(stub)
    end
end
