--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local C_LFGList = C_LFGList
local GetNumSavedInstances, GetSavedInstanceInfo = GetNumSavedInstances, GetSavedInstanceInfo
local Mixin, GetDifficultyInfo = Mixin, GetDifficultyInfo
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M, GC = ns.O, ns.LibStub, ns.M, ns.GC
local MockAPI = O.MockAPI
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

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return table, table The first table is regular instance and second is raid
--- @param o API
local function Methods(o)

    --- @param savedInstanceInfo SavedInstanceInfo
    --- @return string
    function o:GetUniqueName(savedInstanceInfo)
        local difficultyName = savedInstanceInfo.difficultyName:gsub('[%(%)]', '')
        return sformat("%s (%s)", savedInstanceInfo.name, difficultyName)
    end

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

    --- Player has to be in the instance for this
    --- @return InstanceInfo
    function o:GetInstanceInfo()
        local name, instanceType, difficultyID, difficultyName, maxPlayers,
            dynamicDifficulty, isDynamic, instanceID, instanceGroupSize,
            LfgDungeonID = GetInstanceInfo()
        if not name then return nil end

        --- @type InstanceInfo
        local info = {
            name = name,
            instanceType = instanceType,
            difficultyID = difficultyID,
            difficultyName = difficultyName,
            maxPlayers = maxPlayers,
            dynamicDifficulty = dynamicDifficulty,
            isDynamic = isDynamic,
            instanceID = instanceID,
            instanceGroupSize = instanceGroupSize,
            LfgDungeonID = LfgDungeonID,
        }
        return info
    end

    --- #### See
    --- - [https://wowpedia.fandom.com/wiki/API_GetSavedInstanceInfo](https://wowpedia.fandom.com/wiki/API_GetSavedInstanceInfo)
    --- - [https://wowpedia.fandom.com/wiki/InstanceID](https://wowpedia.fandom.com/wiki/InstanceID)
    --- @param index number
    --- @return SavedInstanceInfo
    function o:GetSavedInstanceInfoByIndex(index)
        if SDNR_MOCK_SAVED_DUNGEONS == true then
            return MockAPI:GetSavedInstanceInfoByIndex(index)
        end

        local name, id, reset, difficulty, isLocked, isExtended, _, isRaid,
            maxPlayers, difficultyName, numEncounters, encounterProgress,
            extendDisabled, instanceID = GetSavedInstanceInfo(index)
        if IsBlank(name) then return nil end

        --- @type SavedInstanceInfo
        local d = {
            name = name,
            lockoutID = id,
            reset = reset,
            nameId = nil,
            difficulty = difficulty,
            isLocked = isLocked,
            isExtended = isExtended,
            isRaid = isRaid,
            maxPlayers = maxPlayers,
            difficultyName = difficultyName,
            numEncounters = numEncounters,
            encounterProgress = encounterProgress,
            extendDisabled = extendDisabled,
            instanceID = instanceID,
            encounters = self:GetSavedInstanceEncounters(index)
        }
        d.nameId = self:GetUniqueName(d)
        return d
    end

    function o:GetNumSavedInstances()
        if SDNR_MOCK_SAVED_DUNGEONS == true then return MockAPI:GetNumSavedInstances() end
        return GetNumSavedInstances()
    end

    --- @return table<string, SavedInstanceDetails>
    function o:GetSavedInstanceByFilter()
        if not C_LFGList then return end

        --- @type LFGListingFrameActivityViewScrollBox
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not (view and view:GetDataProvider()) then return end
        local dataProvider = view:GetDataProvider()

        --- @type table<string, DataProviderElement>
        local results = {}

        --- @param savedInstanceInfo SavedInstanceInfo
        local createMainPredicate = function(savedInstanceInfo)
            ---@param elem DataProviderElement
            return function(elem)
                if not (elem and elem.data) then return false end
                local savedName = savedInstanceInfo.name
                local data = elem.data
                if data.activityID then
                    local ai = self:GetActivityInfo(data.activityID)
                    return ai and savedName == ai.shortName
                            and data.minLevel == ai.minLevel
                            and savedInstanceInfo.difficultyName == ai.difficultyName
                end
                return savedName == data.name
            end
        end

        local count = self:GetNumSavedInstances()
        for i=1, count do
            local savedInstanceInfo = self:GetSavedInstanceInfoByIndex(i)
            savedInstanceInfo.instanceIndex = i
            local savedElem = dataProvider:FindElementDataByPredicate(createMainPredicate(savedInstanceInfo))
            if savedElem then
                local activity = self:GetActivityInfo(savedElem.data.activityID)
                --- @type SavedInstanceDetails
                local ret = {
                    data = savedElem.data,
                    info = savedInstanceInfo, activity = activity,
                    -- savedCategoryName = savedInCategoryName,
                }
                ret.relatedInstances = self:GetRelatedInstances(dataProvider, function(elem)
                    local elemData = elem.data
                    return savedInstanceInfo.name == elemData.name
                            and activity.id ~= elemData.activityID
                            and activity.minLevel == elemData.minLevel
                end)
                results[savedInstanceInfo.nameId] = ret
            end
        end

        return results
    end

    --- @param filterFn DataProviderFilterFn
    function o:GetRelatedInstances(dataProvider, filterFn) return self:FindAll(dataProvider, filterFn) end

    --- @param predicateFn DataProviderFilterFn
    --- @param dp DataProvider
    --- @return table<number, DataProviderElementData>
    function o:FindAll(dp, predicateFn)
        local results = {}
        for index, elem in dp:Enumerate() do
            if predicateFn(elem) == true then table.insert(results, elem.data) end
        end
        return results
    end

    --- @param instanceName string
    --- @param relatedInstances table<number, DataProviderElementData>
    function o:LogElementData(instanceName, relatedInstances)
        for i, elemData in ipairs(relatedInstances) do
            p:log('EleData %s[%s]: %s', savedInstanceInfo.name, i, pformat(elemData))
        end
    end

    --- @param instanceIndex number
    --- @return Encounters
    function o:GetSavedInstanceEncounters(instanceIndex)
        --- @type Encounters
        local encounters = {}
        for i = 1, 20 do
            local bossName, fileDataID, isKilled, unknown4 = GetSavedInstanceEncounterInfo(instanceIndex, i)
            if bossName then
                --- @type EncounterInfo
                local d = { bossName=bossName, fileDataID=fileDataID, isKilled=isKilled }
                table.insert(encounters, d)
            else
                return encounters
            end
        end
        return encounters
    end

    ---@param activityID number
    function o:GetActivityInfoTable(activityID)
        if SDNR_MOCK_SAVED_DUNGEONS == true then
            return MockAPI:GetActivityInfoTable(activityID)
        end
        return C_LFGList.GetActivityInfoTable(activityID)
    end

    --- ### See
    --- - Wow Classic [https://wowpedia.fandom.com/wiki/API_C_LFGList.GetActivityInfo](https://wowpedia.fandom.com/wiki/API_C_LFGList.GetActivityInfo)
    --- - All Others [https://wowpedia.fandom.com/wiki/API_C_LFGList.GetActivityInfoTable](https://wowpedia.fandom.com/wiki/API_C_LFGList.GetActivityInfoTable)
    --- @param activityID number
    --- @return ActivityInfoDetails
    function o:GetActivityInfo(activityID)
        local activity = self:GetActivityInfoTable(activityID)
        if not activity then return end
        local difficulty = self:GetDifficultyInfo(activity.difficultyID)

        --- @type ActivityInfoDetails
        local ret = {
            id = activityID,
            difficultyName = difficulty.name,
            isHeroic = difficulty.isHeroic,
        }
        return Mixin(ret, activity)
    end

    --- @return DifficultyInfo
    --- @param difficultyID number
    function o:GetDifficultyInfo(difficultyID)
        local name, groupType, isHeroic, isChallengeMode, displayHeroic,
            displayMythic, toggleDifficultyID = GetDifficultyInfo(difficultyID)
        return {
            name = name,
            groupType = groupType,
            isHeroic = isHeroic,
            isChallengeMode = isChallengeMode,
            displayHeroic = displayHeroic,
            displayMythic = displayMythic,
            toggleDifficultyID = toggleDifficultyID
        }
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

        local count = self:GetNumSavedInstances()
        for i=1, count do
            local savedInfo = self:GetSavedInstanceInfoByIndex(i)
            savedInfo.instanceIndex = i
            local tbl = dungeons
            if savedInfo.isRaid then tbl = raids end
            savedInfo.nameId = self:GetUniqueName(savedInfo)

            if filterFn then
                if filterFn(savedInfo) then tbl[savedInfo.nameId] = savedInfo end
            else tbl[savedInfo.nameId] = savedInfo end
        end

        return dungeons, raids
    end

end

Methods(L)
