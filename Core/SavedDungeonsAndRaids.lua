--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = SDNR_Namespace(...)
local LibStub = LibStub
local O, LibStubLocal, M = ns:LibPack()
local GC = O.GlobalConstants
local Table = O.Table
local toStringSorted, pformat = Table.toStringSorted, O.pformat

---@class SavedDungeonsAndRaid
local A = LibStub("AceAddon-3.0"):NewAddon(ns.name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local mt = getmetatable(A) or {}
mt.__tostring = ns.ToStringFunction()
local p = O.Logger:NewLogger()
A.logger = p

--setmetatable(A, mt)
ns['addon'] = A


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o SavedDungeonsAndRaid
local function Methods(o)

    O.MainEventHandler:Init(o)

    function o:OnInitialize()
        p:log(10, "Initialized called..")
        self:SendMessage(GC.M.OnAfterInitialize, self)
    end
end

local function Constructor()
    Methods(A)
    SDNR = A
end

Constructor()



