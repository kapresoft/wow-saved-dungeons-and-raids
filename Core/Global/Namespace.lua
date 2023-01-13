--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub

--- @type Kapresoft_LibUtil_Objects
local LibUtil = Kapresoft_LibUtil

--- @type Kapresoft_LibUtil_PrettyPrint
local PrettyPrint = Kapresoft_LibUtil.PrettyPrint
PrettyPrint.setup({ show_function = true, show_metatable = true, indent_size = 2, depth_limit = 3 })


--- @type string
local addonName
--- @type Namespace
local _ns
addonName, _ns = ...

local LibName = _ns.LibName

--[[-----------------------------------------------------------------------------
GlobalObjects
-------------------------------------------------------------------------------]]
--- @class GlobalObjects
local GlobalObjects = {
    --- @type Kapresoft_LibUtil_AceLibraryObjects
    AceLibrary = {},
    --- @type LibStub
    LibStubAce = {},

    --- @type fun(fmt:string, ...)|fun(val:string)
    pformat = {},
    --- @type fun(fmt:string, ...)|fun(val:string)
    sformat = {},

    --- @type Kapresoft_LibUtil_Objects
    LU = {},

    --- @type AceDbInitializerMixin
    AceDbInitializerMixin = {},
    --- @type API
    API = {},
    --- @type Core
    Core = {},
    --- @type GlobalConstants
    GlobalConstants = {},
    --- @type Logger
    Logger = {},
    --- @type MainEventHandler
    MainEventHandler = {},
    --- @type OptionsMixin
    OptionsMixin = {},
    --- @type SavedInstances
    SavedInstances = {},
}
--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]

--- @class Modules
local M = {
    LibStubAce = 'LibStubAce',
    LU = 'LU',
    pformat = 'pformat',
    sformat = 'sformat',
    AceLibrary = 'AceLibrary',

    AceDbInitializerMixin = 'AceDbInitializerMixin',
    API = 'API',
    Core = 'Core',
    GlobalConstants = 'GlobalConstants',
    Logger = 'Logger',
    MainEventHandler = 'MainEventHandler',
    OptionsMixin = 'OptionsMixin',
    SavedInstances = 'SavedInstances',
}

local InitialModuleInstances = {
    -- External Libs --
    LU = LibUtil,
    AceLibrary = LibUtil.AceLibrary.O,
    LibStubAce = LibStub,
    -- Internal Libs --
    GlobalConstants = LibStub(LibName(M.GlobalConstants)),
    pformat = PrettyPrint.pformat,
}

--- @type GlobalConstants
local GC = LibStub(LibName(M.GlobalConstants))

--- @class LibPackMixin
local LibPackMixin = {

    --- @return GlobalObjects, LocalLibStub, Modules, Namespace
    --- @param self LibPackMixin
    LibPack = function(self) return self.O, self.LibStub, self.M, self end,

    --- @param self LibPackMixin
    --- @return GlobalObjects, GlobalConstants, Namespace
    LibPack2 = function(self) return self.O, self.O.GlobalConstants, self end,

    --- @param self LibPackMixin
    AceEvent = function(self) return self.O.AceLibrary.AceEvent:Embed({}) end,

}

---Usage:
---```
---local O, LibStub = SDNR_Namespace(...)
---local AceConsole = O.AceConsole
---```
--- @return Namespace
local function SDNR_Namespace(...)
    --- @type string
    local addon
    --- @type Namespace
    local ns

    addon, ns = ...


    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- @type string
    ns.name = addon
    --- @type string
    ns.nameShort = GC:GetLogName()

    if 'table' ~= type(ns.O) then ns.O = {} end

    for key, val in pairs(LibUtil) do ns.O[key] = val end
    for key, _ in pairs(M) do
        local lib = InitialModuleInstances[key]
        if lib then ns.O[key] = lib end
    end

    ns.pformat = ns.O.pformat
    ns.sformat = ns.O.sformat
    ns.M = M
    ns.GC = ns.O.GlobalConstants
    ns.LibStubAce = ns.O.LibStubAce

    K_Mixin(ns, LibPackMixin)

    local pformat = ns.pformat
    local getSortedKeys = ns.O.Table.getSortedKeys

    --- @param libName string The library name. Ex: 'GlobalConstants'
    --- @param o table The library object instance
    function ns:Register(libName, o)
        if not (libName or o) then return end
        self.O[libName] = o
    end

    --- @param libName string The library name. Ex: 'GlobalConstants'
    function ns:NewLogger(libName) return self.O.Logger:NewLogger(libName) end
    function ns:ToStringNamespaceKeys() return pformat(getSortedKeys(ns)) end
    function ns:ToStringObjectKeys() return pformat(getSortedKeys(ns.O)) end
    --- @return LoggerInterface
    function ns:GetAddonLogger() return _G[self.name].logger end
    return ns
end

local namespace = SDNR_Namespace(...)

---```
---local O, LibStub, M, ns = SDNR_LibPack(...)
---```
--- @return GlobalObjects, LocalLibStub, Modules, Namespace
function SDNR_LibPack(...) return namespace:LibPack() end

---Example:
---```
---local O, GC, ns = SDNR_Namespace(...):SDNR_LibPack2()
---```
--- @return GlobalObjects, GlobalConstants, Namespace
function SDNR_LibPack2(...) return namespace:LibPack2() end
