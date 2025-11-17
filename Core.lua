local addonName, addonTable = ...

-- Get references to required addons
local Dominos = LibStub("AceAddon-3.0"):GetAddon("Dominos")
local MAS = LibStub("AceAddon-3.0"):GetAddon("MouseoverActionSettings")

if not Dominos or not MAS then
    print (addonName .. ": Dominos or MouseoverActionSettings not found. Disabling addon.")
    return
end

-- Create our addon module
local DominosFader = Dominos:NewModule("DominosFader", "AceEvent-3.0")
addonTable.DominosFader = DominosFader

-- Store references
addonTable.Dominos = Dominos
addonTable.MAS = MAS

-- Table to store registered bars
DominosFader.registeredBars = {}

function DominosFader:OnInitialize()
    print("Dominos_Fader: MouseOverActionSettings support enabled")
    
    -- Create a custom category in MAS for Dominos bars
    if MAS.db and MAS.db.profile then
        -- Initialize Dominos category if it doesn't exist
        if not MAS.db.profile.dominosCategory then
            MAS.db.profile.dominosCategory = {}
        end
    end
end

function DominosFader:OnEnable()
    -- Register callbacks for when bars are created/destroyed
    Dominos.RegisterCallback(self, "BAR_CREATED", "OnBarCreated")
    Dominos.RegisterCallback(self, "BAR_FREED", "OnBarFreed")
    
    -- Register existing bars
    for id, frame in Dominos.Frame:GetAll() do
        self:RegisterBar(frame)
    end
    
    -- Register slash command to refresh all Dominos bars
    SLASH_DOMINOSFADER1 = "/dominosfader"
    SLASH_DOMINOSFADER2 = "/df"
    SlashCmdList["DOMINOSFADER"] = function(msg)
        if msg == "refresh" or msg == "reload" then
            DominosFader:RefreshAllBars()
            print("Dominos_Fader: Refreshed all bar settings")
        elseif msg == "debug" then
            -- Debug: print settings for first action bar
            local moduleName = "Dominos_ActionBar1"
            if MAS.db and MAS.db.profile and MAS.db.profile[moduleName] then
                print("Debug for " .. moduleName .. ":")
                local dbObj = MAS.db.profile[moduleName]
                for k, v in pairs(dbObj) do
                    print("  " .. k .. " = " .. tostring(v))
                end
                
                -- Also check if there's a separate triggers table
                print("Checking module object:")
                local module = MAS:GetModule(moduleName, true)
                if module then
                    print("  Module exists: " .. tostring(module:IsEnabled()))
                end
                
                -- Check the mouseover unit
                local data = DominosFader.registeredBars[1]
                if data and data.mo_unit then
                    print("Mouseover unit statusEvents:")
                    if data.mo_unit.statusEvents then
                        for i, event in ipairs(data.mo_unit.statusEvents) do
                            print("  [" .. i .. "] = " .. event)
                        end
                    else
                        print("  No statusEvents table!")
                    end
                end
            else
                print("No settings found for " .. moduleName)
            end
        elseif msg:match("^set ") then
            -- Manual command to set an event: /df set TARGET_UPDATE
            -- Or set for specific bar: /df set 2 TARGET_UPDATE
            local barNum, event = msg:match("^set (%d+) (.+)")
            if not barNum then
                -- No bar number specified, default to bar 1
                barNum = "1"
                event = msg:match("^set (.+)")
            end
            
            if event then
                local moduleName = "Dominos_ActionBar" .. barNum
                if not MAS.db.profile[moduleName] then
                    print("Error: Bar " .. barNum .. " not found")
                    return
                end
                
                MAS.db.profile[moduleName][event] = true
                print("Set " .. moduleName .. "." .. event .. " = true")
                
                -- Force disable and re-enable the module
                local module = MAS:GetModule(moduleName, true)
                if module then
                    module:Disable()
                    module:Enable()
                    print("Reloaded module")
                end
            end
        elseif msg:match("^enable ") then
            -- Enable multiple events at once: /df enable 1 COMBAT TARGET FOCUS
            local barNum = msg:match("^enable (%d+)")
            if barNum then
                local moduleName = "Dominos_ActionBar" .. barNum
                if not MAS.db.profile[moduleName] then
                    print("Error: Bar " .. barNum .. " not found")
                    return
                end
                
                local events = {msg:match("^enable %d+ (.+)")}
                local eventStr = events[1]
                if eventStr then
                    local count = 0
                    for event in eventStr:gmatch("%S+") do
                        local fullEvent = event:upper()
                        if not fullEvent:match("_UPDATE$") then
                            fullEvent = fullEvent .. "_UPDATE"
                        end
                        MAS.db.profile[moduleName][fullEvent] = true
                        print("  Enabled " .. fullEvent)
                        count = count + 1
                    end
                    
                    if count > 0 then
                        -- Reload the module
                        local module = MAS:GetModule(moduleName, true)
                        if module then
                            module:Disable()
                            module:Enable()
                            print("Reloaded " .. moduleName .. " with " .. count .. " events")
                        end
                    end
                end
            end
        elseif msg == "setall" then
            -- Enable common triggers for all action bars (1-10)
            local events = {"COMBAT_UPDATE", "TARGET_UPDATE", "FOCUS_UPDATE"}
            for barId = 1, 10 do
                local moduleName = "Dominos_ActionBar" .. barId
                if MAS.db.profile[moduleName] then
                    for _, event in ipairs(events) do
                        MAS.db.profile[moduleName][event] = true
                    end
                    local module = MAS:GetModule(moduleName, true)
                    if module then
                        module:Disable()
                        module:Enable()
                    end
                    print("Configured " .. moduleName)
                end
            end
            print("All action bars configured with Combat, Target, and Focus triggers")
        else
            print("Dominos_Fader commands:")
            print("  /dfc - Open configuration panel")
            print("  /df refresh - Reload all bar settings")
            print("  /df debug - Show settings for Action Bar 1")
            print("  /df set <EVENT> - Enable event for bar 1")
            print("  /df set <bar#> <EVENT> - Enable event for specific bar")
            print("  /df enable <bar#> <events> - Enable multiple events")
            print("  /df setall - Enable Combat, Target, and Focus for all bars")
        end
    end
end

function DominosFader:OnDisable()
    -- Unregister all bars
    for id, data in pairs(self.registeredBars) do
        self:UnregisterBar(id)
    end
end

function DominosFader:RefreshAllBars()
    -- Refresh settings for all registered bars
    for id, data in pairs(self.registeredBars) do
        if data.mas_module and data.mas_module.Refresh then
            data.mas_module:Refresh()
        end
    end
end

function DominosFader:OnBarCreated(event, bar, id)
    self:RegisterBar(bar)
end

function DominosFader:OnBarFreed(event, bar, id)
    self:UnregisterBar(id)
end

function DominosFader:RegisterBar(bar)
    if not bar or self.registeredBars[bar.id] then
        return
    end
    
    -- Check if this bar type is supported
    local barType = self:GetBarType(bar.id)
    if not barType then
        return
    end
    
    -- Create the bar registration data
    local registrationData = {
        bar = bar,
        barType = barType,
        moduleHandler = nil
    }
    
    self.registeredBars[bar.id] = registrationData
    
    -- Notify the specific module handler to set up the bar
    local moduleFile = addonTable.modules and addonTable.modules[barType]
    if moduleFile and moduleFile.RegisterBar then
        registrationData.moduleHandler = moduleFile
        moduleFile:RegisterBar(bar, registrationData)
    end
end

function DominosFader:UnregisterBar(id)
    local data = self.registeredBars[id]
    if not data then
        return
    end
    
    -- Unregister from the module handler
    if data.moduleHandler and data.moduleHandler.UnregisterBar then
        data.moduleHandler:UnregisterBar(data.bar)
    end
    
    self.registeredBars[id] = nil
end

function DominosFader:GetBarType(barId)
    -- Map Dominos bar IDs to types
    if type(barId) == "number" then
        return "action"
    elseif barId == "pet" then
        return "pet"
    elseif barId == "class" then
        return "stance"
    elseif barId == "bags" then
        return "bag"
    elseif barId == "menu" then
        return "menu"
    elseif barId == "extra" then
        return "extra"
    end
    
    return nil
end

-- Helper function to get buttons from a bar
function DominosFader:GetBarButtons(bar)
    local buttons = {}
    
    if bar.buttons then
        -- ButtonBar style (has buttons table)
        for _, button in pairs(bar.buttons) do
            if button and button:IsObjectType("Button") then
                table.insert(buttons, button)
            end
        end
    end
    
    return buttons
end

-- Initialize modules table
addonTable.modules = {}
