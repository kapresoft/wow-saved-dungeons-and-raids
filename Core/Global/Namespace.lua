--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
---@type LibStub
local LibStub = LibStub

---@type Kapresoft_LibUtil_Objects
local LibUtil = Kapresoft_LibUtil

---@type Kapresoft_LibUtil_PrettyPrint
local PrettyPrint = Kapresoft_LibUtil.PrettyPrint
PrettyPrint.setup({ show_function = true, show_metatable = true, indent_size = 2, depth_limit = 3 })

---@class Namespace
local NamespaceObject = {
    ---Usage:
    ---```
    ---local GC = LibStub(LibName('GlobalConstants'), 1)
    ---```
    ---@type fun(moduleName:string, optionalMajorVersion:string)
    ---@return string The full LibStub library name. Example:  'SavedDungeonsAndRaids-GlobalConstants-1.0.1'
    LibName = {},
    ---Usage:
    ---```
    ---local L = {}
    ---local mt = { __tostring = ns.ToStringFunction() }
    ---setmetatable(mt, L)
    ---```
    ---@type fun(moduleName:string)
    ToStringFunction = {}
}

---@type string
local addonName
---@type Namespace
local ns
addonName, ns = ...

local LibName = ns.LibName

--[[-----------------------------------------------------------------------------
GlobalObjects
-------------------------------------------------------------------------------]]
local AceModule = {
    AceAddon = "AceAddon-3.0",
    AceConsole = 'AceConsole-3.0',
    AceConfig = 'AceConfig-3.0',
    AceConfigDialog = 'AceConfigDialog-3.0',
    AceDB = 'AceDB-3.0',
    AceDBOptions = 'AceDBOptions-3.0',
    AceEvent = 'AceEvent-3.0',
    AceHook = 'AceHook-3.0',
    AceGUI = 'AceGUI-3.0',
    AceLibSharedMedia = 'LibSharedMedia-3.0'
}

---@class AceObjects
local AceObjects = {

    ---@type AceAddon
    AceAddon = {},
    ---@type AceConsole
    AceConsole = {},
    ---@type AceConfig
    AceConfig = {},
    ---@type AceConfigDialog
    AceConfigDialog = {},
    ---@type AceDB
    AceDB = {},
    ---@type AceDBOptions
    AceDBOptions = {},
    ---@type AceEvent
    AceEvent = {},
    ---@type AceHook
    AceHook = {},
    ---@type AceGUI
    AceGUI = {},
    ---@type AceLibSharedMedia
    AceLibSharedMedia = {},

}

---@class GlobalObjects
local GlobalObjects = {
    --AceLib = AceObjects,
    ---@type Kapresoft_LibUtil_AceLibraryObjects
    AceLibrary = {},
    ---@type LibStub
    AceLibStub = {},
    ---@type AceConfig
    AceConfig = AceObjects.AceConfig,
    ---@type AceConsole
    AceConsole = {},
    ---@type AceDB
    AceDB = {},
    ---@type AceEvent
    AceEvent = {},

    ---@type fun(fmt:string, ...)|fun(val:string)
    pformat = {},
    ---@type fun(fmt:string, ...)|fun(val:string)
    sformat = {},

    ---@type Kapresoft_LibUtil_Objects
    LU = {},
    -----@type Kapresoft_LibUtil_PrettyPrint
    --PrettyPrint = {},
    -----@type Kapresoft_LibUtil_Assert
    --Assert = {},
    -----@type Kapresoft_LibUtil_Incrementer
    --Incrementer = {},
    -----@type Kapresoft_LibUtil_LuaEvaluator
    --LuaEvaluator = {},
    -----@type Kapresoft_LibUtil_Mixin
    --Mixin = {},
    -----@type Kapresoft_LibUtil_String
    --String = {},
    -----@type Kapresoft_LibUtil_Table
    --Table = {},

    ---@type Core
    Core = {},
    ---@type AceDbInitializerMixin
    AceDbInitializerMixin = {},
    ---@type GlobalConstants
    GlobalConstants = {},
    ---@type Logger
    Logger = {},
    ---@type MainEventHandler
    MainEventHandler = {},
    ---@type OptionsMixin
    OptionsMixin = {},
}
--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]

---@class Modules
local M = {
    AceLibStub = 'AceLibStub',
    LU = 'LU',
    pformat = 'pformat',
    sformat = 'sformat',
    AceLibrary = 'AceLibrary',
    AceConfig = 'AceConfig',
    AceConsole = 'AceConsole',
    AceDB = 'AceDB',
    AceEvent = 'AceEvent',

    Core = 'Core',
    AceDbInitializerMixin = 'AceDbInitializerMixin',
    GlobalConstants = 'GlobalConstants',
    Logger = 'Logger',
    MainEventHandler = 'MainEventHandler',
    OptionsMixin = 'OptionsMixin',
}

local InitialModuleInstances = {
    -- External Libs --
    LU = LibUtil,
    AceLibrary = LibUtil.AceLibrary.O,
    AceLibStub = LibStub,
    -- Internal Libs --
    GlobalConstants = LibStub(LibName(M.GlobalConstants)),
    AceAddon = LibStub(AceModule.AceAddon),
    AceConsole = LibStub(AceModule.AceConsole),
    AceConfig = LibStub(AceModule.AceConfig),
    AceConfigDialog = LibStub(AceModule.AceConfigDialog),
    AceDB = LibStub(AceModule.AceDB),
    AceDBOptions = LibStub(AceModule.AceDBOptions),
    AceEvent = LibStub(AceModule.AceEvent),
    AceHook = LibStub(AceModule.AceHook),
    AceGUI = LibStub(AceModule.AceGUI),
    AceLibSharedMedia = LibStub(AceModule.AceLibSharedMedia),
    pformat = PrettyPrint.pformat,
}

---@type GlobalConstants
local GC = LibStub(LibName(M.GlobalConstants))

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
    ---@type string
    namespace.nameShort = GC:GetLogName()

    if 'table' ~= type(namespace.O) then namespace.O = {} end

    for key, val in pairs(LibUtil) do namespace.O[key] = val end
    for key, _ in pairs(M) do
        local lib = InitialModuleInstances[key]
        if lib then namespace.O[key] = lib end
    end

    namespace.pformat = namespace.O.pformat
    namespace.sformat = namespace.O.sformat
    namespace.M = M

    local pformat = namespace.pformat
    local getSortedKeys = namespace.O.Table.getSortedKeys

    ---Example:
    ---```
    ---local O, LibStub, M, ns = SDNR_Namespace(...):LibPack()
    ---```
    ---@return GlobalObjects, LocalLibStub, Modules, Namespace
    function namespace:LibPack() return self.O, ns.LibStub, M, self end

    ---@param libName string The library name. Ex: 'GlobalConstants'
    ---@param o table The library object instance
    function namespace:Register(libName, o)
        if not (libName or o) then return end
        self.O[libName] = o
    end

    ---@param libName string The library name. Ex: 'GlobalConstants'
    function namespace:NewLogger(libName) return self.O.Logger:NewLogger(libName) end
    function namespace:ToStringNamespaceKeys() return pformat(getSortedKeys(ns)) end
    function namespace:ToStringObjectKeys() return pformat(getSortedKeys(ns.O)) end

    return namespace
end
---@return GlobalObjects, LocalLibStub, Modules, Namespace
function SDNR_LibPack(...) return SDNR_Namespace(...):LibPack() end

---@type Modules
SDNR_Modules = M
