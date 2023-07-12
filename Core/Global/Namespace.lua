--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type string
local addonName
--- @class __Namespace_Lib
local _ns
addonName, _ns = ...

--- @type LibStub
local LibStub = LibStub

--- @type Kapresoft_LibUtil
local LibUtil = _ns.Kapresoft_LibUtil

local pformat = LibUtil.pformat

--- @type Kapresoft_LibUtil_PrettyPrint
local PrettyPrint = _ns.pformat.pprint
PrettyPrint.setup({ show_function = true, show_metatable = true, indent_size = 2, depth_limit = 3 })

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
    --- @type MockAPI
    MockAPI = {},
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
    MockAPI = 'MockAPI',
    Core = 'Core',
    GlobalConstants = 'GlobalConstants',
    Logger = 'Logger',
    MainEventHandler = 'MainEventHandler',
    OptionsMixin = 'OptionsMixin',
    SavedInstances = 'SavedInstances',

}

local LibUtilObjects = LibUtil.Objects
local AceLibraryObjects = LibUtilObjects.AceLibrary.O

local InitialModuleInstances = {
    -- External Libs --
    LU = LibUtilObjects,
    AceLibrary = AceLibraryObjects,
    LibStubAce = LibStub,
    -- Internal Libs --
    GlobalConstants = LibStub(LibName(M.GlobalConstants)),
    pformat = pformat,
}

--- @type GlobalConstants
local GC = LibStub(LibName(M.GlobalConstants))

--- @class __LibPackMixin
local LibPackMixin = {

    --- @type fun() : GlobalObjects, Kapresoft_LibUtil_LibStub, Modules, __LibPackMixin
    LibPack = function(self) return self.O, self.LibStub, self.M, self end,

    --- @type fun() : GlobalConstants, __LibPackMixin
    LibPack2 = function(self) return self.O, self.O.GlobalConstants, self end,

    --- Creates a new instance of AceEvent
    --- @type fun( self: __LibPackMixin ) : AceEvent
    AceEvent = function(self) return self.O.AceLibrary.AceEvent:Embed({}) end,

    --- Creates a new instance of AceEvent
    --- @type fun( self: __LibPackMixin ) : AceHook
    AceHook = function(self) return self.O.AceLibrary.AceHook:Embed({}) end,

}

---Usage:
---```
---local O, LibStub = SDNR_Namespace(...)
---local AceConsole = O.AceConsole
---```
--- @param addon string The addon name
--- @param ns __Namespace_Lib | __LibPackMixin | __Namespace_Interface
--- @return Namespace
local function CreatNameSpace(addon, ns)

    Mixin(ns, LibPackMixin)

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- @type string
    ns.name = addon
    --- @type string
    ns.nameShort = GC:GetLogName()

    if 'table' ~= type(ns.O) then ns.O = {} end

    for key, val in pairs(LibUtil) do ns.O[key] = val end
    for key, _ in pairs(InitialModuleInstances) do
        local lib = InitialModuleInstances[key]
        if lib then ns.O[key] = lib end
    end

    ns.pformat = ns.O.pformat
    ns.sformat = ns.O.sformat
    ns.M = M
    ns.Locale = {}
    ns.GC = ns.O.GlobalConstants
    ns.LibStubAce = ns.O.LibStubAce

    if not _G['pformat'] then _G['pformat'] = ns.pformat end

    local getSortedKeys = ns.O.LU.Table.getSortedKeys

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
    --- @return Logger
    function ns:GetAddonLogger() return _G[self.name].logger end

    ---```
    --- @type Namespace
    --- local _, ns = ...
    --- local O, LibStub, M = ns.O, ns.LibStub, ns.M
    ---```
    --- @return GlobalObjects, LocalLibStub, Modules
    function ns:LibPack() return self.O, self.LibStub, self.M end

    ---Example:
    ---```
    --- @type Namespace
    --- local _, ns = ...
    --- local O, GC = ns.O, ns.O.GlobalConstants
    ---```
    --- @return GlobalObjects, GlobalConstants, Namespace
    function ns:LibPack2() return self.O, self.GC end

    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = LibUtil.Objects.LibStubMixin:New(ns.name, 1.0,
            function(name, newLibInstance)
                --- @type Logger
                local loggerLib = LibStub(ns.LibName(M.Logger))
                if loggerLib then
                    newLibInstance.logger = loggerLib:NewLogger(name)
                    newLibInstance.logger:log(30, 'New Lib: %s', newLibInstance.major)
                end
                ns:Register(name, newLibInstance)
            end)
    ns.LibStub = LocalLibStub

    return ns
end

if _ns.name then return end

CreatNameSpace(addonName, _ns)
