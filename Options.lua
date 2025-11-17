local addonName, addonTable = ...
local DominosFader = addonTable.DominosFader
local MAS = addonTable.MAS

-- Create options panel
local optionsPanel = CreateFrame("Frame", "DominosFaderOptions", UIParent)
optionsPanel.name = "Fader"
optionsPanel.parent = "Dominos"

-- Add to Interface Options
if Settings and Settings.RegisterCanvasLayoutCategory then
    -- Dragonflight+ API
    local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
    category.ID = optionsPanel.name
    Settings.RegisterAddOnCategory(category)
else
    -- Classic API
    InterfaceOptions_AddCategory(optionsPanel)
end

-- Title
local title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Dominos Fader - MouseOver Settings")

-- Subtitle
local subtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Configure mouseover fading triggers for your Dominos action bars")

-- Scroll frame for bar list
local scrollFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -20)
scrollFrame:SetPoint("BOTTOMRIGHT", optionsPanel, "BOTTOMRIGHT", -30, 60)

local scrollChild = CreateFrame("Frame")
scrollChild:SetSize(600, 1)
scrollFrame:SetScrollChild(scrollChild)

-- Store bar checkboxes
local barConfigs = {}

-- Event options
local eventOptions = {
    {key = "COMBAT_UPDATE", label = "In Combat", tooltip = "Show bar when in combat"},
    {key = "TARGET_UPDATE", label = "Target Exists", tooltip = "Show bar when you have a target"},
    {key = "FOCUS_UPDATE", label = "Focus Exists", tooltip = "Show bar when you have a focus target"},
    {key = "MOUNT_UPDATE", label = "Mounted", tooltip = "Show bar when mounted"},
    {key = "PLAYER_MOVING_UPDATE", label = "Moving", tooltip = "Show bar when moving"},
    {key = "NPC_UPDATE", label = "Talking to NPC", tooltip = "Show bar when interacting with NPCs"},
    {key = "DRAGONRIDING_UPDATE", label = "Dragonriding", tooltip = "Show bar when dragonriding"},
    {key = "CASTING_UPDATE", label = "Casting", tooltip = "Show bar when casting"},
    {key = "EDIT_MODE_UPDATE", label = "Edit Mode", tooltip = "Show bar in edit mode"},
    {key = "GRID_UPDATE", label = "Grid Mode", tooltip = "Show bar in grid mode"},
}

-- Function to create a bar config section
local function CreateBarConfig(parent, barId, moduleName, yOffset)
    local config = CreateFrame("Frame", nil, parent)
    config:SetSize(580, 140)
    config:SetPoint("TOPLEFT", 10, yOffset)
    config:Show()
    
    -- Background
    local bg = config:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Bar title
    local barTitle = config:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    barTitle:SetPoint("TOPLEFT", 10, -10)
    barTitle:SetText("Action Bar " .. barId)
    
    -- Enable/Disable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, config, "InterfaceOptionsCheckButtonTemplate")
    enableCheck:SetPoint("TOPRIGHT", -10, -8)
    enableCheck.Text:SetText("Enabled")
    
    -- Store checkboxes
    config.checkboxes = {}
    
    -- Create event checkboxes in a grid
    local col = 0
    local row = 0
    for i, eventData in ipairs(eventOptions) do
        local check = CreateFrame("CheckButton", nil, config, "InterfaceOptionsCheckButtonTemplate")
        check:SetPoint("TOPLEFT", 20 + (col * 140), -40 - (row * 25))
        check.Text:SetText(eventData.label)
        check.tooltip = eventData.tooltip
        check.eventKey = eventData.key
        
        config.checkboxes[eventData.key] = check
        
        col = col + 1
        if col >= 4 then
            col = 0
            row = row + 1
        end
    end
    
    config.moduleName = moduleName
    config.enableCheck = enableCheck
    
    return config
end

-- Function to refresh the config panel
function optionsPanel:Refresh()
    -- Safety check
    if not MAS or not MAS.db or not MAS.db.profile then
        C_Timer.After(0.5, function() optionsPanel:Refresh() end)
        return
    end
    
    -- Clear existing configs
    for _, config in pairs(barConfigs) do
        config:Hide()
        config:SetParent(nil)
    end
    barConfigs = {}
    
    -- Create config for each action bar
    local yOffset = -10
    for barId = 1, 10 do
        local moduleName = "Dominos_ActionBar" .. barId
        if MAS.db.profile[moduleName] then
            local config = CreateBarConfig(scrollChild, barId, moduleName, yOffset)
            barConfigs[barId] = config
            
            -- Load current settings
            local dbObj = MAS.db.profile[moduleName]
            config.enableCheck:SetChecked(dbObj.enabled ~= false)
            
            for eventKey, checkbox in pairs(config.checkboxes) do
                checkbox:SetChecked(dbObj[eventKey] == true)
            end
            
            yOffset = yOffset - 150
        end
    end
    
    -- If no bars were found, show a message
    if yOffset == -10 then
        local noDataText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        noDataText:SetPoint("TOP", 0, -50)
        noDataText:SetText("No action bars configured yet.\n\nAction bars will appear here after you\ncreate them in Dominos.")
        noDataText:SetTextColor(1, 1, 0)
    end
    
    scrollChild:SetHeight(math.max(400, math.abs(yOffset) + 150))
end

-- Apply button
local applyBtn = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
applyBtn:SetPoint("BOTTOMRIGHT", -16, 16)
applyBtn:SetSize(120, 25)
applyBtn:SetText("Apply Changes")
applyBtn:SetScript("OnClick", function()
    for barId, config in pairs(barConfigs) do
        local moduleName = config.moduleName
        local dbObj = MAS.db.profile[moduleName]
        
        if not dbObj then return end
        
        -- Update enabled state
        dbObj.enabled = config.enableCheck:GetChecked()
        
        -- Update event triggers
        for eventKey, checkbox in pairs(config.checkboxes) do
            dbObj[eventKey] = checkbox:GetChecked()
        end
        
        -- Reload the module
        local module = MAS:GetModule(moduleName, true)
        if module then
            if dbObj.enabled then
                if module:IsEnabled() then
                    module:Disable()
                end
                module:Enable()
            else
                module:Disable()
            end
        end
    end
    
    print("Dominos_Fader: Settings applied!")
end)

-- Reset button
local resetBtn = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
resetBtn:SetPoint("RIGHT", applyBtn, "LEFT", -10, 0)
resetBtn:SetSize(100, 25)
resetBtn:SetText("Reset All")
resetBtn:SetScript("OnClick", function()
    StaticPopup_Show("DOMINOS_FADER_RESET")
end)

-- Reset confirmation dialog
StaticPopupDialogs["DOMINOS_FADER_RESET"] = {
    text = "Reset all Dominos Fader settings to MouseOverActionSettings defaults?\n\nThis will clear all trigger settings and let MAS use its default behavior.",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        for barId = 1, 10 do
            local moduleName = "Dominos_ActionBar" .. barId
            if MAS.db.profile[moduleName] then
                local dbObj = MAS.db.profile[moduleName]
                dbObj.enabled = true
                
                -- Clear all event overrides to let MAS use its defaults
                for _, eventData in ipairs(eventOptions) do
                    dbObj[eventData.key] = nil
                end
                
                -- Reload module
                local module = MAS:GetModule(moduleName, true)
                if module then
                    module:Disable()
                    module:Enable()
                end
            end
        end
        
        optionsPanel:Refresh()
        print("Dominos_Fader: Settings reset to MAS defaults")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Quick Setup button
local quickSetupBtn = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
quickSetupBtn:SetPoint("BOTTOMLEFT", 16, 16)
quickSetupBtn:SetSize(150, 25)
quickSetupBtn:SetText("Quick Setup")
quickSetupBtn:SetScript("OnClick", function()
    StaticPopup_Show("DOMINOS_FADER_QUICKSETUP")
end)

-- Quick setup dialog
StaticPopupDialogs["DOMINOS_FADER_QUICKSETUP"] = {
    text = "Enable Combat, Target, and Focus triggers for all bars?",
    button1 = "Yes",
    button2 = "Cancel",
    OnAccept = function()
        for barId = 1, 10 do
            local moduleName = "Dominos_ActionBar" .. barId
            if MAS.db.profile[moduleName] then
                local dbObj = MAS.db.profile[moduleName]
                dbObj.enabled = true
                dbObj.COMBAT_UPDATE = true
                dbObj.TARGET_UPDATE = true
                dbObj.FOCUS_UPDATE = true
                
                local module = MAS:GetModule(moduleName, true)
                if module then
                    module:Disable()
                    module:Enable()
                end
            end
        end
        
        optionsPanel:Refresh()
        print("Dominos_Fader: Quick setup complete - Combat, Target, and Focus enabled for all bars")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Refresh when panel is shown
optionsPanel:SetScript("OnShow", function(self)
    self:Refresh()
end)

-- Store reference
addonTable.optionsPanel = optionsPanel

-- Slash command to open config
_G["SLASH_DOMINOSFADERCONFIG1"] = "/dfc"
SlashCmdList["DOMINOSFADERCONFIG"] = function()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(optionsPanel.name)
    else
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
    end
end
