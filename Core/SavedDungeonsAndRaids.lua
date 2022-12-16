--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = SDNR_Namespace(...)
local O, LibStubLocal, M = ns:LibPack()
local LibStub = LibStub
local Mixin = O.LU.Mixin
local Table = O.Table
local toStringSorted = Table.toStringSorted
local pformat = O.pformat

---@class SavedDungeonsAndRaid
local A = LibStub("AceAddon-3.0"):NewAddon(ns.name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local mt = getmetatable(A) or {}
mt.__tostring = ns.ToStringFunction()
local p = O.Logger:NewLogger()

--setmetatable(A, mt)
ns['addon'] = A


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o SavedDungeonsAndRaid
local function Methods(o)
    local mainEventHandler = Mixin:MixinAndInit(O.MainEventHandlerMixin, o)
    o.mainEventHandler = mainEventHandler

    function o:OnInitialize()
        p:log(10, "Initialized called..")
        self:SendMessage('AddonMessage_OnAfterInitialize', self)
    end
end

local function Constructor()
    Methods(A)
    p:log('Loaded: %s', ns.name)
    --p:log('Namespace keys: %s', ns:ToStringNamespaceKeys())
    --p:log('Namespace Object keys: %s', ns:ToStringObjectKeys())
    SDNR = A
end

Constructor()



