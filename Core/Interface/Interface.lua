--[[-----------------------------------------------------------------------------
Error Handlers
-------------------------------------------------------------------------------]]
--- @alias SafeCallFn fun() | "function() print('My function') end"
--- @alias SafeCallErrorHandlerFn fun(errorMsg:string) | "function(errorMsg) print('Error occurred:', errorMsg) end"
--- @alias FluentSafeCallExecute fun()
--- @alias FluentErrorHandlerFn fun(errorHandlerFn:SafeCallErrorHandlerFn)

------ @class FluentErrorHandler
local FluentErrorHandler = {
    --- @type FluentSafeCallExecute - Executes the function
    Exec = {}
}
--- @class FluentSafeCall
local FluentSafeCall = {
    --- @type FluentSafeCallExecute - Executes the function
    Exec = {},
    --- @type FluentErrorHandler
    OnError = {}
}

--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @alias Namespace __Namespace_Lib | __Namespace_Interface | __LibPackMixin
--- @class __Namespace_Interface
local Namespace = {
    --- @type Kapresoft_LibUtil_ColorDefinition
    consoleColors = {
        primary   = 'hex:6-char',
        secondary = 'hex:6-char',
        tertiary = 'hex:6-char'
    },
    --- @type Kapresoft_LibUtil
    Kapresoft_LibUtil = {},

    ---Usage:
    ---```
    ---local GC = LibStub(LibName('GlobalConstants'), 1)
    ---```
    --- @type fun(moduleName:string, optionalMajorVersion:string)
    --- @return string The full LibStub library name. Example:  'SavedDungeonsAndRaids-GlobalConstants-1.0.1'
    LibName = {},

    --- @type Kapresoft_LibUtil_LibStub
    LibStub = {},
    --- @type LibStub
    LibStubAce = {},
    ---Usage:
    ---```
    ---local L = {}
    ---local mt = { __tostring = ns.ToStringFunction() }
    ---setmetatable(mt, L)
    ---```
    --- @type fun(moduleName:string)
    ToStringFunction = {},

    --- @type fun(o:any, ...) : void
    pformat = {},
    --- @type table<string, string|number>
    Locale = {},
}

--[[-----------------------------------------------------------------------------
Others
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject
local BaseLibraryObject = {
    --- @type table
    mt = { __tostring = function() end },
}
--- @type Logger
BaseLibraryObject.logger = {}

--- @class BaseLibraryObject_WithAceEvent : AceEvent
local BaseLibraryObject_WithAceEvent = {
    --- @type table
    mt = { __tostring = function() end },
}
--- @type Logger
BaseLibraryObject_WithAceEvent.logger = {}

--- @class MainEventHandlerFrame : _Frame
local MainEventHandlerFrame = {
    --- @type MainEventContext
    ctx = {}
}

--- @class MainEventContext
local EventFrameWidgetInterface = {
    --- @type MainEventHandlerFrame
    frame = {},
    --- @type SavedDungeonsAndRaid
    addon = {},
}

--- @class ActivityInfoDetails : ActivityInfo
--- @see DifficultyInfo
local ActivityInfoDetails = {
    id = 1,
    isHeroic = true,
    difficultyName = '',
}

--- #### See: [https://wowpedia.fandom.com/wiki/API_GetSavedInstanceEncounterInfo](https://wowpedia.fandom.com/wiki/API_GetSavedInstanceEncounterInfo)
--- @class EncounterInfo
local EncounterInfo = {
    bossName = 'General Zod',
    fileDataID = 1,
    isKilled = isKilled
}
--- @alias Encounters table<number, EncounterInfo>

--- @class SavedInstanceInfo
local _SavedInstanceInfo = {
    id = -1,
    --- Index from 1 to GetNumSavedInstances()
    instanceIndex = 1,
    name = 'The Nexus',
    lockoutID = 123456789,
    -- number of seconds remaining until reset
    reset = 1,
    nameId = 'The Nexus (Heroic)',
    difficulty = 2,
    isLocked = true,
    isExtended = true,
    isRaid = true,
    maxPlayers = 5,
    difficultyName = 'Normal|Heroic|Mythic',
    numEncounters = 1,
    encounterProgress = 1,
    extendDisabled = true,
    instanceID = 1,
    --- @type Encounters
    encounters = {}
}

--- @class SavedInstanceDetails
local _SavedInstanceInfoDetails = {
    --- @type SavedInstanceInfo
    info = {},
    --- @type ActivityInfoDetails
    activity = {},
    --- @type DataProviderElementData
    data = {},
}

--- @class MockedInstanceInfo
local MockedInstanceInfo = {
    activity = 1102,
    maxNumPlayers = 10,
    name = 'The Eye of Eternity',
    --- @type InstanceDifficultyName
    difficultyName = '10 Player',
    isRaid = true,
    maxLevel = 80,
    minLevel = 80,
}
