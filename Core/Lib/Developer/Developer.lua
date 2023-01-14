------------------------------------------------------------------------
-- test stuff.
------------------------------------------------------------------------
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]


local O, GC, ns = SDNR_LibPack2(...)
local AceEvent = O.AceLibrary.AceEvent
local API = O.API

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
