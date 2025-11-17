local addonName, addonTable = ...

local DominosFader = addonTable.DominosFader
local MAS = addonTable.MAS

if not DominosFader or not MAS then
    print (addonName .. ": Dominos or MouseoverActionSettings not found. Disabling addon.")
    return
end

local MenuBarModule = {}
addonTable.modules.menu = MenuBarModule

function MenuBarModule:RegisterBar(bar, registrationData)
    local moduleName = "DominosMenuBar"
    local eventName = "DOMINOS_MENU_BAR_UPDATE"
    
    -- Get menu buttons
    local buttons = {}
    if bar.buttons then
        for _, button in pairs(bar.buttons) do
            if button and button:IsObjectType("Button") then
                table.insert(buttons, button)
            end
        end
    end
    
    -- Also try to get from activeButtons
    if bar.activeButtons then
        for _, button in pairs(bar.activeButtons) do
            if button and button:IsObjectType("Button") then
                local found = false
                for _, b in ipairs(buttons) do
                    if b == button then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(buttons, button)
                end
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
    local module = MAS:GetModule(moduleName, true)
    if not module then
        module = MAS:NewModule(moduleName)
    end
    
    function module:OnEnable()
        local dbObj = MAS.db.profile[moduleName]
        if not dbObj then
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
end

function MenuBarModule:UnregisterBar(bar)
    local moduleName = "DominosMenuBar"
    
    local module = MAS:GetModule(moduleName, true)
    if module then
        module:Disable()
    end
end
