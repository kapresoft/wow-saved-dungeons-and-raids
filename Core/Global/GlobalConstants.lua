--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format
local addon, ns = ...

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub
ns.LibStub = LibStub

---@param moduleName string
---@param optionalMajorVersion number|string
local function LibName(moduleName, optionalMajorVersion)
    local majorVersion = optionalMajorVersion or '1.0'
    local v = sformat("%s-%s-%s", addon, moduleName, majorVersion)
    return v
end

---@class GlobalConstants
local L = LibStub:NewLibrary(LibName('GlobalConstants'), 1)

local function Methods(o)
    function o:LibName(...) return LibName(...) end
end

Methods(L)

SDNR_LibName = LibName
