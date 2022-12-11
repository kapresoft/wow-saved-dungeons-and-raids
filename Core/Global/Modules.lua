--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format
---@type Namespace
local ns
--@type string
local addon

addon, ns = ...

local O = SDNR_Namespace(...):LibPack()

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub
local LibUtil = Kapresoft_LibUtil_Objects
local SDNR_LibName = SDNR_LibName
local PrettyPrint = Kapresoft_LibUtil.PrettyPrint

---@class Modules
local M = {
    GlobalConstants = LibStub(SDNR_LibName('GlobalConstants')),
    AceConsole = LibStub('AceConsole-3.0'),
    LibUtil = LibUtil,
    pformat = PrettyPrint.pformat,
}
for key, val in pairs(M) do O[key] = val end

---@type Modules
SDNR_Modules = M

