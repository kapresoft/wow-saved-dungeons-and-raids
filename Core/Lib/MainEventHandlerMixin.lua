--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = SDNR_Namespace(...)
local O, LibStub, M = ns:LibPack()
local AceEvent = O.AceEvent

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MainEventHandlerMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.MainEventHandlerMixin, 1)
local p = L.logger

AceEvent:RegisterMessage('AddonMessage_OnAfterInitialize', function(evt, ...)
    ---@type SavedDungeonsAndRaid
    local addon = ...
    --p:log(0, 'RegisterMessage: %s called...', evt)
    addon.mainEventHandler:RegisterEvents()
end)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o MainEventHandlerFrame
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
        local f = CreateFrame("Frame", nil, self.addon.frame)
        f.widget = self:CreateWidget(f)
        return f
    end
end

InstanceMethods(L)
