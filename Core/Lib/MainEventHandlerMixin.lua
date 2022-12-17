--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = SDNR_Namespace(...)
local O, LibStub, M = ns:LibPack()
local AceEvent, GC = O.AceEvent, O.GlobalConstants
local E, MSG = GC.E, GC.M

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MainEventHandlerMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.MainEventHandlerMixin, 1)
AceEvent:Embed(L)
local p = L.logger

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param f MainEventHandlerFrame
local function OnPlayerEnteringWorld(f, event, ...)
    --p:log('[%s] called...', event)
    local addon = f.ctx.addon
    addon.logger:log('Loaded...')
    --p:log('Namespace keys: %s', ns:ToStringNamespaceKeys())
    --p:log('Namespace Object keys: %s', ns:ToStringObjectKeys())

    ---Other addons can listen to message
    ---AceEvent:RegisterMessage(MSG.OnAddonReady, function(evt, ...) end
    L:SendMessage(MSG.OnAddonReady, addon)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o MainEventHandlerMixin
local function InstanceMethods(o)

    ---Init Method: Called by Mixin
    ---Example:
    ---```
    ---local newInstance = Mixin:MixinAndInit(O.MainEventHandlerMixin, addon)
    ---```
    ---@param addon SavedDungeonsAndRaid
    function o:Init(addon)
        self.addon = addon
    end

    function o:RegisterEvents()
        p:log("RegisterEvents...")
        self:RegisterOnPlayerEnteringWorld()
    end

    function L:RegisterOnPlayerEnteringWorld()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPlayerEnteringWorld)
        RegisterFrameForEvents(f, { E.PLAYER_ENTERING_WORLD })
    end

    ---@param eventFrame _Frame
    ---@return MainEventHandlerFrame
    function o:CreateWidget(eventFrame)
        local widget = {
            frame = eventFrame,
            addon = self.addon,
        }
        return widget
    end

    ---@return MainEventHandlerFrame
    function o:CreateEventFrame()
        ---@type MainEventHandlerFrame
        local f = CreateFrame("Frame", nil, self.addon.frame)
        f.ctx = self:CreateWidget(f)
        return f
    end
end

---Registers a listener to a message event
local function RegisterMessageHandler(o)
    o:RegisterMessage(MSG.OnAfterInitialize, function(evt, ...)
        ---@type SavedDungeonsAndRaid
        local addon = ...
        p:log(10, 'RegisterMessage[%s]: called...', evt)
        addon.mainEventHandler:RegisterEvents()
    end)
end

InstanceMethods(L)
RegisterMessageHandler(L)
