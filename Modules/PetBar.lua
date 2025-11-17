local addonName, addonTable = ...

local DominosFader = addonTable.DominosFader
local MAS = addonTable.MAS

if not DominosFader or not MAS then
    print(addonName .. ": Dominos or MouseoverActionSettings not found. Disabling addon.")
    return
end

local PetBarModule = {}
addonTable.modules.pet = PetBarModule

function PetBarModule:RegisterBar(bar, registrationData)
    local moduleName = "Dominos_PetBar"
    local eventName = "DOMINOS_PET_BAR_UPDATE"

    -- Get pet buttons
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
        Parents = { bar },
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
            -- Initialize default settings with combat enabled
            MAS.db.profile[moduleName] = {
                enabled = true,
                minAlpha = 0,
                maxAlpha = 1,
                useCustomDelay = false,
                delay = 0.5,
                useCustomAnimationSpeed = false,
                animationSpeed_In = 0.3,
                animationSpeed_Out = 0.5,
                COMBAT_UPDATE = true,  -- Enable combat by default
            }
            dbObj = MAS.db.profile[moduleName]
        else
            -- Migrate existing settings: enable combat if not explicitly set
            if dbObj.COMBAT_UPDATE == nil then
                dbObj.COMBAT_UPDATE = true
            end
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
        
        -- Update status events - read current settings from database
        mo_unit.statusEvents = {}
        local possibleEvents = {
            "COMBAT_UPDATE",
            "TARGET_UPDATE", 
            "FOCUS_UPDATE",
            "MOUNT_UPDATE",
            "PLAYER_MOVING_UPDATE",
            "NPC_UPDATE",
            "DRAGONRIDING_UPDATE",
            "CASTING_UPDATE",
            "EDIT_MODE_UPDATE",
            "GRID_UPDATE",
        }
        
        for _, event in ipairs(possibleEvents) do
            if dbObj[event] then
                table.insert(mo_unit.statusEvents, event)
            end
        end
        
        mo_unit:Enable()
    end
    
    function module:OnDisable()
        mo_unit:Disable()
    end
    
    function module:Refresh()
        local dbObj = MAS.db.profile[moduleName]
        if not dbObj then return end
        
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
        local possibleEvents = {
            "COMBAT_UPDATE",
            "TARGET_UPDATE", 
            "FOCUS_UPDATE",
            "MOUNT_UPDATE",
            "PLAYER_MOVING_UPDATE",
            "NPC_UPDATE",
            "DRAGONRIDING_UPDATE",
            "CASTING_UPDATE",
            "EDIT_MODE_UPDATE",
            "GRID_UPDATE",
        }
        
        for _, event in ipairs(possibleEvents) do
            if dbObj[event] then
                table.insert(mo_unit.statusEvents, event)
            end
        end
        
        if mo_unit.isEnabled then
            mo_unit:Disable()
            mo_unit:Enable()
        end
    end

    -- Store reference
    registrationData.mo_unit = mo_unit
    registrationData.mas_module = module
    
    mo_unit.mas_module = module
    
    -- Enable the module if MAS is enabled
    if MAS:IsEnabled() then
        module:Enable()
    end
    
    -- Register as User Module in MAS
    local userModuleData = {
        name = moduleName,
        displayName = "Dominos Pet Bar",
        category = "Dominos",
        Parents = {bar},
        scriptRegions = buttons,
    }
    
    if MAS.RegisterUserModule then
        MAS:RegisterUserModule(userModuleData)
    end
end

function PetBarModule:UnregisterBar(bar)
    local moduleName = "Dominos_PetBar"
    
    if MAS.UnregisterUserModule then
        MAS:UnregisterUserModule(moduleName)
    end
    
    local module = MAS:GetModule(moduleName, true)
    if module then
        module:Disable()
    end
end