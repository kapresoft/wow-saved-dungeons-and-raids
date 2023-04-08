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
local AceEvent = O.AceLibrary.AceEvent
local E, MSG = GC.E, GC.M

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class MainEventHandler : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(M.MainEventHandler, 1); if not L then return end
L.skipCount = 0
AceEvent:Embed(L)
local p = L.logger


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

---Other modules can listen to message
---```Usage:
---AceEvent:RegisterMessage(MSG.OnAddonReady, function(evt, ...) end
---```
local function SendAddonReadyMessage()
    L:SendMessage(MSG.OnAddonReady, addon)
end

--- @param f MainEventHandlerFrame
--- @param event string The event name
local function OnPlayerEnteringWorld(f, event, ...)
    local version = GC:GetAddonInfo()
    local addon = f.ctx.addon
    addon.logger:log(sformat(ns.Locale.COMMAND_TEXT_FORMAT, version, GC.C.COMMAND, GC.C.HELP_COMMAND))
    addon:RegisterHooks()
    SendAddonReadyMessage()
    After(2, function() L:RegisterOnRequestRaidInfo(); addon.logger:log(10,'RequestRaidInfo() event registered.') end)
end

--- @param f MainEventHandlerFrame
--- @param event string The event name
local function OnRequestRaidInfo(f, event)
    O.SavedInstances:ReportSavedInstances()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o MainEventHandler
local function InstanceMethods(o)

    ---Init Method: Called by Mixin
    ---Example:
    ---```
    ---local newInstance = Mixin:MixinAndInit(O.MainEventHandlerMixin, addon)
    ---```
    --- @param addon SavedDungeonsAndRaid
    function o:Init(addon)
        self.addon = addon
        self:RegisterMessage(MSG.OnAfterInitialize, function(evt, ...) self:OnAfterInitialize() end)
    end
    function o:OnAfterInitialize() self:RegisterEvents() end
    function o:RegisterEvents()
        p:log(100, "RegisterEvents called.")
        self:RegisterOnPlayerEnteringWorld()
    end

    function L:RegisterOnPlayerEnteringWorld()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPlayerEnteringWorld)
        RegisterFrameForEvents(f, { E.PLAYER_ENTERING_WORLD })
    end

    function L:RegisterOnRequestRaidInfo()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnRequestRaidInfo)
        RegisterFrameForEvents(f, { E.UPDATE_INSTANCE_INFO })
    end

    --- @param eventFrame _Frame
    --- @return MainEventHandlerFrame
    function o:CreateContext(eventFrame)
        local ctx = {
            frame = eventFrame,
            addon = self.addon,
        }
        return ctx
    end

    --- @return MainEventHandlerFrame
    function o:CreateEventFrame()
        --- @type MainEventHandlerFrame
        local f = CreateFrame("Frame", nil, self.addon.frame)
        f.ctx = self:CreateContext(f)
        return f
    end
end

InstanceMethods(L)
