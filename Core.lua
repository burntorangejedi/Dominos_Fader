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
    self:Print("Dominos Fader loaded - MouseOverActionSettings support enabled")
end

function DominosFader:OnEnable()
    -- Register callbacks for when bars are created/destroyed
    Dominos.RegisterCallback(self, "BAR_CREATED", "OnBarCreated")
    Dominos.RegisterCallback(self, "BAR_FREED", "OnBarFreed")
    
    -- Register existing bars
    for id, frame in Dominos.Frame:GetAll() do
        self:RegisterBar(frame)
    end
end

function DominosFader:OnDisable()
    -- Unregister all bars
    for id, data in pairs(self.registeredBars) do
        self:UnregisterBar(id)
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
