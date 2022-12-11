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

local TOSTRING_ADDON_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe}}|r'
local TOSTRING_SUBMODULE_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe::|r|cfdfbeb2d%s|r|cfdfefefe}}|r'

---@param moduleName string
---@param optionalMajorVersion number|string
local function LibName(moduleName, optionalMajorVersion)
    assert(moduleName, "Module name is required for LibName(moduleName)")
    local majorVersion = optionalMajorVersion or '1.0'
    local v = sformat("%s-%s-%s", addon, moduleName, majorVersion)
    return v
end
---@param moduleName string
local function ToStringFunction(moduleName)
    if moduleName then return function() return string.format(TOSTRING_SUBMODULE_FMT, addon, moduleName) end end
    return function() return string.format(TOSTRING_ADDON_FMT, addon) end
end

---@class LocalLibStub
local S = {}

---@param moduleName string
---@param optionalMinorVersion number
function S:NewLibrary(moduleName, optionalMinorVersion)
    local o = LibStub:NewLibrary(LibName(moduleName), optionalMinorVersion or 1)
    assert(o, sformat("Module not found: %s", tostring(moduleName)))
    o.mt = getmetatable(o) or {}
    o.mt.__tostring = ns.ToStringFunction(moduleName)
    setmetatable(o.mt, o)
    ns:Register(moduleName, o)
    return o
end

---@param moduleName string
---@param optionalMinorVersion number
function S:GetLibrary(moduleName, optionalMinorVersion) return LibStub(LibName(moduleName), optionalMinorVersion or 1) end

S.mt = { __call = function (_, ...) return S:GetLibrary(...) end }
setmetatable(S, S.mt)

---@class GlobalConstants
local L = LibStub:NewLibrary(LibName('GlobalConstants'), 1)

---@param o GlobalConstants
local function Methods(o)
    --  TODO
end
Methods(L)

ns.LibName = LibName
ns.ToStringFunction = ToStringFunction
ns.LibStub = S