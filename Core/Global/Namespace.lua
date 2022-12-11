--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format
local addon, ns = ...

---@class LibStub
local LibStub = LibStub

---@class NamespaceObjects
local NamespaceObjects = {
    ---@type GlobalConstants
    GlobalConstants = {},
    ---@class AceConsole
    AceConsole = {},
    ---@type Kapresoft_LibUtil_Objects
    LibUtil = {},
    ---@type fun(fmt:string, ...)|fun(val:string)
    pformat = {}
}

---@return Namespace
function SDNR_Namespace(...)
    ---@type string
    local addon
    ---@class Namespace
    local ns
    addon, ns = ...

    ---@type NamespaceObjects
    ns.O = ns.O or {}
    ---@type string
    ns.name = addon

    ---@return NamespaceObjects, LibStub
    function ns:LibPack() return self.O, LibStub end

    return ns
end