--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetSavedInstanceInfo = GetSavedInstanceInfo

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, M = SDNR_LibPack(...)
local GC, String = O.GlobalConstants, O.LU.String
local IsEmptyTable = O.LU.Table.isEmpty
local INSTANCE_COUNT
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class API : BaseLibraryObject
local L = LibStub:NewLibrary(M.API)
local p = L.logger;

---@class SavedInstanceInfo
local _SavedInstance = {
    name = 'The Nexus',
    instanceLockId = 123456789,
    difficulty = 2,
    difficultyName = 'Normal|Heroic',
    isRaid = false,
    isLocked = false,
}

---@return table, table The first table is regular instance and second is raid
---@param o API
local function Methods(o)

    ---@param index number
    ---@return SavedInstanceInfo
    function o:GetSavedInstanceInfoByIndex(index)
        local name, id, _, difficulty, isLocked, _, _, isRaid, _, difficultyName = GetSavedInstanceInfo(index)
        if String.IsBlank(name) then return nil end
        ---@type SavedInstanceInfo
        local d = {
            name = name,
            instanceLockId = id,
            difficulty = difficulty,
            difficultyName = difficultyName,
            isLocked = isLocked,
            isRaid = isRaid,
        }
        return d
    end

    ---@return table<string, DataProviderElement>
    function o:GetSavedDungeonsElement()
        return self:GetSavedInstanceByFilter(function(s) return s.isRaid == false end)
    end

    ---@return table<string, DataProviderElement>
    function o:GetSavedRaidsElement()
        return self:GetSavedInstanceByFilter(function(s) return s.isRaid == true end)
    end

    ---@param predicateFn fun(savedInstanceInfo:SavedInstanceInfo)
    ---@return table<string, DataProviderElement>
    function o:GetSavedInstanceByFilter(predicateFn)
        ---@type LFGListingFrameActivityViewScrollBox
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not (view and view:GetDataProvider()) then return end
        local dataProvider = view:GetDataProvider()

        ---@type table<string, DataProviderElement>
        local results = {}

        for i=1, 25 do
            local info = self:GetSavedInstanceInfoByIndex(i)
            if info and info.name then
                local instanceName = info.name
                local savedElem = dataProvider:FindElementDataByPredicate(function(elem)
                    if not (elem and elem.data) then return false end
                    return instanceName == elem.data.name
                end)
                if savedElem and predicateFn(info) then results[instanceName] = savedElem end
            end
        end

        return results
    end

    ---@return table<string, SavedInstanceInfo>, table<string, SavedInstanceInfo>
    function o:GetSavedInstances()
        ---@type SavedInstanceInfo
        local dungeons = {}
        ---@type SavedInstanceInfo
        local raids = {}
        for i=1, 25 do
            local d = self:GetSavedInstanceInfoByIndex(i)
            if d and d.name then
                local tbl = dungeons
                if d.isRaid == true then tbl = raids end
                tbl[d.name] = d
            end
        end
        return dungeons, raids
    end

end

Methods(L)

SDNR_API = L
