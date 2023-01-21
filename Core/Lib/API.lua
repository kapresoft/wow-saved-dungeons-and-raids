--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetNumSavedInstances, GetSavedInstanceInfo = GetNumSavedInstances, GetSavedInstanceInfo

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M = ns.O, ns.LibStub, ns.M
local LibUtil = ns.Kapresoft_LibUtil

local String = O.LU.String
local IsBlank,ContainsIgnoreCase = String.IsBlank, String.ContainsIgnoreCase
local IsEmptyTable = O.LU.Table.isEmpty
local pformat = ns.pformat

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class API : BaseLibraryObject
local L = LibStub:NewLibrary(M.API)
local p = L.logger;

--- @class SavedInstanceInfo
local _SavedInstance = {
    id = -1,
    name = 'The Nexus',
    nameId = 'The Nexus (Heroic)',
    instanceLockId = 123456789,
    maxPlayers = maxPlayers,
    difficulty = 2,
    difficultyName = 'Normal|Heroic|Mythic',
    isRaid = false,
    isLocked = false,
    instanceIDMostSig = -1,
}
local CategoryID = { Dungeon = 2, Raid = 114 }
--- @class CategoryInfo
local CategoryInfoMixin = {
    --- @param self CategoryInfo
    --- @param id number Category ID
    --- @param name string Category Name, i.e. Dungeons, Raids
    Init = function(self, id, name)
        self.id = id
        self.name = name
    end,
    --- @param self CategoryInfo
    IsDungeon = function(self) return self.id == CategoryID.Dungeon end,
    --- @param self CategoryInfo
    IsRaid = function(self) return self.id == CategoryID.Raid end,
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param savedInstanceInfo SavedInstanceInfo
local function IsInstanceSaved(savedInstanceInfo)
    if not (savedInstanceInfo and savedInstanceInfo.name) then return false end
    return savedInstanceInfo.isLocked
end

--- @param savedInstanceInfo SavedInstanceInfo
--- @return boolean
local function IsHeroic(savedInstanceInfo)
    return ContainsIgnoreCase(savedInstanceInfo.difficultyName, 'heroic')
end

--- @param savedInstanceInfo SavedInstanceInfo
--- @return boolean
local function IsMythic(savedInstanceInfo)
    return ContainsIgnoreCase(savedInstanceInfo.difficultyName, 'mythic')
end

--- @param savedInstanceInfo SavedInstanceInfo
--- @return string
local function GetUniqueName(savedInstanceInfo)
    local difficultyName = savedInstanceInfo.difficultyName:gsub('[%(%)]', '')
    return sformat("%s (%s)", savedInstanceInfo.name, difficultyName)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return table, table The first table is regular instance and second is raid
--- @param o API
local function Methods(o)

    --- @return CategoryInfo
    function o:GetSelectedCategory()
        if not _G['LFGListingFrame'] then return nil end
        local catID = _G['LFGListingFrame']:GetCategorySelection()
        if not catID then return nil end

        --- @type CategoryInfo
        local name, parentCatID, flags = C_LFGList.GetCategoryInfo(catID)
        p:log(10, 'C_LFGList.GetCategoryInfo: %s', pformat({ name=name, parentCatID=parentCatID, flags=flags }))
        if not name then return nil end
        --- @type CategoryInfo
        local c = LibUtil:CreateAndInitFromMixin(CategoryInfoMixin, catID, name)
        return c
    end

    --- @param index number
    --- @return SavedInstanceInfo
    function o:GetSavedInstanceInfoByIndex(index)
        local name, id, _, difficulty, isLocked, _, instanceIDMostSig, isRaid,
            maxPlayers, difficultyName = GetSavedInstanceInfo(index)
        if IsBlank(name) then return nil end
        --- @type SavedInstanceInfo
        local d = {
            name = name,
            id = id,
            nameId = {},
            instanceLockId = id,
            maxPlayers = maxPlayers,
            difficulty = difficulty,
            difficultyName = difficultyName,
            isLocked = isLocked,
            isRaid = isRaid,
            instanceIDMostSig = instanceIDMostSig
        }
        return d
    end

    --- @return table<string, DataProviderElement>
    function o:GetSavedDungeonsElement()
        return self:GetSavedInstanceByFilter(function(s) return s.isRaid == false end)
    end

    --- @return table<string, DataProviderElement>
    function o:GetSavedRaidsElement()
        return self:GetSavedInstanceByFilter(function(s) return s.isRaid == true end)
    end

    --- @param predicateFn fun(savedInstanceInfo:SavedInstanceInfo)
    --- @return table<string, DataProviderElement>
    function o:GetSavedInstanceByFilter(predicateFn)
        local C_LFGList = _G['C_LFGList']
        if not C_LFGList then return end

        --- @type LFGListingFrameActivityViewScrollBox
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not (view and view:GetDataProvider()) then return end

        local dataProvider = view:GetDataProvider()

        --- @type table<string, DataProviderElement>
        local results = {}

        --- @param info SavedInstanceInfo
        local createMainPredicate = function(info)
            return function(elem)
                if not (elem and elem.data) then return false end
                local iName = info.name
                local data = elem.data
                if data.activityID then
                    local ai = C_LFGList.GetActivityInfoTable(data.activityID)
                    return ai and ai.maxNumPlayers and (iName == data.name and info.maxPlayers == ai.maxNumPlayers)
                end
                return iName == data.name
            end
        end

        for i=1,25 do
            local info = self:GetSavedInstanceInfoByIndex(i)
            if info and info.name then
                local savedElem = dataProvider:FindElementDataByPredicate(createMainPredicate(info))
                if savedElem and predicateFn(info) then results[info.name] = savedElem end
            end
        end

        return results
    end

    --- @return table<string, SavedInstanceInfo>, table<string, SavedInstanceInfo>
    function o:GetSavedInstances()
        return self:GetAllSavedInstances(function(savedInfo) return IsInstanceSaved(savedInfo) end)
    end

    --- @return table<string, SavedInstanceInfo>, table<string, SavedInstanceInfo>
    --- @param filterFn fun(savedInfo:SavedInstanceInfo): boolean
    function o:GetAllSavedInstances(filterFn)
        --- @type SavedInstanceInfo
        local dungeons = {}
        --- @type SavedInstanceInfo
        local raids = {}

        local count = GetNumSavedInstances()
        for i=1, count do
            local savedInfo = self:GetSavedInstanceInfoByIndex(i)
            local tbl = dungeons
            if savedInfo.isRaid then tbl = raids end
            savedInfo.nameId = GetUniqueName(savedInfo)

            if filterFn then
                if filterFn(savedInfo) then tbl[savedInfo.nameId] = savedInfo end
            else tbl[savedInfo.nameId] = savedInfo end
        end

        return dungeons, raids
    end

end

Methods(L)
