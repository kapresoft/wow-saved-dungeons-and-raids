--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
---@class LibStub
local LibStub = LibStub
---@type Kapresoft_LibUtil_Objects
local LibUtil = Kapresoft_LibUtil

---@type Kapresoft_LibUtil_PrettyPrint
local PrettyPrint = Kapresoft_LibUtil.PrettyPrint

---@class Namespace
local NamespaceObject = {
    LibName = {}
}

---@type string
local addonName
---@type Namespace
local ns
addonName, ns = ...

---Usage:
---```
---local GC = LibStub(LibName('GlobalConstants'), 1)
---```
---@type fun(moduleName:string, optionalMajorVersion:string)
---@return string The full LibStub library name. Example:  'SavedDungeonsAndRaids-GlobalConstants-1.0.1'
local LibName = ns.LibName

--[[-----------------------------------------------------------------------------
GlobalObjects
-------------------------------------------------------------------------------]]
---@class GlobalObjects
local GlobalObjects = {
    ---@type GlobalConstants
    GlobalConstants = {},
    ---@class AceConsole
    AceConsole = {},

    ---@type fun(fmt:string, ...)|fun(val:string)
    pformat = {},

    ---@type Kapresoft_LibUtil_Objects
    LU = {},
    ---@type Kapresoft_LibUtil_PrettyPrint
    PrettyPrint = {},
    ---@type Kapresoft_LibUtil_Assert
    Assert = {},
    ---@type Kapresoft_LibUtil_Incrementer
    Incrementer = {},
    ---@type Kapresoft_LibUtil_LuaEvaluator
    LuaEvaluator = {},
    ---@type Kapresoft_LibUtil_Mixin
    Mixin = {},
    ---@type Kapresoft_LibUtil_String
    String = {},
    ---@type Kapresoft_LibUtil_Table
    Table = {},
}
--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
---@class Modules
local M = {
    LU = LibUtil,
    GlobalConstants = LibStub(LibName('GlobalConstants')),
    AceConsole = LibStub('AceConsole-3.0'),
    pformat = PrettyPrint.pformat,
}

---Usage:
---```
---local O, LibStub = SDNR_Namespace(...)
---local AceConsole = O.AceConsole
---```
---@return Namespace
function SDNR_Namespace(...)
    ---@type string
    local addon
    ---@type Namespace
    local namespace
    addon, namespace = ...

    ---@type GlobalObjects
    namespace.O = namespace.O or {}
    ---@type string
    namespace.name = addon

    ---@return GlobalObjects, LibStub
    function namespace:LibPack() return self.O, LibStub end
    ---@param libName string The library name. Ex: 'GlobalConstants'
    ---@param o table The library object instance
    function namespace:Register(libName, o)
        if not (libName or o) then return end
        ns.O[libName] = o
    end

    for key, val in pairs(LibUtil) do namespace.O[key] = val end
    for key, val in pairs(M) do namespace.O[key] = val end

    return namespace
end


---@type Modules
SDNR_Modules = M
