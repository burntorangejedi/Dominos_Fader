local addonName, addonTable = ...

local DominosFader = addonTable.DominosFader
local MAS = addonTable.MAS

if not DominosFader or not MAS then
    print (addonName .. ": Dominos or MouseoverActionSettings not found. Disabling addon.")
    return
end

local ActionBarModule = {}
addonTable.modules.action = ActionBarModule

function ActionBarModule:RegisterBar(bar, registrationData)
    local barId = bar.id
    local moduleName = "DominosActionBar" .. barId
    local eventName = "DOMINOS_ACTION_BAR_" .. barId .. "_UPDATE"
    
    -- Get all buttons from this bar
    local buttons = {}
    if bar.buttons then
        for _, button in pairs(bar.buttons) do
            if button and button:IsObjectType("Button") then
                table.insert(buttons, button)
            end
        end
    end
    
    if #buttons == 0 then
        return
    end
    
    -- Create mouseover unit for MAS
    local mo_unit = {
        Parents = {bar},
        visibilityEvent = eventName,
        scriptRegions = buttons,
        statusEvents = {},
    }
    
    mo_unit = MAS:NewMouseoverUnit(mo_unit)
    
    -- Create MAS module
    local module = MAS:NewModule(moduleName)
    
    function module:OnEnable()
        local dbObj = MAS.db.profile[moduleName]
        if not dbObj then
            -- Initialize default settings
            MAS.db.profile[moduleName] = {
                enabled = true,
                minAlpha = 0,
                maxAlpha = 1,
                useCustomDelay = false,
                delay = 0.5,
                useCustomAnimationSpeed = false,
                animationSpeed_In = 0.3,
                animationSpeed_Out = 0.5,
            }
            dbObj = MAS.db.profile[moduleName]
        end
        
        if dbObj.useCustomDelay then
            mo_unit.delay = dbObj.delay
        end
        mo_unit.minAlpha = dbObj.minAlpha
        mo_unit.maxAlpha = dbObj.maxAlpha
        if dbObj.useCustomAnimationSpeed then
            mo_unit.animationSpeed_In = dbObj.animationSpeed_In
            mo_unit.animationSpeed_Out = dbObj.animationSpeed_Out
        end
        mo_unit.statusEvents = {}
        for event, _ in pairs(addonTable.events or {}) do
            if dbObj[event] then
                table.insert(mo_unit.statusEvents, event)
            end
        end
        mo_unit:Enable()
    end
    
    function module:OnDisable()
        mo_unit:Disable()
    end
    
    -- Store reference
    registrationData.mo_unit = mo_unit
    registrationData.mas_module = module
    
    -- Enable the module if MAS is enabled
    if MAS:IsEnabled() then
        module:Enable()
    end
    
    -- Add to MAS UI (if you want it to appear in MAS options)
    self:AddToMASOptions(moduleName, "Action Bar " .. barId, bar)
end

function ActionBarModule:UnregisterBar(bar)
    local moduleName = "DominosActionBar" .. bar.id
    
    -- Disable and remove the MAS module
    local module = MAS:GetModule(moduleName, true)
    if module then
        module:Disable()
    end
end

function ActionBarModule:AddToMASOptions(moduleName, displayName, bar)
    -- This would add the bar to MAS options panel
    -- The implementation depends on MAS's option system
    -- You may need to use MAS's API to register this as a user module
end
