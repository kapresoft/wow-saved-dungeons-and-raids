--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents
local After = C_Timer.After

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M, GC = ns.O, ns.LibStub, ns.M, ns.O.GlobalConstants
local E, MSG = GC.E, GC.M

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias MainEventHandler MainEventHandlerMixin | BaseLibraryObject | _Frame
--- @class MainEventHandlerMixin
local L = LibStub:NewLibrary(M.MainEventHandler, 1); if not L then return end
L.skipCount = 0
--AceEvent:Embed(L)
local p = L.logger

--- @type MainEventHandler
DEVS_MainEventHandlerMixin = L

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

---Other modules can listen to message
---```Usage:
---AceEvent:RegisterMessage(MSG.OnAddonReady, function(evt, ...) end
---```
local function SendAddonReadyMessage()
    ns:AceEvent():SendMessage(MSG.OnAddonReady)
end

--- @param f MainEventHandler
--- @param event string The event name
local function OnPlayerEnteringWorld(f, event, ...)
    local version = GC:GetAddonInfo()
    --- @type SavedDungeonsAndRaid
    local addon = _G[ns.name]
    addon.logger:log(sformat(ns.Locale.COMMAND_TEXT_FORMAT, version, GC.C.COMMAND, GC.C.HELP_COMMAND))
    addon:RegisterHooks()
    SendAddonReadyMessage()
    After(2, function() f:RegisterOnRequestRaidInfo(); addon.logger:log(10,'RequestRaidInfo() event registered.') end)
end

--- @param f MainEventHandlerFrame
--- @param event string The event name
local function OnRequestRaidInfo() O.SavedInstances:ReportSavedInstances() end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o MainEventHandlerMixin | _Frame
local function InstanceMethods(o)

    function o:OnLoad()
        RegisterFrameForEvents(self, { E.PLAYER_ENTERING_WORLD })
    end

    function o:OnEvent(event, ...)
        if E.PLAYER_ENTERING_WORLD == event then
            OnPlayerEnteringWorld(self, event, ...)
        elseif E.UPDATE_INSTANCE_INFO == event then
            OnRequestRaidInfo()
        end
    end

    function o:RegisterOnRequestRaidInfo()
        RegisterFrameForEvents(self,{ E.UPDATE_INSTANCE_INFO })
    end

end; InstanceMethods(L)
