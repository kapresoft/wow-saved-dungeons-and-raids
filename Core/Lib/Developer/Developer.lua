--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC = ns.O, ns.GC
local AceEvent = O.AceLibrary.AceEvent
local API, MockAPI = O.API, O.MockAPI

--SDNR_LOG_LEVEL = 0
--- Set this to true to mock heroic dungeons data for LFG Frame
--- @see MockAPI
SDNR_MOCK_SAVED_DUNGEONS = false
GC.C.DEBUG_LFG_PRE_RETAIL_DEBUG_HOOK_ENABLED = false

-- Override the saved instances here
MockAPI.SavedInstanceDetails = {
    MockAPI.CoS_TitanRuneBeta, MockAPI.Gundrak, MockAPI.VioletHold_TitanRuneBeta,
    MockAPI.EOE_25, MockAPI.NAXX_25, MockAPI.NAXX_10 }

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Developer : BaseLibraryObject_WithAceEvent
local L = {}; AceEvent:Embed(L); SDNRD = L
local p = O.Logger:NewLogger('Developer')
p:log('Loaded...')

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function L:GetSavedInstances()
    local dungeons, raids = API:GetSavedInstances()
    return { dungeons = dungeons, raids = raids }
end
function L:GetAllSavedInstances()
    local dungeons, raids = API:GetAllSavedInstances()
    return { dungeons = dungeons, raids = raids }
end

--- have be in the instance for this
function L:GetInstanceInfo() return API:GetInstanceInfo() end

--- @param level number
function L:LL(level)
    if not level then
        p:log('SDNR_LOG_LEVEL: %s', SDNR_LOG_LEVEL)
        return
    end
    SDNR_LOG_LEVEL = level or 0
    p:log('New SDNR_LOG_LEVEL is: %s', SDNR_LOG_LEVEL)
end


----[[-----------------------------------------------------------------------------
--Frame
---------------------------------------------------------------------------------]]
--local function OnEvent(frame, event, ...)
--    p:log(10, '%s', event)
--    --if event == 'PLAYER_LEAVING_WORLD' then
--    --end
--end
--
----- @class DeveloperFrame
--local frame = CreateFrame("Frame", 'DeveloperFrame', UIParent)
--frame:SetScript('OnEvent', OnEvent)
--frame:RegisterEvent('PLAYER_ENTERING_WORLD')
--frame:RegisterEvent('PLAYER_LEAVING_WORLD')

